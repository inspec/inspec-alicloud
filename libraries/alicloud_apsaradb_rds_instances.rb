require 'alicloud_backend'

class AliCloudApsaradbRdsInstances < AliCloudResourceBase
  name 'alicloud_apsaradb_rds_instances'
  desc 'Verifies settings for ApsaraDB RDS instances in bulk.'
  example <<-EXAMPLE
    describe alicloud_apsaradb_rds_instances do
      it { should exist }
      its('entries.count') { should be > 1 }
    end

    # Iterate through all instances and checking the properties
    alicloud_apsaradb_rds_instances.db_instance_ids.each do |db_instance_id|
      describe alicloud_apsaradb_rds_instance(db_instance_id) do
        its('engine') { should eq 'MySQL' }
        its('engine_version') { should eq '8.0' }
      end
    end
  EXAMPLE

  attr_reader :table

  FilterTable.create
             .register_column(:db_instance_ids, field: :db_instance_id)
             .register_column(:descriptions, field: :description)
             .register_column(:resource_groups, field: :resource_group)
             .register_column(:net_types, field: :net_type)
             .register_column(:instance_types, field: :instance_type)
             .register_column(:multiple_zone_deployments, field: :multiple_zone_deployment)
             .register_column(:network_types, field: :network_type)
             .register_column(:read_only_instance_ids, field: :read_only_instance_list)
             .register_column(:engines, field: :engine)
             .register_column(:engine_versions, field: :engine_version)
             .register_column(:statuses, field: :status)
             .register_column(:zone_ids, field: :zone_id)
             .register_column(:instance_classes, field: :instance_class)
             .register_column(:create_times, field: :create_time)
             .register_column(:vswitch_ids, field: :vswitch_id)
             .register_column(:pay_types, field: :pay_type)
             .register_column(:lock_modes, field: :lock_mode)
             .register_column(:storage_types, field: :storage_type)
             .register_column(:vpc_ids, field: :vpc_id)
             .register_column(:connection_modes, field: :connection_mode)
             .register_column(:vpc_cloud_instance_ids, field: :vpc_cloud_instance_id)
             .register_column(:region_ids, field: :region_id)
             .register_column(:expire_times, field: :expire_time)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters

    total_records_returned = 0
    rds_instance_rows = []
    loop do
      @api_response = fetch_data(opts)
      return [] if !@api_response || @api_response.empty?

      total_record_count = @api_response['TotalRecordCount']
      page_record_count = @api_response['PageRecordCount']
      total_records_returned += page_record_count

      @api_response['Items']['DBInstance'].each do |rds_instance|
        rds_instance_rows += [{
          db_instance_id: rds_instance['DBInstanceId'],
          description: rds_instance['DBInstanceDescription'],
          resource_group: rds_instance['ResourceGroupId'],
          net_type: rds_instance['DBInstanceNetType'],
          instance_type: rds_instance['DBInstanceType'],
          multiple_zone_deployment: rds_instance['MutriORsignle'],
          network_type: rds_instance['InstanceNetworkType'],
          read_only_instance_list: rds_instance['ReadOnlyDBInstanceIds']['ReadOnlyDBInstanceId'],
          engine: rds_instance['Engine'],
          engine_version: rds_instance['EngineVersion'],
          status: rds_instance['DBInstanceStatus'],
          zone_id: rds_instance['ZoneId'],
          instance_class: rds_instance['DBInstanceClass'],
          create_time: rds_instance['CreateTime'],
          vswitch_id: rds_instance['VSwitchId'],
          pay_type: rds_instance['PayType'],
          lock_mode: rds_instance['LockMode'],
          storage_type: rds_instance['DBInstanceStorageType'],
          vpc_id: rds_instance['VpcId'],
          connection_mode: rds_instance['ConnectionMode'],
          vpc_cloud_instance_id: rds_instance['VpcCloudInstanceId'],
          region_id: rds_instance['RegionId'],
          expire_time: rds_instance['ExpireTime'],
        }]
      end

      break if total_records_returned == total_record_count
    end
    @table = rds_instance_rows
  end

  def fetch_data(opts)
    catch_alicloud_errors do
      resp = @alicloud.rds_client.request(
        action: 'DescribeDBInstances',
        params: {
          RegionId: opts[:region],
        },
        opts: {
          method: 'POST',
        },
      )
      return resp
    end
  end
end
