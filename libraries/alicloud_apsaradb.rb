require 'alicloud_backend'

class AliCloudApsaraDB < AliCloudResourceBase
    name 'alicloud_apsaradb_instance'
    desc ' Verifies properties for an ApsaraDB for RDS instance'
    example "" # TODO

    attr_reader     :lock_mode,
                    :db_instance_net_type,
                    :db_instance_class,
                    :resource_group_id,
                    :vpc_cloud_instance_id,
                    :zone_id,
                    :read_only_db_instance_ids,
                    :connection_mode,
                    :instance_network_type,
                    :engine,
                    :mutri_or_signle,
                    :ins_id,
                    :expire_time,
                    :create_time,
                    :db_instance_type,
                    :region_id,
                    :engine_version,
                    :lock_reason,
                    :db_instance_status,
                    :pay_type

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: [:region, :db_instance_id])

    catch_alicloud_errors do
        @resp = @alicloud.rds_client.request(
          action: 'DescribeDBInstances',
          params: {
            'RegionId': opts[:region],
            'DBInstanceId': opts[:db_instance_id],
          },
        )
      end

      @db_info                      = @resp['Databases']['DBInstance'][0]  # should warn if list length > 1
      @db_instance_id               = @db_info['DBInstanceId']  # should be the same as the id supplied in opts
      @lock_mode                    = @db_info['LockMode']
      @db_instance_net_type         = @db_info['DBInstanceNetType']
      @db_instance_class            = @db_info['DBInstanceClass']
      @resource_group_id            = @db_info['ResourceGroupId']
      @vpc_cloud_instance_id        = @db_info['VpcCloudInstanceId']
      @zone_id                      = @db_info['ZoneId']
      @read_only_db_instance_ids    = @db_info['ReadOnlyDBInstanceIds']
      @connection_mode              = @db_info['ConnectionMode']
      @instance_network_type        = @db_info['InstanceNetworkType']
      @engine                       = @db_info['Engine']
      @mutri_or_signle              = @db_info['MutriORsignle']  # TODO check spelling
      @ins_id                       = @db_info['InsId']
      @expire_time                  = @db_info['ExpireTime']
      @create_time                  = @db_info['CreateTime']
      @db_instance_type             = @db_info['DBInstanceType']
      @region_id                    = @db_info['RegionId']
      @engine_version               = @db_info['EngineVersion']
      @lock_reason                  = @db_info['LockReason']
      @db_instance_status           = @db_info['DBInstanceStatus']
      @pay_type                     = @db_info['PayType']
  end
end
