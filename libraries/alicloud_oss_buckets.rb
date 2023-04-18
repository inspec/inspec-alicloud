require 'alicloud_backend'

class AliCloudOssBuckets < AliCloudResourceBase
  name 'alicloud_oss_buckets'
  desc 'Verifies settings for AliCloud OSS Buckets in bulk.'
  example <<-EXAMPLE
    describe alicloud_oss_buckets do
      its('bucket_names') { should eq ['test-oss-bucket''] }
    end
  EXAMPLE

  attr_reader :table

  FilterTable.create
             .register_column(:bucket_names, field: :bucket_name)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(region))
    @table = fetch_data
  end

  def fetch_data
    catch_alicloud_errors do
      @api_response = @alicloud.oss_client.list_buckets
      @api_response.map { |bucket| { bucket_name: bucket.name } }
    end || []
  end
end
