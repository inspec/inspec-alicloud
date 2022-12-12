# -*- encoding: utf-8 -*-

require 'rest-client'
require 'nokogiri'
require 'time'
require 'alicloud/oss/http'
require 'alicloud/oss/config'
require 'alicloud/oss/struct'

module AliCloud
  module OSS


    ##
    # Protocol implement the OSS Open API which is low-level. User
    # should refer to {OSS::Client} for normal use.
    #
    class Protocol

      STREAM_CHUNK_SIZE = 16 * 1024
      CALLBACK_HEADER = 'x-oss-callback'

      include Aliyun::Common::Logging

      def initialize(config)
        @config = config
        @http = HTTP.new(config)
      end

      # List all the buckets.
      # @param opts [Hash] options
      # @option opts [String] :prefix return only those buckets
      #  prefixed with it if specified
      # @option opts [String] :marker return buckets after where it
      #  indicates (exclusively). All buckets are sorted by name
      #  alphabetically
      # @option opts [Integer] :limit return only the first N
      #  buckets if specified
      # @return [Array<Bucket>, Hash] the returned buckets and a
      #  hash including the next tokens, which includes:
      #  * :prefix [String] the prefix used
      #  * :delimiter [String] the delimiter used
      #  * :marker [String] the marker used
      #  * :limit [Integer] the limit used
      #  * :next_marker [String] marker to continue list buckets
      #  * :truncated [Boolean] whether there are more buckets to
      #    be returned
      def list_buckets(opts = {})
        logger.info("Begin list buckets, options: #{opts}")

        params = {
          'prefix' => opts[:prefix],
          'marker' => opts[:marker],
          'max-keys' => opts[:limit],
        }.reject { |_, v| v.nil? }

        r = @http.get( {}, {:query => params})
        doc = parse_xml(r.body)

        buckets = doc.css("Buckets Bucket").map do |node|
          Bucket.new(
            {
              :name => get_node_text(node, "Name"),
              :location => get_node_text(node, "Location"),
              :creation_time =>
                get_node_text(node, "CreationDate") { |t| Time.parse(t) },
            }, self
          )
        end

        more = {
          :prefix => 'Prefix',
          :limit => 'MaxKeys',
          :marker => 'Marker',
          :next_marker => 'NextMarker',
          :truncated => 'IsTruncated',
        }.reduce({}) { |h, (k, v)|
          value = get_node_text(doc.root, v)
          value.nil?? h : h.merge(k => value)
        }

        update_if_exists(
          more, {
            :limit => ->(x) { x.to_i },
            :truncated => ->(x) { x.to_bool },
          }
        )

        logger.info("Done list buckets, buckets: #{buckets}, more: #{more}")

        [buckets, more]
      end

      # Create a bucket
      # @param name [String] the bucket name
      # @param opts [Hash] options
      # @option opts [String] :location the region where the bucket
      #  is located
      # @example
      #   oss-cn-hangzhou
      def create_bucket(name, opts = {})
        logger.info("Begin create bucket, name: #{name}, opts: #{opts}")

        location = opts[:location]
        body = nil
        if location
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.CreateBucketConfiguration {
              xml.LocationConstraint location
            }
          end
          body = builder.to_xml
        end

        @http.put({:bucket => name}, {:body => body})

        logger.info("Done create bucket")
      end

      # Put bucket acl
      # @param name [String] the bucket name
      # @param acl [String] the bucket acl
      # @see OSS::ACL
      def put_bucket_acl(name, acl)
        logger.info("Begin put bucket acl, name: #{name}, acl: #{acl}")

        sub_res = {'acl' => nil}
        headers = {'x-oss-acl' => acl}
        @http.put(
          {:bucket => name, :sub_res => sub_res},
          {:headers => headers, :body => nil})

        logger.info("Done put bucket acl")
      end

      def get_bucket_tagging(name)
        logger.info("Begin get bucket tagging, name: #{name}")

        sub_res = {'tagging' => nil}
        r = @http.get({:bucket => name, :sub_res => sub_res})
        doc = parse_xml(r.body)
        opts = {
          :key => get_node_text(doc.at_css("Tagging TagSet Tag"), "Key"),
          :value => get_node_text(doc.at_css("Tagging TagSet Tag"), "Value"),
        }

        logger.info("Done get bucket tags")
        BucketTagging.new(opts)
      end

      # Get bucket/object url
      # @param [String] bucket the bucket name
      # @param [String] object the bucket name
      # @return [String] url for the bucket/object
      def get_request_url(bucket, object = nil)
        @http.get_request_url(bucket, object)
      end

      # Get bucket/object resource path
      # @param [String] bucket the bucket name
      # @param [String] object the bucket name
      # @return [String] resource path for the bucket/object
      def get_resource_path(bucket, object = nil)
        @http.get_resource_path(bucket, object)
      end

      # Get user's access key id
      # @return [String] the access key id
      def get_access_key_id
        @config.access_key_id
      end

      # Get user's access key secret
      # @return [String] the access key secret
      def get_access_key_secret
        @config.access_key_secret
      end  

      # Get user's STS token
      # @return [String] the STS token
      def get_sts_token
        @config.sts_token
      end

      # Sign a string using the stored access key secret
      # @param [String] string_to_sign the string to sign
      # @return [String] the signature
      def sign(string_to_sign)
        Util.sign(@config.access_key_secret, string_to_sign)
      end

      private

      # Parse body content to xml document
      # @param content [String] the xml content
      # @return [Nokogiri::XML::Document] the parsed document
      def parse_xml(content)
        doc = Nokogiri::XML(content) do |config|
          config.options |= Nokogiri::XML::ParseOptions::NOBLANKS
        end

        doc
      end

      # Get the text of a xml node
      # @param node [Nokogiri::XML::Node] the xml node
      # @param tag [String] the node tag
      # @yield [String] the node text is given to the block
      def get_node_text(node, tag, &block)
        n = node.at_css(tag) if node
        value = n.text if n
        block && value ? yield(value) : value
      end

      # Decode object key using encoding. If encoding is nil it
      # returns the key directly.
      # @param key [String] the object key
      # @param encoding [String] the encoding used
      # @return [String] the decoded key
      def decode_key(key, encoding)
        return key unless encoding

        unless KeyEncoding.include?(encoding)
          fail ClientError, "Unsupported key encoding: #{encoding}"
        end

        if encoding == KeyEncoding::URL
          return CGI.unescape(key)
        end
      end

      # Transform x if x is not nil
      # @param x [Object] the object to transform
      # @yield [Object] the object if given to the block
      # @return [Object] the transformed object
      def wrap(x, &block)
        yield x if x
      end

      # Get conditions for HTTP headers
      # @param conditions [Hash] the conditions
      # @return [Hash] conditions for HTTP headers
      def get_conditions(conditions)
        {
          :if_modified_since => 'if-modified-since',
          :if_unmodified_since => 'if-unmodified-since',
        }.reduce({}) { |h, (k, v)|
          conditions.key?(k)? h.merge(v => conditions[k].httpdate) : h
        }.merge(
          {
            :if_match_etag => 'if-match',
            :if_unmatch_etag => 'if-none-match',
          }.reduce({}) { |h, (k, v)|
            conditions.key?(k)? h.merge(v => conditions[k]) : h
          }
        )
      end

      # Get copy conditions for HTTP headers
      # @param conditions [Hash] the conditions
      # @return [Hash] copy conditions for HTTP headers
      def get_copy_conditions(conditions)
        {
          :if_modified_since => 'x-oss-copy-source-if-modified-since',
          :if_unmodified_since => 'x-oss-copy-source-if-unmodified-since',
        }.reduce({}) { |h, (k, v)|
          conditions.key?(k)? h.merge(v => conditions[k].httpdate) : h
        }.merge(
          {
            :if_match_etag => 'x-oss-copy-source-if-match',
            :if_unmatch_etag => 'x-oss-copy-source-if-none-match',
          }.reduce({}) { |h, (k, v)|
            conditions.key?(k)? h.merge(v => conditions[k]) : h
          }
        )
      end

      # Get bytes range
      # @param range [Array<Integer>] range
      # @return [String] bytes range for HTTP headers
      def get_bytes_range(range)
        if range &&
           (!range.is_a?(Array) || range.size != 2 ||
            !range.at(0).is_a?(Integer) || !range.at(1).is_a?(Integer))
          fail ClientError, "Range must be an array containing 2 Integers."
        end

        "bytes=#{range.at(0)}-#{range.at(1) - 1}"
      end

      # Update values for keys that exist in hash
      # @param hash [Hash] the hash to be updated
      # @param kv [Hash] keys & blocks to updated
      def update_if_exists(hash, kv)
        kv.each { |k, v| hash[k] = v.call(hash[k]) if hash.key?(k) }
      end

      # Convert hash keys to lower case Non-Recursively
      # @param hash [Hash] the hash to be converted
      # @return [Hash] hash with lower case keys
      def to_lower_case(hash)
        hash.reduce({}) do |result, (k, v)|
          result[k.to_s.downcase] = v
          result
        end
      end
    end
  end
end
