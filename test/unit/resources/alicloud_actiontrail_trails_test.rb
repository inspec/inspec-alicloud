require 'helper'
require 'alicloud_actiontrail_trails'

class AliCloudActionTrailTrailsConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'

    AliCloudActionTrailTrails.any_instance.stubs(:fetch_data).returns({ 'Name' => 'trail-name',
                                                                        'OssBucketName' => 'bucket-name',
                                                                        'OssKeyPrefix' => 'bucket-name-prefix',
                                                                        'RoleName' => 'role-name' })
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudActionTrailTrails.new(rubbish: 9) }
  end

  def test_rejects_string_argument
    assert_raises(ArgumentError) { AliCloudActionTrailTrails.new('not-there') }
  end
end
