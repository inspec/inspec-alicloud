# -*- encoding: utf-8 -*-

require 'base64'
require 'json'
require 'uri'

module AliCloud
  module OSS
    class BucketTagging < Common::Struct::Base
      attrs :key, :value
    end

  end
end
