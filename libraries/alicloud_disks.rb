# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudDisks < AliCloudResourceBase
  name 'alicloud_disks'
  desc 'Verifies settings for AliClou disss in bulk'
  example "
    # Verify that you have disks defined
    describe alicloud_disks do
      it { should exist }
    end

    # Verify you have more than the 1 disk
    describe alicloud_disks do
      its('entries.count') { should be > 1 }
    end
  "

  attr_reader :table

  # FilterTable setup
  FilterTable.create
             .register_column(:ids, field: :id)
             .register_column(:descriptions, field: :description)
             .register_column(:names, field: :name)
             .register_column(:encypted_disks, field: :encypted)
             .register_column(:categorys, field: :category)
             .register_column(:kms_key_ids, field: :kms_key_id)
             .register_column(:sizes, field: :sizes)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters
    @table = fetch_data
  end

  def fetch_data
    disk_rows = []
    catch_alicloud_errors do
      @disks = @alicloud.ecs_client.request(
        action: 'DescribeDisks',
        params: {
          'RegionId': opts[:region],
        }
      )['Disks']['Disk']
    end

    return [] if !@disks || @disks.empty?
    @disks.map do |disk|
      disk_rows += [{
        id: disk['DiskId'],
        description: disk['Description'],
        name: disk['DiskName'],
        encrypted: disk['Encrypted'],
        category: disk['Category'],
        kms_key_id: disk['KMSKeyId'],
        size: disk['Size']
      }]
    end

    @table = disk_rows
  end
end
