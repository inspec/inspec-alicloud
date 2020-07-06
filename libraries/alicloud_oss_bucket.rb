# frozen_string_literal: true

require 'alicloud_backend'
require 'pry-byebug'

class AliCloudOSSBucket < AliCloudResourceBase
  name 'alicloud_oss_bucket'
  desc 'Verifies settings for an AliCloud OSS Bucket'
  example "
    describe alicloud_oss_bucket(bucket_name: 'test_bucket') do
      it { should exist }
    end
  "

  attr_reader :region, :bucket_name

  def initialize(opts = {})
    opts = { bucket_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: [:bucket_name])

    @bucket_name = opts[:bucket_name]

    catch_alicloud_errors do
      @region = @alicloud.oss_client.request(
        action: 'GetBucketLocation',
        params: {
          "BucketName": opts[:bucket_name],
        }
      )

      # Forcing bucket region for future bucket calls to avoid warnings about multiple unnecessary
      # redirects and signing attempts.
      opts[:alicloud_region] = @region.empty? ? 'eu-west-1' : @region
      super(opts)
    end
  end

  def exists?
    !@region.nil?
  end

  def public?
    return false unless exists?
    catch_alicloud_errors do
      @bucket_policy_status_public = @alicloud.oss_client.request(
        action: 'GetBucketAcl',
        params: {
          "BucketName": opts[:bucket_name],
        }
      )['AccessControlList']['Grant'] == 'public-read'
    end
  end

  # def has_access_logging_enabled?
  #   return false unless exists?
  #   catch_alicloud_errors do
  #     @has_access_logging_enabled ||= !@alicloud.oss_client.request(
  #       action: 'GetBucketLogging',
  #       params: {
  #         "BucketName": opts[:bucket_name],
  #       }
  #     )['BucketLoggingStatus']['LoggingEnabled'].nil?
  #   end
  # end

  # def has_default_encryption_enabled?
  #   return false unless exists?
  #   catch_alicloud_errors do
  #     @has_default_encryption_enabled ||= !@alicloud.oss_client.request(
  #       action: 'GetBucketInfo',
  #       params: {
  #         "BucketName": opts[:bucket_name],
  #       }
  #     )['ServerSideEncryptionRule']['ApplyServerSideEncryptionByDefault'].nil?
  #   end
  # end

  # def has_versioning_enabled?
  #   return false unless exists?
  #   catch_alicloud_errors do
  #     @has_versioning_enabled = @alicloud.oss_client.request(
  #       action: 'GetBucketVersioning',
  #         params: {
  #           "BucketName": opts[:bucket_name],
  #         }
  #       )['VersioningConfiguration']['Status'] == 'Enabled'
  #   end
  # end

  # def has_secure_transport_enabled?
  #   bucket_policy.any? { |s| s.effect == 'Deny' && s.condition == { 'Bool' => { 'acs:SecureTransport'=>'false' } } }
  # end

  # # below is to preserve the original 'unsupported' function but isn't used in the above
  # def bucket_policy
  #   @bucket_policy ||= fetch_bucket_policy
  # end

  # def fetch_bucket_policy
  #   policy_list = []
  #   catch_alicloud_errors do
  #     raw_policy = @alicloud.oss_client.request(
  #       action: 'GetBucketPolicy',
  #         params: {
  #           "BucketName": opts[:bucket_name],
  #         }
  #     ).to_h
  #     return [] if !raw_policy.key?(:policy)
  #     JSON.parse(raw_policy[:policy].read)['Statement'].map do |statement|
  #       lowercase_hash = {}
  #       statement.each_key { |k| lowercase_hash[k.downcase] = statement[k] }
  #       policy_list += [OpenStruct.new(lowercase_hash)]
  #     end
  #   end
  #   policy_list
  # end

  # def bucket_lifecycle_rules
  #   rules_list = []
  #   catch_alicloud_errors do
  #     rules_list = @alicloud.oss_client.request(
  #       action: 'GetBucketLifecycle',
  #       params: {
  #         "BucketName": opts[:bucket_name],
  #       }
  #     )['LifecycleConfiguration']
  #   end
  #   rules_list
  # end

  # def tags
  #   tag_list = @alicloud.oss_client.request(
  #     action: 'GetBucketTagging',
  #     params: {
  #       "BucketName": opts[:bucket_name],
  #     }
  #   )['Tagging']['TagSet']
  #   map_tags(tag_list)
  # end

  def to_s
    "OSS Bucket #{@bucket_name}"
  end
end
