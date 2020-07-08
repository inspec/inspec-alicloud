# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudActionTrailTrail < AliCloudResourceBase
  name 'alicloud_actiontrail_trail'
  desc 'Verifies settings for an individual AliCloud ActionTrail'

  example "
    describe alicloud_actiontrail_trail('trail-name') do
      it { should exist }
    end
  "
  attr_reader :trail_name, :oss_bucket_name, :oss_key_prefix, :role_name, :sls_project_arn, :sls_write_role_arn

  def initialize(opts = {})
    opts = { trail_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: [:trail_name])

    @trail_name = opts[:trail_name]
    catch_alicloud_errors do
      resp = @alicloud.actiontrail_client.request(
        action: 'DescribeTrails',
        params: {
          "RegionId": opts[:region],
          "NameList": @trail_name,
        }
      )['TrailList']

      if resp.empty?
        @trail_name = 'empty response'
        return
      end

      @trail = resp.first
      @oss_bucket_name = @trail['OssBucketName']
      @oss_key_prefix = @trail['OssKeyPrefix']
      @role_name = @trail['RoleName']
      @sls_project_arn = @trail['SlsProjectArn']
      @sls_write_role_arn = @trail['SlsWriteRoleArn']
    end
  end

  def delivered_logs_days_ago
    return nil unless exists?
    catch_alicloud_errors do
      trail_status = @alicloud.actiontrail_client.request(
        action: 'GetTrailStatus',
        params: {
          "RegionId": opts[:region],
          "Name": @trail_name,
        }
      )
      # LatestDeliveryTime is unix time with milliseconds
      # Subtract two datetime objects for difference in days
      # May not exist if no logs have been delivered yet
      (DateTime.now - DateTime.strptime(trail_status['LatestDeliveryTime'].to_s, '%Q')).to_i if trail_status['LatestDeliveryTime']
    end
  end

  def logging?
    return nil unless exists?
    catch_alicloud_errors do
      trail_status = @alicloud.actiontrail_client.request(
        action: 'GetTrailStatus',
        params: {
          "RegionId": opts[:region],
          "Name": @trail_name,
        }
      )
      trail_status['IsLogging']
    end
  end

  def exists?
    !@trail.nil? && !@trail.empty?
  end

  def to_s
    "ActionTrail #{@trail_name}"
  end
end
