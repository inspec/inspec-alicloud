# frozen_string_literal: true

require "alicloud_backend"

class AliCloudECSInstance < AliCloudResourceBase
  name "alicloud_ecs_instance"
  desc "Verifies settings for an individual ecs instance"

  example '
  # verify an instance exists
  describe alicloud_ecs_instance(instance_id: alicloud_instance_id) do
    it { should exist }
  end
  '

  attr_reader :description, :memory, :instance_charge_type, :cpu, :instance_network_type, :public_ip_address,
              :inner_ip_address, :expired_time, :image_id, :eip_address, :instance_type, :host_name, :vlan_id,
              :status, :io_optimized, :request_id, :zone_id, :instance_id, :cluster_id, :stopped_mode,
              :dedicated_host_attribute, :security_group_ids, :vpc_attributes, :operation_locks, :internet_charge_type,
              :instance_name, :internet_max_bandwidth_out, :internet_max_bandwidth_in, :serial_number, :creation_time,
              :region_id, :credit_specification

  # rubocop:disable Metrics/MethodLength
  def initialize(opts = {})
    opts = { instance_id: opts } if opts.is_a?(String)
    opts[:instance_id] = opts.delete(:id) if opts.key?(:id) # id is an alias for group_id
    super(opts)
    validate_parameters(required: %i(instance_id))
    catch_alicloud_errors do
      @resp = @alicloud.ecs_client.request(
        action: "DescribeInstanceAttribute",
        params: {
          'RegionId': opts[:region],
          'InstanceId': opts[:instance_id],
        },
        opts: {
          method: "POST",
        },
      )
      if @resp.nil?
        @instance_id = "empty response"
        return
      end

      @instance                   = @resp
      @description                = @instance["Description"]
      @memory                     = @instance["Memory"]
      @instance_charge_type       = @instance["InstanceChargeType"]
      @cpu                        = @instance["Cpu"]
      @instance_network_type      = @instance["InstanceNetworkType"]
      @public_ip_address          = @instance["PublicIpAddress"]["IpAddress"]
      @inner_ip_address           = @instance["InnerIpAddress"]["IpAddress"]
      @expired_time               = @instance["ExpiredTime"]
      @image_id                   = @instance["ImageId"]
      @eip_address                = @instance["EipAddress"]
      @instance_type              = @instance["InstanceType"]
      @host_name                  = @instance["HostName"]
      @vlan_id                    = @instance["VlanId"]
      @status                     = @instance["Status"]
      @io_optimized               = @instance["IoOptimized"]
      @request_id                 = @instance["RequestId"]
      @zone_id                    = @instance["ZoneId"]
      @instance_id                = @instance["InstanceId"]
      @cluster_id                 = @instance["ClusterId"]
      @stopped_mode               = @instance["StoppedMode"]
      @dedicated_host_attribute   = @instance["DedicatedHostAttribute"]
      @security_group_ids         = @instance["SecurityGroupIds"]
      @vpc_attributes             = @instance["VpcAttributes"]
      @operation_locks            = @instance["OperationLocks"]
      @internet_charge_type       = @instance["InternetChargeType"]
      @instance_name              = @instance["InstanceName"]
      @internet_max_bandwidth_out = @instance["InternetMaxBandwidthOut"]
      @internet_max_bandwidth_in  = @instance["InternetMaxBandwidthIn"]
      @serial_number              = @instance["SerialNumber"]
      @creation_time              = @instance["CreationTime"]
      @region_id                  = @instance["RegionId"]
      @credit_specification       = @instance["CreditSpecification"]
    end
    # rubocop:enable Metrics/MethodLength
  end

  def exists?
    !@instance.nil? && !@instance.empty?
  end

  def to_s
    "ECS Instance #{instance_id}"
  end
end
