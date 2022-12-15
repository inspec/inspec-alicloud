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
      CALLBACK_HEADER = 'x-oss-callback'.freeze

      include Aliyun::Common::Logging

      def initialize(config)
        @config = config
        @http = HTTP.new(config)
      end

      def get_bucket_tagging(name)
        logger.info("Begin get bucket tagging, name: #{name}")

        sub_res = { 'tagging' => nil }
        r = @http.get({ bucket: name, sub_res: sub_res })
        doc = parse_xml(r.body)
        opts = {
          key: get_node_text(doc.at_css("Tagging TagSet Tag"), "Key"),
          value: get_node_text(doc.at_css("Tagging TagSet Tag"), "Value"),
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
          raise ClientError, "Unsupported key encoding: #{encoding}"
        end

        if encoding == KeyEncoding::URL
          CGI.unescape(key)
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
          if_modified_since: 'if-modified-since',
          if_unmodified_since: 'if-unmodified-since',
        }.reduce({}) { |h, (k, v)|
          conditions.key?(k)? h.merge(v => conditions[k].httpdate) : h
        }.merge(
          {
            if_match_etag: 'if-match',
            if_unmatch_etag: 'if-none-match',
          }.reduce({}) { |h, (k, v)|
            conditions.key?(k)? h.merge(v => conditions[k]) : h
          },
        )
      end

      # Get copy conditions for HTTP headers
      # @param conditions [Hash] the conditions
      # @return [Hash] copy conditions for HTTP headers
      def get_copy_conditions(conditions)
        {
          if_modified_since: 'x-oss-copy-source-if-modified-since',
          if_unmodified_since: 'x-oss-copy-source-if-unmodified-since',
        }.reduce({}) { |h, (k, v)|
          conditions.key?(k)? h.merge(v => conditions[k].httpdate) : h
        }.merge(
          {
            if_match_etag: 'x-oss-copy-source-if-match',
            if_unmatch_etag: 'x-oss-copy-source-if-none-match',
          }.reduce({}) { |h, (k, v)|
            conditions.key?(k)? h.merge(v => conditions[k]) : h
          },
        )
      end

      # Get bytes range
      # @param range [Array<Integer>] range
      # @return [String] bytes range for HTTP headers
      def get_bytes_range(range)
        if range &&
            (!range.is_a?(Array) || range.size != 2 ||
             !range.at(0).is_a?(Integer) || !range.at(1).is_a?(Integer))
          raise ClientError, "Range must be an array containing 2 Integers."
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
