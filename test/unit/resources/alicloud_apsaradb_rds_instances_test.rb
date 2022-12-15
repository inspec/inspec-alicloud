require 'helper'
require 'alicloud_apsaradb_rds_instances'

class AliCloudApsaradbRdsInstancessConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'

    AliCloudApsaradbRdsInstances.any_instance.stubs(:fetch_data).returns({ 'TotalRecordCount' => 1, 'PageRecordCount' => 1,
                                                                           'PageNumber' => 1, 'Items' => { 'DBInstance' => [{ 'ResourceGroupId' => 'rg-12345', 'DBInstanceNetType' => 'Intranet',
                                                                                                                              'DBInstanceType' => 'Primary', 'MutriORsignle' => false, 'InstanceNetworkType' => 'VPC', 'DBInstanceId' => 'rm-inst4nc3',
                                                                                                                              'ReadOnlyDBInstanceIds' => { 'ReadOnlyDBInstanceId' => [] }, 'DBInstanceDescription' => 'testdb',
                                                                                                                              'Engine' => 'MySQL', 'EngineVersion' => '8.0', 'DBInstanceStatus' => 'Running', 'ZoneId' => 'eu-west-1a',
                                                                                                                              'DBInstanceClass' => 'mysql.n1.micro.1', 'CreateTime' => '2021-05-28T08:04:07Z', 'VSwitchId' => 'vsw-12345',
                                                                                                                              'PayType' => 'Postpaid', 'LockMode' => 'Unlock', 'DBInstanceStorageType' => 'cloud_ssd', 'InsId' => 1,
                                                                                                                              'VpcId' => 'vpc-1234', 'ConnectionMode' => 'Standard', 'VpcCloudInstanceId' => 'rm-f2z81b1496wwd9393-202105281604',
                                                                                                                              'RegionId' => 'eu-west-1', 'ExpireTime' => '' }] } })

    AliCloudApsaradbRdsInstances.any_instance.stubs(:fetch_vpc_info).returns({ 'VpcId' => 'vpc-1234',
                                                                               'IsDefault' => false })
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudApsaradbRdsInstances.new(rubbish: 9) }
  end

  def test_rejects_string_argument
    assert_raises(ArgumentError) { AliCloudApsaradbRdsInstances.new('not-there') }
  end

  def test_accepts_no_arguments_and_resource_works
    databases = AliCloudApsaradbRdsInstances.new
    assert_equal ['rm-inst4nc3'], databases.db_instance_ids
    assert_equal ['testdb'], databases.descriptions
    assert_equal ['rg-12345'], databases.resource_groups
    assert_equal ['Intranet'], databases.net_types
    assert_equal ['Primary'], databases.instance_types
    assert_equal [false], databases.multiple_zone_deployments
    assert_equal ['VPC'], databases.network_types
    assert_equal [[]], databases.read_only_instance_ids
    assert_equal ['MySQL'], databases.engines
    assert_equal ['8.0'], databases.engine_versions
    assert_equal ['Running'], databases.statuses
    assert_equal ['eu-west-1a'], databases.zone_ids
    assert_equal ['mysql.n1.micro.1'], databases.instance_classes
    assert_equal ['2021-05-28T08:04:07Z'], databases.create_times
    assert_equal ['vsw-12345'], databases.vswitch_ids
    assert_equal ['Postpaid'], databases.pay_types
    assert_equal ['Unlock'], databases.lock_modes
    assert_equal ['cloud_ssd'], databases.storage_types
    assert_equal ['vpc-1234'], databases.vpc_ids
  end

  def test_accepts_region
    databases = AliCloudApsaradbRdsInstances.new(region: 'eu-west-1')
    assert_equal ['rm-inst4nc3'], databases.db_instance_ids
  end
end
