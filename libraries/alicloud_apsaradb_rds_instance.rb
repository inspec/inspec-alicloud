require 'alicloud_backend'

class AliCloudApsaradbRdsInstance < AliCloudResourceBase
  name 'alicloud_apsaradb_rds_instance'
  desc 'Verifies settings for an ApsaraDB RDS instance.'
  example <<-EXAMPLE
    describe alicloud_apsaradb_rds_instance(db_instance_id: 'test-db-instance-id') do
      it { should exist }
      its ('engine') { should eq 'MySQL' }
      its ('engine_version') { should eq '8.0' }
      its ('allocated_storage') { should cmp 20 }
      its ('net_type') { should eq 'Intranet' }
      its ('in_default_vpc') { should be false }
      its ('security_ips') { should_not include '0.0.0.0/0' }
      its ('pay_type') { should eq 'Postpaid' }
    end
  EXAMPLE

  attr_reader :instance_id, :description, :instance_type, :category, :engine, :engine_version,
              :allocated_storage, :storage_type, :memory, :cpus, :instance_class, :pay_type, :status,
              :network_type, :net_type, :vpc_id, :in_default_vpc, :zone_id, :security_ips, :security_ip_mode

  def initialize(opts = {})
    opts = { db_instance_id: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: [:db_instance_id])

    @instance_id = opts[:db_instance_id]

    @rds_instance = fetch_db_info(opts)
    return if @rds_instance.nil?

    @description       = @rds_instance['DBInstanceDescription']
    @instance_type     = @rds_instance['DBInstanceType'] # Primary/Readonly/Guard/Temp
    @category          = @rds_instance['Category'] # Basic/HighAvailability/AlwaysOn/Finance
    @engine            = @rds_instance['Engine']
    @engine_version    = @rds_instance['EngineVersion']
    @allocated_storage = @rds_instance['DBInstanceStorage']
    @storage_type      = @rds_instance['DBInstanceStorageType']
    @memory            = @rds_instance['DBInstanceMemory']
    @cpus              = @rds_instance['DBInstanceCPU'].to_i
    @instance_class    = @rds_instance['DBInstanceClass']
    @pay_type          = @rds_instance['PayType']
    @status            = @rds_instance['DBInstanceStatus'] # Running
    @network_type      = @rds_instance['InstanceNetworkType'] # Classic/VPC
    @net_type          = @rds_instance['DBInstanceNetType'] # Internet / Intranet
    @vpc_id            = @rds_instance['VpcId']
    @zone_id           = @rds_instance['ZoneId']
    @security_ips      = @rds_instance['SecurityIPList']
    @security_ip_mode  = @rds_instance['SecurityIPMode'] # normal (standard whitelist mode)/safety (enhanced whitelist mode)

    opts[:vpc_id] = @vpc_id
    vpc_info = fetch_vpc_info(opts)
    @in_default_vpc = vpc_info['IsDefault']
  end

  def fetch_db_info(opts)
    catch_alicloud_errors('InvalidDBInstanceId.NotFound') do
      resp = @alicloud.rds_client.request(
        action: 'DescribeDBInstanceAttribute',
        params: {
          RegionId: opts[:region],
          DBInstanceId: opts[:db_instance_id],
        },
        opts: {
          method: 'POST',
        },
      )['Items']['DBInstanceAttribute'][0]
      return resp
    end
  end

  def fetch_vpc_info(opts)
    catch_alicloud_errors do
      resp = @alicloud.vpc_client.request(
        action: 'DescribeVpcAttribute',
        params: {
          'RegionId': opts[:region],
          'VpcId': opts[:vpc_id],
        },
      )
      return resp
    end
  end

  def exists?
    !@rds_instance.nil? && !@rds_instance.empty?
  end

  def resource_id
    @instance_id
  end

  def to_s
    d = "RDS Instance ID: #{@instance_id}"
    @description ? d + " Description: #{@description}" : d
  end
end
