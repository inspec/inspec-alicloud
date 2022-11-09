# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudOssBucketTag < AliCloudResourceBase
  name 'alicloud_oss_bucket_tag'
  desc 'Verifies settings for an AliCloud OSS Bucket Tags.'
  example <<-EXAMPLE
    describe alicloud_oss_bucket_tag(bucket_name: 'test_bucket') do
      it { should exist }
    end

    describe alicloud_oss_bucket_tag(bucket_name: 'soumyo') do
      it { should exist }
    end
  EXAMPLE

  attr_reader :bucket_name

  def initialize(opts = {})
    opts = { bucket_name: opts } if opts.is_a?(String)
    @opts = opts
    super(opts)
    validate_parameters(required: %i(bucket_name))

    catch_alicloud_errors do
      require 'pry'
      binding.pry
      @resp = @alicloud.oss_client.request(
        action: 'GetBucketTagging',
        params: {
          # acs:oss:*:{#accountId}:{#BucketName}
          "BucketName": opts[:bucket_name],
        },
      )
    end
  end

  # "accountId": "https://oss-#{opts[:region]}.aliyuncs.com",
  # acs:ecs:{#regionId}:{#accountId}:securitygroup/{#securitygroupId}
  # acs:oss:*:{#accountId}:{#BucketName}
  # AliCloudSecurityGroup

  # def exists?
  #   !failed_resource?
  # end

  def to_s
    "Bucket Name: #{opts[:bucket_name]}"
  end
end
