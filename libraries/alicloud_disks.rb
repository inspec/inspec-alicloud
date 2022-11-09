# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudDisks < AliCloudResourceBase
  name 'alicloud_disks'
  desc 'Verifies settings for AliCloud disks in bulk.'
  example <<-EXAMPLE
    # Verify that you have disks defined
    describe alicloud_disks do
      it { should exist }
    end

    # Verify you have more than 1 disk
    describe alicloud_disks do
      its('entries.count') { should be > 1 }
    end

    # Ensure auto snapshot is turned on for all disks
    describe alicloud_disks.where(enable_auto_snapshot: false) do
      it { should_not exist }
      its('ids') { should cmp [] }
    end
  EXAMPLE

  attr_reader :table

  # FilterTable setup
  FilterTable.create
             .register_column(:ids, field: :id)
             .register_column(:names, field: :name)
             .register_column(:descriptions, field: :description)
             .register_column(:sizes, field: :size)
             .register_column(:categories, field: :category)
             .register_column(:encrypted_disks, field: :encrypted)
             .register_column(:kms_key_ids, field: :kms_key_id)
             .register_column(:enable_auto_snapshot, field: :enable_auto_snapshot)
             .register_column(:delete_auto_snapshot, field: :delete_auto_snapshot)
             .register_column(:delete_with_instance, field: :delete_with_instance)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(region))

    @disks = fetch_data
    return [] if !@disks || @disks.empty?

    disk_rows = []
    @disks.map do |disk|
      disk_rows += [{
        id: disk['DiskId'],
        name: disk['DiskName'],
        description: disk['Description'],
        size: disk['Size'],
        category: disk['Category'],
        encrypted: disk['Encrypted'],
        kms_key_id: disk['KMSKeyId'],
        enable_auto_snapshot: disk['EnableAutoSnapshot'],
        delete_auto_snapshot: disk['DeleteAutoSnapshot'],
        delete_with_instance: disk['DeleteWithInstance'],
      }]
    end

    @table = disk_rows
  end

  def fetch_data
    catch_alicloud_errors do
      disks = @alicloud.ecs_client.request(
        action: 'DescribeDisks',
        params: {
          RegionId: opts[:region],
        },
      )['Disks']['Disk']
      return disks
    end
  end
end
