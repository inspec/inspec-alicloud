# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudStsCallerIdentity < AliCloudResourceBase
  name 'alicloud_sts_caller_identity'
  desc 'Verifies settings for an AliCloud STS Caller Identity.'
  example <<-EXAMPLE
    describe alicloud_sts_caller_identity do
      its("arn") { should match "acs:ram::.*:user/service-account-inspec" }
    end
  EXAMPLE

  attr_reader :arn

  def initialize(opts = {})
    super(opts)
    validate_parameters

    catch_alicloud_errors do
      @arn = @alicloud.sts_client.request(action: 'GetCallerIdentity')['Arn']
    end
  end

  def resource_id
    @arn
  end

  def exists?
    !@arn.nil?
  end

  def to_s
    'AliCloud Security Token Service Caller Identity'
  end
end
