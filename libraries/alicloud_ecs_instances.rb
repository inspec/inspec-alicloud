# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudECSInstances < AliCloudResourceBase
  name 'alicloud_ecs_instances'
  desc 'Verifies settings for AliCloud instances in bulk'
  example "
  # verify more than 1 instance exists
  describe alicloud_ecs_instances do
    its('entries.count') { should be > 1 }
  end
  "

  attr_reader :table

  FilterTable.create
             .register_column(:instance_ids, field: :instance_id)
             .register_column(:instance_names, field: :instance_name)
             .register_column(:host_names, field: :host_name)
             .register_column(:descriptions, field: :description)
             .register_column(:memory, field: :memory)
             .register_column(:instance_charge_types, field: :instance_charge_type)
             .register_column(:cpus, field: :cpu)
             .register_column(:os_names, field: :os_name)
             .register_column(:instance_network_types, field: :instance_network_type)
             .register_column(:inner_ip_addresses, field: :inner_ip_address)
             .register_column(:expired_times, field: :expired_time)
             .register_column(:image_ids, field: :image_id)
             .register_column(:eip_addresses, field: :eip_address)
             .register_column(:vlan_ids, field: :vlan_id)
             .register_column(:statuses, field: :status)
             .register_column(:io_optimized, field: :io_optimized)
             .register_column(:metadata_options, field: :metadata_options)
             .register_column(:zone_ids, field: :zone_id)
             .register_column(:cluster_ids, field: :cluster_id)
             .register_column(:stopped_modes, field: :stopped_mode)
             .register_column(:cpu_options, field: :cpu_options)
             .register_column(:start_times, field: :start_time)
             .register_column(:security_group_ids, field: :security_group_ids)
             .register_column(:vpc_attributes, field: :vpc_attributes)
             .register_column(:internet_charge_types, field: :internet_charge_type)
             .register_column(:deployment_set_ids, field: :deployment_set_id)
             .register_column(:internet_max_bandwidth_out, field: :internet_max_bandwidth_out)
             .register_column(:internet_max_bandwidth_in, field: :internet_max_bandwidth_in)
             .register_column(:serial_numbers, field: :serial_number)
             .register_column(:os_types, field: :os_type)
             .register_column(:creation_times, field: :creation_time)
             .register_column(:auto_release_times, field: :auto_release_time)
             .register_column(:instance_type_families, field: :instance_type_family)
             .register_column(:dedicated_instance_attributes, field: :dedicated_instance_attribute)
             .register_column(:public_ip_addresses, field: :public_ip_address)
             .register_column(:gpu_specs, field: :gpu_spec)
             .register_column(:network_interfaces, field: :network_interfaces)
             .register_column(:spot_price_limits, field: :spot_price_limit)
             .register_column(:devices_available, field: :device_available)
             .register_column(:sale_cycles, field: :sale_cycle)
             .register_column(:instance_types, field: :instance_type)
             .register_column(:os_names_en, field: :os_names_en)
             .register_column(:spot_strategies, field: :spot_strategy)
             .register_column(:deletion_protections, field: :deletion_protection)
             .register_column(:ram_roles, field: :ram_role)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(region))

    @instances = fetch_data
    return [] if !@instances || @instances.empty?

    instance_rows = []
    @instances.map do |instance|
      instance_id = instance['InstanceId']

      instance_rows += [{
        instance_id: instance_id,
        instance_name: instance['InstanceName'],
        host_name: instance['HostName'],
        description: instance['Description'],
        memory: instance['Memory'],
        instance_charge_type: instance['InstanceChargeType'],
        cpu: instance['Cpu'],
        os_name: instance['OSName'],
        instance_network_type: instance['InstanceNetworkType'],
        inner_ip_address: instance['InnerIpAddress']['IpAddress'],
        expired_time: instance['ExpiredTime'],
        image_id: instance['ImageId'],
        eip_address: instance['EipAddress'],
        vlan_id: instance['VlanId'],
        status: instance['Status'],
        io_optimized: instance['IoOptimized'],
        metadata_options: instance['MetadataOptions'],
        zone_id: instance['ZoneId'],
        stopped_mode: instance['StoppedMode'],
        cpu_options: instance['CpuOptions'],
        start_time: instance['StartTime'],
        security_group_ids: instance['SecurityGroupIds'],
        vpc_attributes: instance['VpcAttributes'],
        internet_charge_type: instance['InternetChargeType'],
        deployment_set_id: instance['DeploymentSetId'],
        internet_max_bandwidth_out: instance['InternetMaxBandwidthOut'],
        internet_max_bandwidth_in: instance['InternetMaxBandwidthIn'],
        serial_number: instance['SerialNumber'],
        os_type: instance['OSType'],
        creation_time: instance['CreationTime'],
        auto_release_time: instance['AutoReleaseTime'],
        instance_type_family: instance['InstanceTypeFamily'],
        dedicated_instance_attribute: instance['DedicatedInstanceAttribute'],
        public_ip_address: instance['PublicIpAddress'],
        gpu_spec: instance['GPUSpec'],
        network_interfaces: instance['NetworkInterfaces'],
        spot_price_limit: instance['SpotPriceLimit'],
        device_available: instance['DeviceAvailable'],
        sale_cycle: instance['SaleCycle'],
        instance_type: instance['InstanceType'],
        os_names_en: instance['OSNameEn'],
        spot_strategy: instance['SpotStrategy'],
        deletion_protection: instance['DeletionProtection'],
        ram_role: fetch_instance_ram_roles(opts[:region], instance_id),
      }]
    end

    @table = instance_rows
  end

  def fetch_data
    catch_alicloud_errors do
      resp = @alicloud.ecs_client.request(
        action: 'DescribeInstances',
        params: {
          'RegionId': opts[:region],
        },
      )['Instances']['Instance']
      return resp
    end
  end

  def fetch_instance_ram_roles(region, instance_id)
    catch_alicloud_errors do
      resp = @alicloud.ecs_client.request(
        action: 'DescribeInstanceRamRole',
        params: {
          RegionId: region,
          InstanceIds: [instance_id].to_json,
        },
        opts: {
          method: 'POST',
        },
      )['InstanceRamRoleSets']['InstanceRamRoleSet'].map { |r| r['RamRoleName'] }
      return resp
    end
  end

  def exists?
    !@table.nil? && !@table.empty?
  end

  def to_s
    'AliCloud ECS Instances (All)'
  end
end
