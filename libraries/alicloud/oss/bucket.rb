# -*- encoding: utf-8 -*-
require 'alicloud/common/struct'
require 'alicloud/oss/protocol'

module AliCloud
  module OSS

    class Bucket < Common::Struct::Base

      attrs :name, :location, :creation_time

      def initialize(opts = {}, protocol = nil)
        super(opts)
        @protocol = protocol
      end

      def tagging
        @protocol.get_bucket_tagging(name)
      end
    end
  end
end