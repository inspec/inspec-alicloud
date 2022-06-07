# frozen_string_literal: true

require 'helper'
require 'alicloud_disk'

class AliCloudDiskConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'
    AliCloudDisk.any_instance.stubs(:fetch_disk_info).returns({ 'Description' => 'test disk', 'Category' => 'cloud_efficiency',
                                                                'KMSKeyId' => 'akey', 'Encrypted' => true, 'Size' => 20, 'DeleteAutoSnapshot' => true, 'DeleteWithInstance' => true,
                                                                'EnableAutoSnapshot' => true, 'DiskName' => 'my-disk', 'DiskId' => 'd-123456789' })
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudDisk.new }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudDisk.new(rubbish: 9) }
  end

  def test_accepts_string_argument
    disk = AliCloudDisk.new(disk_id: 'd-123456789')
    assert_equal 'd-123456789', disk.id
    assert_equal 'my-disk', disk.name
  end

  def test_accepts_rejects_string_argument_not_in_disk_id_format
    assert_raises(ArgumentError) { AliCloudDisk.new('vol-123456789') }
  end

  def test_accepts_key_value_disk_id_argument_and_resource_works
    disk = AliCloudDisk.new(disk_id: 'd-123456789')
    assert_equal 'my-disk', disk.name
    assert_equal true, disk.encrypted
    assert_equal 'test disk', disk.description
    assert_equal 'cloud_efficiency', disk.category
    assert_equal 'akey', disk.kms_key_id
    assert_equal 20, disk.size
    assert_equal true, disk.enable_auto_snapshot
    assert_equal true, disk.delete_auto_snapshot
    assert_equal true, disk.delete_with_instance
  end

  def test_accepts_key_value_id_argument
    disk = AliCloudDisk.new(id: 'd-123456789')
    assert_equal 'd-123456789', disk.id
    assert_equal 'my-disk', disk.name
  end

  def test_accepts_key_value_disk_name_argument
    disk = AliCloudDisk.new(disk_name: 'my-disk')
    assert_equal 'd-123456789', disk.id
    assert_equal 'my-disk', disk.name
  end

  def test_accepts_key_value_name_argument
    disk = AliCloudDisk.new(name: 'my-disk')
    assert_equal 'd-123456789', disk.id
    assert_equal 'my-disk', disk.name
  end

  def test_accepts_disk_id_and_region
    disk = AliCloudDisk.new(disk_id: 'd-123456789', region: 'us-east-1')
    assert_equal 'd-123456789', disk.id
  end
end
