# frozen_string_literal: true

require 'helper'
require 'alicloud_disks'

class AliCloudDisksConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'eu-west-1'
    AliCloudDisks.any_instance.stubs(:fetch_data).returns([{ 'Description' => 'test disk 1', 'Category' => 'cloud_efficiency',
                                                             'KMSKeyId' => 'akey', 'Encrypted' => true, 'Size' => 20, 'DeleteAutoSnapshot' => true, 'DeleteWithInstance' => false,
                                                             'EnableAutoSnapshot' => true, 'DiskName' => 'my-first-disk', 'DiskId' => 'd-123456789' },
                                                           { 'Description' => 'test disk 2', 'Category' => 'cloud_efficiency',
                                                             'KMSKeyId' => 'bkey', 'Encrypted' => true, 'Size' => 20, 'DeleteAutoSnapshot' => true, 'DeleteWithInstance' => false,
                                                             'EnableAutoSnapshot' => true, 'DiskName' => 'my-second-disk', 'DiskId' => 'd-987654321' },
                                                           { 'Description' => 'test disk 3', 'Category' => 'cloud_efficiency',
                                                             'KMSKeyId' => 'ckey', 'Encrypted' => false, 'Size' => 20, 'DeleteAutoSnapshot' => true, 'DeleteWithInstance' => false,
                                                             'EnableAutoSnapshot' => true, 'DiskName' => 'my-third-disk', 'DiskId' => 'd-555555555' }])
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudDisks.new(rubbish: 9) }
  end

  def test_accepts_no_arguments
    disks = AliCloudDisks.new
    assert_equal %w[d-123456789 d-987654321 d-555555555], disks.ids
    assert_equal ['test disk 1', 'test disk 2', 'test disk 3'], disks.descriptions
    assert_equal %w[my-first-disk my-second-disk my-third-disk], disks.names
    assert_equal [true, true, false], disks.encrypted_disks
    assert_equal %w[cloud_efficiency cloud_efficiency cloud_efficiency], disks.categories
    assert_equal %w[akey bkey ckey], disks.kms_key_ids
    assert_equal [20, 20, 20], disks.sizes
    assert_equal [true, true, true], disks.enable_auto_snapshot
    assert_equal [true, true, true], disks.delete_auto_snapshot
    assert_equal [false, false, false], disks.delete_with_instance
  end

  def test_accepts_region
    AliCloudDisks.new(region: 'us-east-1')
  end
end
