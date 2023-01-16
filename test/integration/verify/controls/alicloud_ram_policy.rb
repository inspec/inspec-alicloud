title 'Test single AliCloud RAM Policy'

alicloud_ram_policy_name = input(:alicloud_ram_policy_name, value: '', description: 'The AliCloud RAM Policy name.')
alicloud_ram_attached_policy_name_1 = input(:alicloud_ram_attached_policy_name_1, value: '', description: 'The Attached AliCloud RAM Policy 1 name.')
alicloud_ram_attached_policy_name_2 = input(:alicloud_ram_attached_policy_name_2, value: '', description: 'The Attached AliCloud RAM Policy 2 name.')
alicloud_ram_user_name = input(:alicloud_ram_user_name, value: '', description: 'The AliCloud RAM User name.')
alicloud_ram_group_name = input(:alicloud_ram_group_name, value: '', description: 'The AliCloud RAM Group name.')
alicloud_ram_role_arn = input(:alicloud_ram_role_arn, value: '', description: 'The AliCloud RAM Role ARN.')

control 'alicloud-ram-policy-1.0' do
  title 'Ensure AliCloud RAM Policy has the correct properties.'

  describe alicloud_ram_policy(policy_name: 'DoesNotExist') do
    it { should_not exist }
  end

  describe alicloud_ram_policy('AliyunSupportFullAccess') do
    it { should exist }
  end

  describe alicloud_ram_policy(policy_name: 'AliyunSupportFullAccess', type: 'Custom') do
    it { should_not exist }
  end

  describe alicloud_ram_policy(policy_name: alicloud_ram_policy_name, type: 'Custom') do
    it { should exist }
    it { should_not have_statement('Effect' => 'Allow', 'Resource' => '*', 'Action' => '*') }
    it { should have_statement('Effect' => 'Allow', 'Resource' => '*', 'Action' => 'ecs:Describe*') }
    it { should have_statement('Effect' => 'Allow', 'Resource' => 'acs:oss:::*', 'NotAction' => 'oss:DeleteBucket') }
    its('statement_count') { should be 2 }
    its('default_version') { should cmp 'v1' }
    it { should_not be_attached }
    its('attached_user_count') { should eq 0 }
    its('attached_group_count') { should eq 0 }
    its('attached_role_count') { should eq 0 }
    its('attachment_count') { should eq 0 }
  end

  describe alicloud_ram_policy(policy_name: alicloud_ram_policy_name, type: 'System') do
    it { should_not exist }
  end

  describe alicloud_ram_policy(policy_name: alicloud_ram_attached_policy_name_1) do
    it { should_not be_attached_to_user('fake-user') }
    it { should_not be_attached_to_role('fake-role') }
    it { should be_attached_to_role(alicloud_ram_role_arn) }
    it { should be_attached }
    its('attached_roles') { should include alicloud_ram_role_arn }
    its('attached_user_count') { should eq 0 }
    its('attached_group_count') { should eq 0 }
    its('attached_role_count') { should eq 1 }
    its('attachment_count') { should eq 1 }
    # Test Action in an array
    it { should have_statement(Action: ['ecs:Describe*']) }
  end

  describe alicloud_ram_policy(policy_name: alicloud_ram_attached_policy_name_2, type: 'Custom') do
    it { should be_attached_to_user(alicloud_ram_user_name) }
    it { should be_attached_to_group(alicloud_ram_group_name) }
    it { should be_attached }
    its('attached_users') { should include alicloud_ram_user_name }
    its('attached_user_count') { should eq 1 }
    its('attached_groups') { should include alicloud_ram_group_name }
    its('attached_group_count') { should eq 1 }
    its('attached_role_count') { should eq 0 }
    its('attachment_count') { should eq 2 }
  end
end
