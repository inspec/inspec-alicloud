# frozen_string_literal: true

require 'helper'
require 'alicloud_ram_user'

class AliCloudRamUserConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'

    AliCloudRamUser.any_instance.stubs(:fetch_user_info).with(user_name: 'test-user-1', region: 'us-east-1').returns({
                                                                                                                       'UpdateDate' => '2021-01-01:00:00Z', 'UserName' => 'test-user-1', 'Comments' => 'A comment', 'UserId' => '12345',
                                                                                                                       'DisplayName' => 'a-test-user-1', 'CreateDate' => '2021-01-01:00:00Z', 'Email' => 'test-user-1@some.where',
                                                                                                                       'MobilePhone' => '555-12345'
                                                                                                                     })
    AliCloudRamUser.any_instance.stubs(:fetch_user_info).with(user_name: 'test-user-2', region: 'us-east-1').returns({
                                                                                                                       'UpdateDate' => '2021-01-01:00:00Z', 'UserName' => 'test-user-2', 'Comments' => 'Another comment', 'UserId' => '67890',
                                                                                                                       'DisplayName' => 'a-test-user-2', 'CreateDate' => '2021-01-01:00:00Z', 'Email' => 'test-user-2@some.where',
                                                                                                                       'MobilePhone' => '555-67890'
                                                                                                                     })
    AliCloudRamUser.any_instance.stubs(:fetch_user_info).with(user_name: 'test-user-3', region: 'us-east-1').returns({
                                                                                                                       'UpdateDate' => '2021-01-01:00:00Z', 'UserName' => 'test-user-3', 'Comments' => 'A third comment', 'UserId' => '55555',
                                                                                                                       'DisplayName' => 'a-test-user-', 'CreateDate' => '2021-01-01:00:00Z', 'Email' => 'test-user-3@some.where',
                                                                                                                       'MobilePhone' => '555-55555'
                                                                                                                     })

    AliCloudRamUser.any_instance.stubs(:fetch_login_profile).with(user_name: 'test-user-1',
                                                                  region: 'us-east-1').returns(['UserName' => 'test-user-1'])
    AliCloudRamUser.any_instance.stubs(:fetch_login_profile).with(user_name: 'test-user-2',
                                                                  region: 'us-east-1').returns(['UserName' => 'test-user-2'])
    AliCloudRamUser.any_instance.stubs(:fetch_login_profile).with(user_name: 'test-user-3',
                                                                  region: 'us-east-1').returns(nil)

    AliCloudRamUser.any_instance.stubs(:fetch_access_keys).with(user_name: 'test-user-1',
                                                                region: 'us-east-1').returns([{
                                                                                               'Status' => 'Active', 'AccessKeyId' => '12345'
                                                                                             }, { 'Status' => 'Inactive', 'AccessKeyId' => '67890' }])
    AliCloudRamUser.any_instance.stubs(:fetch_access_keys).with(user_name: 'test-user-2',
                                                                region: 'us-east-1').returns(nil)
    AliCloudRamUser.any_instance.stubs(:fetch_access_keys).with(user_name: 'test-user-3',
                                                                region: 'us-east-1').returns([{
                                                                                               'Status' => 'Active', 'AccessKeyId' => '55555'
                                                                                             }])
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudRamUser.new }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudRamUser.new(rubbish: 9) }
  end

  def test_accepts_string_argument
    user = AliCloudRamUser.new('test-user-1')
    assert_equal 'test-user-1', user.user_name
    assert_equal '12345', user.user_id
    assert_equal '555-12345', user.mobile_phone
    assert_equal true, user.has_console_access?
    assert_equal true, user.has_active_access_key?
    assert_equal true, user.has_console_and_key_access?
  end

  def test_accepts_key_value_argument_and_resource_works
    user = AliCloudRamUser.new(user_name: 'test-user-2')
    assert_equal 'test-user-2', user.user_name
    assert_equal '67890', user.user_id
    assert_equal '555-67890', user.mobile_phone
    assert_equal true, user.has_console_access?
    assert_equal false, user.has_active_access_key?
    assert_equal false, user.has_console_and_key_access?
  end

  def test_accepts_user_name_and_region
    user = AliCloudRamUser.new(user_name: 'test-user-3', region: 'us-east-1')
    assert_equal 'test-user-3', user.user_name
    assert_equal '55555', user.user_id
    assert_equal '555-55555', user.mobile_phone
    assert_equal false, user.has_console_access?
    assert_equal true, user.has_active_access_key?
    assert_equal false, user.has_console_and_key_access?
  end
end
