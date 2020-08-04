require 'alicloud_backend'

class AliCloudECSInstance < AliCloudResourceBase
    name 'alicloud_ecs_instance'
    desc 'Verifies settings for an individual ecs instance'

    example ''

    attr_reader :description, :memory, :instance_charge_type, :cpu, :instance_network_type, :public_ip_address,
                :inner_ip_address, :expired_time, :image_id, :eip_address, :instance_type, :host_name, :vlan_id,
                :status, :io_optimized, :request_id, :zone_id, :instance_id, :cluster_id, :stopped_mode, 
                :dedicated_host_attribute, :security_group_ids, :vpc_attributes, :operation_locks, :internet_charge_type,
                :instance_name, :internet_max_bandwidth_out, :internet_max_bandwidth_in, :serial_number, :creation_time,
                :region_id, :credit_specification, :instance_id

    def initialize(opts = {})
    opts = { instance_id: opts } if opts.is_a?(String)
    opts[:instance_id] = opts.delete(:id) if opts.key?(:id) # id is an alias for group_id
    super(opts)
    validate_parameters(required: %i(instance_id))

    catch_alicloud_errors do
      @resp = @alicloud.ecs_client.request(
        action: 'DescribeInstanceAttribute',
        params: {
          'RegionId': opts[:region],
          'InstanceId': [opts[:instance_id]],
        },
       opts: {
         method: 'POST',
       },
      )

    if @resp.nil?
      @instance_id = 'empty response'
      return
    end

    @instance_description     = @resp
    @description              = @resp['Description']
    @memory                   = @resp['Memory']
    @instance_charge_type     = @resp['InstanceChargeType']
    @cpu                      = @resp['Cpu']
    @instance_network_type    = @resp['InstanceNetworkType']
    @public_ip_address        = @resp['PublicIpAddress']['IpAddress']
    @inner_ip_address         = @resp['InnerIpAddress']['IpAddress']
    @expired_time             = @resp['ExpiredTime']
    @image_id                 = @resp['ImageId']
    @eip_address              = @resp['EipAddress']
    @instance_type            = @resp['InstanceType']
    @host_name                = @resp['HostName']
    @vlan_id                  = @resp['VlanId']
    @status                   = @resp['Status']
    @io_optimized             = @resp['IoOptimized']
    @request_id               = @resp['RequestId']
    @zone_id                  = @resp['ZoneId']
    @instance_id              = @resp['InstanceId']
    @cluster_id               = @resp['ClusterId']
    @stopped_mode             = @resp['StoppedMode']
    @dedicated_host_attribute = @resp['DedicatedHostAttribute']
    @security_group_ids       = @resp['SecurityGroupIds']
    @vpc_attributes           = @resp['VpcAttributes']
    @operation_locks          = @resp['OperationLocks']
    @internet_charge_type     = @resp['InternetChargeType']
    @instance_name            = @resp['InstanceName']
    @internet_max_bandwidth_out = @resp['InternetMaxBandwidthOut']
    @internet_max_bandwidth_in  = @resp['InternetMaxBandwidthIn']
    @serial_number            = @resp['SerialNumber']
    @creation_time            = @resp['CreationTime']
    @region_id                = @resp['RegionId']
    @credit_specification     = @resp['CreditSpecification']

    end
  end
end