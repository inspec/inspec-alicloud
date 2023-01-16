require 'helper'
require 'alicloud_ecs_instances'

class AliCloudECSInstancesConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'eu-west-1'

    AliCloudECSInstances.any_instance.stubs(:fetch_data).returns([{ 'ResourceGroupId' => 'rg-12345', 'Memory' => 8192,
                                                                    'InstanceChargeType' => 'PostPaid', 'Cpu' => 2, 'OSName' => 'Ubuntu 18.04', 'InstanceNetworkType' => 'vpc',
                                                                    'InnerIpAddress' => { 'IpAddress' => [] }, 'ExpiredTime' => '2099-12-31T15:59Z',
                                                                    'ImageId' => 'ubuntu_18_04_64_20G_alibase_20190624.vhd', 'EipAddress' => { 'AllocationId' => '',
                                                                                                                                               'IpAddress' => '101.101.101.101', 'InternetChargeType' => '' }, 'HostName' => 'host-01', 'VlanId' => '', 'Status' => 'Running',
                                                                    'MetadataOptions' => { 'HttpTokens' => 'optimal', 'HttpEndpoint' => '' }, 'InstanceId' => 'i-id1234',
                                                                    'StoppedMode' => 'Not-applicable', 'CpuOptions' => { 'ThreadsPerCore' => 2, 'Numa' => 'ON', 'CoreCount' => 1 },
                                                                    'StartTime' => '2021-05-27T13:48Z', 'DeletionProtection' => true, 'SecurityGroupIds' => { 'SecurityGroupId' => ['sg-12345abc'] },
                                                                    'VpcAttributes' => { 'PrivateIpAddress' => { 'IpAddress' => ['10.0.1.22'] }, 'VpcId' => 'vpc-d7o2g7xz9javyxyke96w3',
                                                                                         'VSwitchId' => 'vsw-d7oop1hf6cxg65343zi7s', 'NatIpAddress' => '' }, 'InternetChargeType' => 'PayByTraffic',
                                                                    'InstanceName' => 'instance-ugxipr', 'DeploymentSetId' => 'ds0bp67ax', 'InternetMaxBandwidthOut' => 10,
                                                                    'InternetMaxBandwidthIn' => 10, 'SerialNumber' => 'xxxxx-xxxx-xxxx', 'OSType' => 'linux', 'CreationTime' => '2021-05-27T13:48Z',
                                                                    'AutoReleaseTime' => '', 'Description' => 'host 1', 'InstanceTypeFamily' => 'ecs.g6', 'DedicatedInstanceAttribute' =>
      { 'Tenancy' => '', 'Affinity' => '' }, 'PublicIpAddress' => { 'IpAddress' => ['100.100.100.100'] },
                                                                    'GPUSpec' => 'NVIDIA V100', 'NetworkInterfaces' => { 'NetworkInterface' => [{ 'Type' => 'Primary',
                                                                                                                                                  'PrimaryIpAddress' => '10.0.1.22', 'MacAddress' => '00:16:3e:01:51:05', 'NetworkInterfaceId' =>
      'eni-d7oaidufeql94hm6wxqj', 'PrivateIpSets' => { 'PrivateIpSet' => [{ 'PrivateIpAddress' => '10.0.1.22',
                                                                            'Primary' => true }] } }] }, 'SpotPriceLimit' => 0.0, 'DeviceAvailable' => true, 'SaleCycle' => 'month',
                                                                    'InstanceType' => 'ecs.g6.large', 'SpotStrategy' => 'NoSpot', 'OSNameEn' => 'Ubuntu 18.04 64 bit',
                                                                    'IoOptimized' => true, 'ZoneId' => 'eu-west-1a', 'GPUAmount' => 0 }])

    AliCloudECSInstances.any_instance.stubs(:fetch_instance_ram_roles).returns(['test-role-abcdefg'])
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudECSInstances.new(rubbish: 9) }
  end

  def test_does_not_accept_string_argument
    assert_raises(ArgumentError) { AliCloudECSInstances.new('i-id1234') }
  end

  def test_resource_works_with_no_params
    instances = AliCloudECSInstances.new
    assert_equal ['i-id1234'], instances.instance_ids
    assert_equal ['instance-ugxipr'], instances.instance_names
    assert_equal ['host-01'], instances.host_names
    assert_equal ['host 1'], instances.descriptions
    assert_equal [8192], instances.memory
    assert_equal ['PostPaid'], instances.instance_charge_types
    assert_equal [2], instances.cpus
    assert_equal ['Ubuntu 18.04'], instances.os_names
    assert_equal ['vpc'], instances.instance_network_types
    assert_equal [[]], instances.inner_ip_addresses
    assert_equal ['2099-12-31T15:59Z'], instances.expired_times
    assert_equal ['ubuntu_18_04_64_20G_alibase_20190624.vhd'], instances.image_ids
    assert_equal '101.101.101.101', instances.eip_addresses.first['IpAddress']
    assert_equal [''], instances.vlan_ids
    assert_equal ['Running'], instances.statuses
    assert_equal [true], instances.io_optimized
    assert_equal 'optimal', instances.metadata_options.first['HttpTokens']
    assert_equal ['eu-west-1a'], instances.zone_ids
    assert_equal ['Not-applicable'], instances.stopped_modes
    assert_equal 1, instances.cpu_options.first['CoreCount']
    assert_equal ['2021-05-27T13:48Z'], instances.start_times
    assert_equal ['sg-12345abc'], instances.security_group_ids.first['SecurityGroupId']
    assert_equal ['10.0.1.22'], instances.vpc_attributes.first['PrivateIpAddress']['IpAddress']
    assert_equal ['PayByTraffic'], instances.internet_charge_types
    assert_equal ['ds0bp67ax'], instances.deployment_set_ids
    assert_equal [10], instances.internet_max_bandwidth_in
    assert_equal [10], instances.internet_max_bandwidth_out
    assert_equal ['xxxxx-xxxx-xxxx'], instances.serial_numbers
    assert_equal ['linux'], instances.os_types
    assert_equal ['2021-05-27T13:48Z'], instances.creation_times
    assert_equal [''], instances.auto_release_times
    assert_equal ['ecs.g6'], instances.instance_type_families
    assert_equal '', instances.dedicated_instance_attributes.first['Tenancy']
    assert_equal ['100.100.100.100'], instances.public_ip_addresses.first['IpAddress']
    assert_equal ['NVIDIA V100'], instances.gpu_specs
    assert_equal '10.0.1.22', instances.network_interfaces.first['NetworkInterface'].first['PrimaryIpAddress']
    assert_equal [0.0], instances.spot_price_limits
    assert_equal [true], instances.devices_available
    assert_equal ['month'], instances.sale_cycles
    assert_equal ['ecs.g6.large'], instances.instance_types
    assert_equal ['Ubuntu 18.04 64 bit'], instances.os_names_en
    assert_equal ['NoSpot'], instances.spot_strategies
    assert_equal [true], instances.deletion_protections
    assert_equal [['test-role-abcdefg']], instances.ram_roles
  end

  def test_accepts_region
    instances = AliCloudECSInstances.new(region: 'eu-west-1')
    assert_equal ['i-id1234'], instances.instance_ids
  end
end
