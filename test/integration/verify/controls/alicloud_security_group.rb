alicloud_vpc_id = input(:alicloud_vpc_id, value: '', description: 'AliCloud VPC ID.')
alicloud_security_group_alpha_id = input(:alicloud_security_group_alpha_id, value: '', description: 'AliCloud Security Group ID.')

title 'Test single AliCloud Security Groups'

control 'alicloud-security-group-1.0' do
  impact 1.0
  title 'Ensure AliCloud security group has the correct properties.'

  describe alicloud_security_group(group_id: 'no-such-security-group') do
    it { should_not exist }
  end

  describe alicloud_security_group(alicloud_security_group_alpha_id) do
    it { should exist }
    its('vpc_id') { should eq alicloud_vpc_id }
    its('group_name') { should eq 'inspec-sg' }
    its('description') { should cmp 'Test security group for inspec' }
    its('inbound_rules.count') { should be_zero }
    its('outbound_rules.count') { should be_zero }
  end

  describe alicloud_security_group(group_id: alicloud_security_group_alpha_id, region: 'us-west-1') do
    it { should_not exist }
  end
end
