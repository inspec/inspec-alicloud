require "helper"
require "alicloud_ecs_instance"

class AliCloudECSInstanceConstructorTest < Minitest::Test
  def setup
    ENV["ALICLOUD_REGION"] = "eu-west-1"

    AliCloudECSInstance.any_instance.stubs(:fetch_instance_attributes).returns({ "Description" => "host 1", "Memory" => 8192,
      "InstanceChargeType" => "PostPaid", "Cpu" => 2, "InstanceNetworkType" => "vpc", "PublicIpAddress" => { "IpAddress" => ["192.168.0.1"] },
      "InnerIpAddress" => { "IpAddress" => [] }, "ExpiredTime" => "2099-12-31T15:59Z", "ImageId" => "ubuntu_18_04_64_20G_alibase_20190624.vhd",
      "EipAddress" => { "AllocationId" => "", "IpAddress" => "101.101.101.101", "InternetChargeType" => "" }, "InstanceType" => "ecs.g6.large",
      "HostName" => "host-01", "VlanId" => "", "Status" => "Running", "IoOptimized" => "optimized", "ZoneId" => "eu-west-1a",
      "InstanceId" => "i-id1234", "ClusterId" => "", "StoppedMode" => "Not-applicable", "DedicatedHostAttribute" => { "DedicatedHostId" => "",
      "DedicatedHostName" => "host-01" }, "SecurityGroupIds" => { "SecurityGroupId" => ["sg-12345abc"] }, "VpcAttributes" => {
      "PrivateIpAddress" => { "IpAddress" => ["10.0.1.22"] }, "VpcId" => "vpc-d7o2g7xz", "VSwitchId" => "vsw-d7oop1h",
      "NatIpAddress" => "" }, "OperationLocks" => { "LockReason" => [] }, "InternetChargeType" => "PayByTraffic",
      "InstanceName" => "instance-ugxipr", "InternetMaxBandwidthOut" => 10, "InternetMaxBandwidthIn" => 1000,
      "SerialNumber" => "xxxxx-xxxx-xxxx", "CreationTime" => "2021-05-27T13:48:03Z", "RegionId" => "eu-west-1", "CreditSpecification" => "" })

    AliCloudECSInstance.any_instance.stubs(:fetch_instance).returns({ "Instances" => { "Instance" => [{ "DeletionProtection" => true }] } })

    AliCloudECSInstance.any_instance.stubs(:fetch_instance_ram_roles).returns(["test-role-abcdefg"])
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudECSInstance.new }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudECSInstance.new(rubbish: 9) }
  end

  def test_accepts_string_argument
    instance = AliCloudECSInstance.new("i-id1234")
    assert_equal "i-id1234", instance.instance_id
  end

  def test_accepts_key_value_argument_and_resource_works
    instance = AliCloudECSInstance.new(instance_id: "i-id1234")
    assert_equal "i-id1234", instance.instance_id
    assert_equal "host 1", instance.description
    assert_equal 8192, instance.memory
    assert_equal "PostPaid", instance.instance_charge_type
    assert_equal 2, instance.cpu
    assert_equal "vpc", instance.instance_network_type
    assert_equal ["192.168.0.1"], instance.public_ip_address
    assert_equal [], instance.inner_ip_address
    assert_equal "2099-12-31T15:59Z", instance.expired_time
    assert_equal "ubuntu_18_04_64_20G_alibase_20190624.vhd", instance.image_id
    assert_equal "101.101.101.101", instance.eip_address["IpAddress"]
    assert_equal "ecs.g6.large", instance.instance_type
    assert_equal "host-01", instance.host_name
    assert_equal "", instance.vlan_id
    assert_equal "Running", instance.status
    assert_equal "optimized", instance.io_optimized
    assert_equal "eu-west-1a", instance.zone_id
    assert_equal "", instance.cluster_id
    assert_equal "Not-applicable", instance.stopped_mode
    assert_equal "host-01", instance.dedicated_host_attribute["DedicatedHostName"]
    assert_equal ["sg-12345abc"], instance.security_group_ids["SecurityGroupId"]
    assert_equal ["10.0.1.22"], instance.vpc_attributes["PrivateIpAddress"]["IpAddress"]
    assert_equal [], instance.operation_locks["LockReason"]
    assert_equal "PayByTraffic", instance.internet_charge_type
    assert_equal "instance-ugxipr", instance.instance_name
    assert_equal 10, instance.internet_max_bandwidth_out
    assert_equal 1000, instance.internet_max_bandwidth_in
    assert_equal "xxxxx-xxxx-xxxx", instance.serial_number

    # @creation_time              = @instance_attributes["CreationTime"]
    # assert_equal ["2021-05-27T13:48Z"], instances.creation_times
    # @credit_specification       = @instance_attributes["CreditSpecification"]

    assert_equal true, instance.deletion_protection
    assert_equal ["test-role-abcdefg"], instance.ram_roles
  end

  def test_accepts_instance_id_and_region
    instance = AliCloudECSInstance.new(instance_id: "i-id1234", region: "eu-west-1")
    assert_equal "i-id1234", instance.instance_id
  end
end
