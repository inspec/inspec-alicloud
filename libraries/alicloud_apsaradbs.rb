require 'alicloud_backend'

class AliCloudApsaraDBs < AliCloudResourceBase
    name 'alicloud_apsaradb_instances'
    desc ' Verifies properties for an ApsaraDB for RDS instance'
    example "" # TODO

    attr_reader :table

    FilterTable.create
        .register_column(:lock_mode, field: :lock_mode)
        .register_column(:db_instance_net_type, field: :db_instance_net_type)
        .register_column(:db_instance_class, field: :db_instance_class)
        .register_column(:resource_group_id, field: :resource_group_id)
        .register_column(:db_instance_id, field: :db_instance_id)
        .register_column(:vpc_cloud_instance_id, field: :vpc_cloud_instance_id)
        .register_column(:zone_id, field: :zone_id)
        .register_column(:read_only_db_instance_ids, field: :read_only_db_instance_ids)
        .register_column(:connection_mode, field: :connection_mode)
        .register_column(:instance_network_type, field: :instance_network_type)
        .register_column(:engine, field: :engine)
        .register_column(:mutri_or_signle, field: :mutri_or_signle)  # TODO check this spelling (potentially wrong in docs)
        .register_column(:ins_id, field: :ins_id)
        .register_column(:expire_time, field: :expire_time)
        .register_column(:create_time, field: :create_time)
        .register_column(:db_instance_type, field: :db_instance_type)
        .register_column(:region_id, field: :region_id)
        .register_column(:engine_version, field: :engine_version)
        .register_column(:lock_reason, field: :lock_reason)
        .register_column(:db_instance_status, field: :db_instance_status)
        .register_column(:pay_type, field: :pay_type)
        .install_filter_methods_on_resource(self, :table)


    def initialize(opts = {})
        opts = { region: opts } if opts.is_a?(String)
        super(opts)
        validate_parameters(required: [:region])
        fetch_data  # sets @table
    end
    
    
    def fetch_data
        catch_alicloud_errors do
            @resp = @alicloud.rds_client.request(
                action: 'DescribeDatabases',
                params: {
                    'RegionId': opts[:region]
                },
                opts: {
                    method: 'POST'
                }
            )
            if @resp.nil?
                @db_instance_id = 'empty response'
                return
            else
                @db_instances = @resp['Items']['DBInstance']
        end
    end

    return [] if !@db_instances || @db_instances.empty?
    db_instance_rows = []
    @db_instances.map do |db_instance|
        db_instance_rows += [{
            lock_mode:                  db_instance['LockMode'],
            db_instance_net_type:       db_instance['DBInstanceNetType'],
            db_instance_class:          db_instance['DBInstanceClass'],
            resource_group_id:          db_instance['ResourceGroupId'],
            db_instance_id:             db_instance['DBInstanceId'],
            vpc_cloud_instance_id:      db_instance['VpcCloudInstanceId'],
            zone_id:                    db_instance['ZoneId'],
            read_only_db_instance_ids:  db_instance['ReadOnlyDBInstanceIds'],
            connection_mode:            db_instance['ConnectionMode'],
            instance_network_type:      db_instance['InstanceNetworkType'],
            engine:                     db_instance['Engine'],
            mutri_or_signle:            db_instance['MutriORsignle'],  # TODO check spelling
            ins_id:                     db_instance['InsId'],
            expire_time:                db_instance['ExpireTime'],
            create_time:                db_instance['CreateTime'],
            db_instance_type:           db_instance['DBInstanceType'],
            region_id:                  db_instance['RegionId'],
            engine_version:             db_instance['EngineVersion'],
            lock_reason:                db_instance['LockReason'],
            db_instance_status:         db_instance['DBInstanceStatus'],
            pay_type:                   db_instance['PayType'],
        }]
    end
    @table = db_instance_rows
  end
end
