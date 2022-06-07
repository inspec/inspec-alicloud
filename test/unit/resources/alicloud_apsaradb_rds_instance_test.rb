# frozen_string_literal: true

require 'helper'
require 'alicloud_apsaradb_rds_instance'

class AliCloudApsaradbRdsInstanceConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'

    AliCloudApsaradbRdsInstance.any_instance.stubs(:fetch_db_info).returns({ 'DBInstanceMemory' => 1024,
                                                                             'DBInstanceType' => 'Primary', 'InstanceNetworkType' => 'VPC', 'DBInstanceId' => 'rm-inst4nc3',
                                                                             'DBInstanceStorage' => 20, 'Engine' => 'MySQL', 'DBInstanceDescription' => 'testdb',
                                                                             'EngineVersion' => '8.0', 'DBInstanceStatus' => 'Running', 'DBInstanceClass' => 'mysql.n1.micro.1',
                                                                             'PayType' => 'Postpaid', 'VpcId' => 'vpc-1234', 'Category' => 'Basic', 'DBInstanceNetType' => 'Intranet',
                                                                             'DBInstanceCPU' => '1', 'SecurityIPList' => '10.0.0.0/16', 'SecurityIPMode' => 'normal',
                                                                             'ZoneId' => 'eu-west-1a', 'DBInstanceStorageType' => 'cloud_ssd' })

    AliCloudApsaradbRdsInstance.any_instance.stubs(:fetch_vpc_info).returns({ 'VpcId' => 'vpc-1234',
                                                                              'IsDefault' => false })
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudApsaradbRdsInstance.new }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudApsaradbRdsInstance.new(rubbish: 9) }
  end

  def test_accepts_string_argument
    rds = AliCloudApsaradbRdsInstance.new('not-there')
    assert_equal 'not-there', rds.instance_id
  end

  def test_accepts_key_value_argument_and_resource_works
    rds = AliCloudApsaradbRdsInstance.new(db_instance_id: 'rm-inst4nc3')
    assert_equal 'rm-inst4nc3', rds.instance_id
    assert_equal 'testdb', rds.description
    assert_equal 'Primary', rds.instance_type
    assert_equal 'Basic', rds.category
    assert_equal 'MySQL', rds.engine
    assert_equal '8.0', rds.engine_version
    assert_equal 20, rds.allocated_storage
    assert_equal 'cloud_ssd', rds.storage_type
    assert_equal 1024, rds.memory
    assert_equal 1, rds.cpus
    assert_equal 'mysql.n1.micro.1', rds.instance_class
    assert_equal 'Postpaid', rds.pay_type
    assert_equal 'Running', rds.status
    assert_equal 'VPC', rds.network_type
    assert_equal 'Intranet', rds.net_type
    assert_equal 'vpc-1234', rds.vpc_id
    assert_equal 'eu-west-1a', rds.zone_id
    assert_equal false, rds.in_default_vpc
    assert_equal '10.0.0.0/16', rds.security_ips
    assert_equal 'normal', rds.security_ip_mode
  end

  def test_accepts_instance_id_and_region
    rds = AliCloudApsaradbRdsInstance.new(db_instance_id: 'rn-inst4nc3', region: 'eu-west-1')
    assert_equal 'rn-inst4nc3', rds.instance_id
  end
end
