require 'alicloud_backend'
require 'alicloud/oss/bucket'
class AliCloudOssBucket < AliCloudResourceBase
  name 'alicloud_oss_bucket'
  desc 'Verifies settings for an AliCloud OSS Bucket.'
  example <<-EXAMPLE
    describe alicloud_oss_bucket(bucket_name: 'test-oss-bucket') do
      it { should exist }
    end
  EXAMPLE

  attr_reader :region, :bucket_name

  def initialize(opts = {})
    opts = { bucket_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: %i(bucket_name region))

    @bucket_name = opts[:bucket_name]

    # catch_alicloud_errors do
    #   @bucket = @alicloud.aliyun_oss_client.get_bucket(opts[:bucket_name])
    # end

    catch_alicloud_errors do
      @bucket = @alicloud.aliyun_oss_client_custom.get_bucket(opts[:bucket_name])
      require 'pry';binding.pry
      @bucket.tagging
    end
  end

  def exists?
    # @bucket object itself will not be nil if the bucket doesn't exist
    # need to check some property of the bucket and rescue the Bucket doesn't exist error

    @bucket.acl
    true
  rescue Aliyun::OSS::ServerError
    false
  end

  def public?
    return false unless exists?

    catch_alicloud_errors do
      @bucket_policy_status_public ||= @bucket.acl != 'private'
    end
  end

  def has_access_logging_enabled?
    return false unless exists?

    catch_alicloud_errors do
      @has_access_logging_enabled ||= @bucket.logging.enable == true
    end
  end

  def has_default_encryption_enabled?
    return false unless exists?

    @has_default_encryption_enabled ||= catch_alicloud_errors do
      @has_default_encryption_enabled = !@bucket.encryption.sse_algorithm.nil?
    rescue Aliyun::OSS::ServerError
      false
    rescue StandardError => e
      fail_resource("Unexpected error thrown: #{e}")
    end
  end

  def has_versioning_enabled?
    return false unless exists?

    catch_alicloud_errors do
      @has_versioning_enabled ||= @bucket.versioning.status == 'Enabled'
    end
  end

  def has_website_enabled?
    return false unless exists?

    catch_alicloud_errors do
      @has_website_enabled ||= @bucket.website.enable == true
    end
  end

  def bucket_lifecycle_rules
    return false unless exists?

    catch_alicloud_errors do
      @bucket_lifecycle_rules ||= @bucket.lifecycle
    end
  end

  def resource_id
    @bucket ? @bucket.name : @bucket_name
  end

  def to_s
    "OSS Bucket #{@bucket_name}"
  end
end
