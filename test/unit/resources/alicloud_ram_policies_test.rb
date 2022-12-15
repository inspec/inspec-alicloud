require 'helper'
require 'alicloud_ram_policies'

class AliCloudRamPoliciesConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'

    system = { 'Policies' => { 'Policy' => [{ 'PolicyType' => 'System', 'Description' => 'System test policy 1',
                                              'AttachmentCount' => 0, 'PolicyName' => 'system-test-1', 'DefaultVersion' => 'v1' },
                                            { 'PolicyType' => 'System', 'Description' => 'System test policy 2', 'AttachmentCount' => 1,
                                              'PolicyName' => 'system-test-2', 'DefaultVersion' => 'v2' }, { 'PolicyType' => 'System',
                                                                                                             'Description' => 'System test policy 3', 'AttachmentCount' => 0, 'PolicyName' => 'system-test-3',
                                                                                                             'DefaultVersion' => 'v1' }] }, 'IsTruncated' => false }
    custom = { 'Policies' => { 'Policy' => [{ 'PolicyType' => 'Custom', 'Description' => 'Test policy 1',
                                              'AttachmentCount' => 1, 'PolicyName' => 'test-1', 'DefaultVersion' => 'v3' }, { 'PolicyType' => 'Custom',
                                                                                                                              'Description' => 'Test policy 2', 'AttachmentCount' => 0, 'PolicyName' => 'test-2', 'DefaultVersion' => 'v2' },
                                            { 'PolicyType' => 'Custom', 'Description' => 'Test policy 3', 'AttachmentCount' => 0, 'PolicyName' => 'test-3',
                                              'DefaultVersion' => 'v4' }] }, 'IsTruncated' => false }

    AliCloudRamPolicies.any_instance.stubs(:list_policies).with(type: 'System', region: 'us-east-1').returns(system)
    AliCloudRamPolicies.any_instance.stubs(:list_policies).with(type: 'Custom', region: 'us-east-1').returns(custom)
    AliCloudRamPolicies.any_instance.stubs(:list_policies).with(only_attached: true, region: 'us-east-1',
                                                                type: 'System').returns(system)
    AliCloudRamPolicies.any_instance.stubs(:list_policies).with(only_attached: true, region: 'us-east-1',
                                                                type: 'Custom').returns(custom)
    AliCloudRamPolicies.any_instance.stubs(:list_policies).with(type: 'System', region: 'eu-west-1').returns(system)

    AliCloudRamPolicies.any_instance.stubs(:get_attached_entities).returns({
                                                                             'Groups' => { 'Group' => [{ 'GroupName' => 'group-1', 'AttachDate' => '2021-01-01T00:00:00Z',
                                                                                                         'Comments' => 'A comment' }] },
                                                                             'Roles' => { 'Role' => [{ 'RoleName' => 'role-1', 'Description' => '', 'Arn' => 'acs:ram::12345:role/role-1',
                                                                                                       'RoleId' => '55555' }] },
                                                                             'Users' => { 'User' => [{ 'UserName' => 'user-1', 'UserId' => '66666', 'DisplayName' => 'user-1' },
                                                                                                     {
                                                                                                       'UserName' => 'user-2', 'UserId' => '88888', 'DisplayName' => 'user-2'
                                                                                                     }] },
                                                                           })
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudRamPolicies.new(rubbish: 9) }
  end

  def test_accepts_no_arguments
    policies = AliCloudRamPolicies.new
    assert_equal %w{system-test-1 system-test-2 system-test-3 test-1 test-2 test-3}, policies.policy_names
    assert_equal %w{v1 v2 v1 v3 v2 v4}, policies.default_versions
    assert_equal [0, 1, 0, 1, 0, 0], policies.attachment_counts
    assert_equal [[], ['group-1'], [], ['group-1'], [], []], policies.attached_groups
    assert_equal [[], ['role-1'], [], ['role-1'], [], []], policies.attached_roles
    assert_equal [[], %w{user-1 user-2}, [], %w{user-1 user-2}, [], []], policies.attached_users
  end

  def test_accepts_custom_as_string_argument
    policies = AliCloudRamPolicies.new('Custom')
    assert_equal %w{test-1 test-2 test-3}, policies.policy_names
    assert_equal %w{v3 v2 v4}, policies.default_versions
    assert_equal [['group-1'], [], []], policies.attached_groups
    assert_equal [['role-1'], [], []], policies.attached_roles
    assert_equal [%w{user-1 user-2}, [], []], policies.attached_users
  end

  def test_accepts_system_type_and_region
    policies = AliCloudRamPolicies.new(type: 'System', region: 'eu-west-1')
    assert_equal %w{system-test-1 system-test-2 system-test-3}, policies.policy_names
    assert_equal %w{v1 v2 v1}, policies.default_versions
  end

  def test_only_attached
    policies = AliCloudRamPolicies.new(only_attached: true)
    assert_equal %w{system-test-2 test-1}, policies.policy_names
    assert_equal %w{v2 v3}, policies.default_versions
    assert_equal [1, 1], policies.attachment_counts
  end
end
