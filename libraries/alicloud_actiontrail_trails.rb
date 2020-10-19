# frozen_string_literal: true

require "alicloud_backend"

class AliCloudActionTrailTrails < AliCloudResourceBase
  name "alicloud_actiontrail_trails"
  desc "Verifies settings for AliCloud Audit Trails in bulk"
  example '
    describe alicloud_actiontrail_trails do
      it { should exist }
    end
  '

  attr_reader :table

  def initialize(opts = {})
    # Call the parent class constructor
    super(opts)
    validate_parameters
    @table = fetch_data
  end

  FilterTable.create
    .register_column(:names,               field: :name)
    .register_column(:oss_bucket_names,    field: :oss_bucket_name)
    .register_column(:oss_key_prefixes,    field: :oss_key_prefix)
    .register_column(:role_names,          field: :role_name)
    .register_column(:sls_project_arns,    field: :sls_project_arn)
    .register_column(:sls_write_role_arns, field: :sls_write_role_arn)
    .install_filter_methods_on_resource(self, :table)

  def fetch_data
    actiontrail_rows = []
    catch_alicloud_errors do
      @actiontrails = @alicloud.actiontrail_client.request(
        action: "DescribeTrails",
        params: {
          "RegionId": opts[:region],
        },
      )["TrailList"]
    end
    return [] if !@actiontrails || @actiontrails.empty?
    @actiontrails.each do |actiontrail|
      actiontrail_rows += [{ name: actiontrail["Name"],
                             oss_bucket_name: actiontrail["OssBucketName"],
                             oss_key_prefix: actiontrail["OssKeyPrefix"],
                             role_name: actiontrail["RoleName"],
                             sls_project_arn: actiontrail["SlsProjectArn"],
                             sls_write_role_arn: actiontrail["SlsWriteRoleArn"] }]
    end
    @table = actiontrail_rows
  end
end
