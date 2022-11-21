require 'alicloud_backend'

class AliCloudECSInstance < AliCloudResourceBase
  name 'alicloud_ecs_instance'
  desc 'Verifies settings for an individual ECS instance.'
  example <<-EXAMPLE
    # Verify an instance exists
    describe alicloud_ecs_instance(instance_id: 'INSTANCE_ID') do
      it { should exist }
    end
  EXAMPLE

  attr_reader :instance_id, :description, :memory, :instance_charge_type, :cpu, :instance_network_type, :public_ip_address,
              :inner_ip_address, :expired_time, :image_id, :eip_address, :instance_type, :host_name, :vlan_id, :status,
              :io_optimized, :zone_id, :cluster_id, :stopped_mode, :dedicated_host_attribute, :security_group_ids,
              :vpc_attributes, :operation_locks, :internet_charge_type, :instance_name, :internet_max_bandwidth_out,
              :internet_max_bandwidth_in, :serial_number, :creation_time, :region_id, :credit_specification,
              :deletion_protection, :ram_roles

  def initialize(opts = {})
    opts = { instance_id: opts } if opts.is_a?(String)
    opts[:instance_id] = opts.delete(:id) if opts.key?(:id) # id is an alias for group_id
    @opts = opts
    super(opts)
    validate_parameters(required: %i(instance_id region))

    @instance = fetch_instance(opts)['Instances']['Instance'].first
    return if @instance.nil?

    @deletion_protection = @instance['DeletionProtection']

    @ram_roles = fetch_instance_ram_roles(opts)

    @instance_attributes = fetch_instance_attributes(opts)
    return if @instance_attributes.nil?

    @description                = @instance_attributes['Description']
    @memory                     = @instance_attributes['Memory']
    @instance_charge_type       = @instance_attributes['InstanceChargeType']
    @cpu                        = @instance_attributes['Cpu']
    @instance_network_type      = @instance_attributes['InstanceNetworkType']
    @public_ip_address          = @instance_attributes['PublicIpAddress']['IpAddress']
    @inner_ip_address           = @instance_attributes['InnerIpAddress']['IpAddress']
    @expired_time               = @instance_attributes['ExpiredTime']
    @image_id                   = @instance_attributes['ImageId']
    @eip_address                = @instance_attributes['EipAddress']
    @instance_type              = @instance_attributes['InstanceType']
    @host_name                  = @instance_attributes['HostName']
    @vlan_id                    = @instance_attributes['VlanId']
    @status                     = @instance_attributes['Status']
    @io_optimized               = @instance_attributes['IoOptimized']
    @zone_id                    = @instance_attributes['ZoneId']
    @instance_id                = @instance_attributes['InstanceId']
    @cluster_id                 = @instance_attributes['ClusterId']
    @stopped_mode               = @instance_attributes['StoppedMode']
    @dedicated_host_attribute   = @instance_attributes['DedicatedHostAttribute']
    @security_group_ids         = @instance_attributes['SecurityGroupIds']
    @vpc_attributes             = @instance_attributes['VpcAttributes']
    @operation_locks            = @instance_attributes['OperationLocks']
    @internet_charge_type       = @instance_attributes['InternetChargeType']
    @instance_name              = @instance_attributes['InstanceName']
    @internet_max_bandwidth_out = @instance_attributes['InternetMaxBandwidthOut']
    @internet_max_bandwidth_in  = @instance_attributes['InternetMaxBandwidthIn']
    @serial_number              = @instance_attributes['SerialNumber']
    @creation_time              = @instance_attributes['CreationTime']
    @region_id                  = @instance_attributes['RegionId']
    @credit_specification       = @instance_attributes['CreditSpecification']
  end

  def fetch_instance(opts)
    catch_alicloud_errors do
      resp = @alicloud.ecs_client.request(
        action: 'DescribeInstances',
        params: {
          'RegionId': opts[:region],
          'InstanceIds': "[\"#{opts[:instance_id]}\"]",
        },
        opts: {
          method: 'POST',
        },
      )
      return resp
    end
  end

  def fetch_instance_attributes(opts)
    catch_alicloud_errors do
      resp = @alicloud.ecs_client.request(
        action: 'DescribeInstanceAttribute',
        params: {
          'RegionId': opts[:region],
          'InstanceId': opts[:instance_id],
        },
        opts: {
          method: 'POST',
        },
      )
      return resp
    end
  end

  def fetch_instance_ram_roles(opts)
    catch_alicloud_errors do
      resp = @alicloud.ecs_client.request(
        action: 'DescribeInstanceRamRole',
        params: {
          RegionId: opts[:region],
          InstanceIds: "[\"#{opts[:instance_id]}\"]",
        },
        opts: {
          method: 'POST',
        },
      )['InstanceRamRoleSets']['InstanceRamRoleSet'].map { |r| r['RamRoleName'] }
      return resp
    end
  end

  def exists?
    !@instance.nil? && !@instance.empty?
  end

  def resource_id
    @opts ? @opts[:instance_id] : ''
  end

  def to_s
    "ECS Instance #{@opts[:instance_id]}"
  end
end
