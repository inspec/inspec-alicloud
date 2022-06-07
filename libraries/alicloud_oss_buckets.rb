# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudOssBuckets < AliCloudResourceBase
  name 'alicloud_oss_buckets'
  desc 'Verifies settings for AliCloud OSS Buckets in bulk'
  example "
    describe alicloud_oss_buckets do
      its('bucket_names') { should eq ['my_bucket'] }
    end
  "

  attr_reader :table

  FilterTable.create
             .register_column(:bucket_names, field: :bucket_name)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i[region])
    @table = fetch_data
  end

  def fetch_data
    bucket_rows = []
    catch_alicloud_errors do
      @api_response = @alicloud.oss_client.list_buckets
    end
    @api_response.each do |bucket|
      bucket_rows += [{ bucket_name: bucket.name }]
    end
    @table = bucket_rows
  end
end
