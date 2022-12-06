require 'helper'
require 'alicloud_ram_user_mfa'

class AliCloudRamUserMFAConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'
    AliCloudRamUserMFA.any_instance.stubs(:fetch_mfa_info).returns({ 'SerialNumber' => 'serial', 'Type' => 'VMFA' })
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudRamUserMFA.new }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudRamUserMFA.new(rubbish: 9) }
  end

  def test_accepts_string_argument
    mfa = AliCloudRamUserMFA.new('test-user-1')
    assert_equal 'serial', mfa.serial_number
    assert_equal 'VMFA', mfa.type
  end

  def test_accepts_user_name_and_region
    mfa = AliCloudRamUserMFA.new(user_name: 'test-user-1', region: 'us-east-1')
    assert_equal 'VMFA', mfa.type
  end
end
