# -*- encoding: utf-8 -*-
require 'alicloud/oss/protocol'
require 'alicloud/oss/util'
require 'alicloud/oss/bucket'

module AliCloud
  module OSS
    class Client
      def initialize(opts)
        raise ClientError, "Endpoint must be provided" unless opts[:endpoint]
        @config = Config.new(opts)
        @protocol = Protocol.new(@config)
      end

      def get_bucket(name)
        Util.ensure_bucket_name_valid(name)
        Bucket.new({ name: name }, @protocol)
      end
    end
  end
end
