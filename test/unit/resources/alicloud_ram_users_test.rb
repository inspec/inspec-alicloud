# frozen_string_literal: true

require 'helper'
require 'alicloud_ram_users'

class AliCloudRamUsersConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'

    AliCloudRamUsers.any_instance.stubs(:fetch_users).returns([{ 'UpdateDate' => '2021-01-01:00:00Z', 'UserName' => 'test-user-1',
                                                                 'Comments' => 'A comment', 'UserId' => '12345', 'DisplayName' => 'a-test-user-1', 'CreateDate' => '2021-01-01:00:00Z' },
                                                               { 'UpdateDate' => '2021-01-01:00:00Z', 'UserName' => 'test-user-2', 'Comments' => 'Another comment', 'UserId' => '67890',
                                                                 'DisplayName' => 'a-test-user-2', 'CreateDate' => '2021-01-01:00:00Z' }, { 'UpdateDate' => '2021-01-01:00:00Z',
                                                                                                                                            'UserName' => 'test-user-3', 'Comments' => 'A third comment', 'UserId' => '55555', 'DisplayName' => 'a-test-user-2',
                                                                                                                                            'CreateDate' => '2021-01-01:00:00Z' }])

    AliCloudRamUsers.any_instance.stubs(:fetch_login_profile).with('us-east-1',
                                                                   'test-user-1').returns(['UserName' => 'test-user-1'])
    AliCloudRamUsers.any_instance.stubs(:fetch_login_profile).with('us-east-1',
                                                                   'test-user-2').returns(['UserName' => 'test-user-2'])
    AliCloudRamUsers.any_instance.stubs(:fetch_login_profile).with('us-east-1', 'test-user-3').returns(nil)

    AliCloudRamUsers.any_instance.stubs(:fetch_access_keys).with('us-east-1',
                                                                 'test-user-1').returns([{ 'Status' => 'Active',
                                                                                           'AccessKeyId' => '12345' }, { 'Status' => 'Inactive', 'AccessKeyId' => '67890' }])
    AliCloudRamUsers.any_instance.stubs(:fetch_access_keys).with('us-east-1', 'test-user-2').returns(nil)
    AliCloudRamUsers.any_instance.stubs(:fetch_access_keys).with('us-east-1',
                                                                 'test-user-3').returns([{ 'Status' => 'Active',
                                                                                           'AccessKeyId' => '55555' }])

    AliCloudRamUsers.any_instance.stubs(:fetch_user_mfa).with('us-east-1', 'test-user-1').returns({ 'Type' => 'VMFA',
                                                                                                    'SerialNumber' => 'acs:ram::1234:mfa/test-user-1' })
    AliCloudRamUsers.any_instance.stubs(:fetch_user_mfa).with('us-east-1', 'test-user-2').returns(nil)
    AliCloudRamUsers.any_instance.stubs(:fetch_user_mfa).with('us-east-1', 'test-user-3').returns(nil)
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudRamUsers.new(rubbish: 9) }
  end

  def test_rejects_string_argument
    assert_raises(ArgumentError) { AliCloudRamUsers.new('us-west-1') }
  end

  def test_accepts_no_arguments_and_resource_works
    users = AliCloudRamUsers.new
    assert_equal %w{test-user-1 test-user-2 test-user-3}, users.user_names
    assert_equal %w{a-test-user-1 a-test-user-2 a-test-user-2}, users.display_names
    assert_equal %w{12345 67890 55555}, users.user_ids
    assert_equal [true, true, false], users.has_console_access
    assert_equal [true, false, true], users.has_access_key
    assert_equal [%w{12345 67890}, [], %w{55555}], users.access_keys
    assert_equal [true, false, true], users.has_active_access_key
    assert_equal [%w{12345}, [], %w{55555}], users.active_access_keys
    assert_equal [true, false, false], users.has_console_and_key_access
    assert_equal [true, false, false], users.has_mfa_enabled
  end
end
