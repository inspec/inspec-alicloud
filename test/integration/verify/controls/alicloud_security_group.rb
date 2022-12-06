alicloud_vpc_id = input(:alicloud_vpc_id, value: '', description: 'AliCloud VPC ID.')
alicloud_security_group_alpha_id = input(:alicloud_security_group_alpha_id, value: '', description: 'AliCloud Security Group ID.')
alicloud_security_group_name = input(:alicloud_security_group_name, value: '', description: 'AliCloud Security Group name.')
alicloud_security_group_description = input(:alicloud_security_group_description, value: '', description: 'AliCloud Security Group name.')
alicloud_security_group_rule_port_in_range = input(:alicloud_security_group_rule_port_in_range, value: '', description: 'A port in AliCloud Security Group ingress rule port range.')
alicloud_security_group_rule_port_not_in_range = input(:alicloud_security_group_rule_port_not_in_range, value: '', description: 'A port not in AliCloud Security Group ingress rule port range.')
alicloud_security_group_rule_cidr = input(:alicloud_security_group_rule_cidr, value: '', description: 'AliCloud Security Group ingress rule IPv4 range.')
alicloud_security_group_rule_cidr_not_in = input(:alicloud_security_group_rule_cidr_not_in, value: '', description: 'A CIDR not in AliCloud Security Group ingress rule IPv4 range.')

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
    its('group_name') { should eq alicloud_security_group_name }
    its('description') { should cmp alicloud_security_group_description }
    its('inbound_rules.count') { should be 1 }
    its('outbound_rules.count') { should be_zero }
    it {
      should allow_in(port: alicloud_security_group_rule_port_in_range, ipv4_range: alicloud_security_group_rule_cidr)
    }
    it {
      should_not allow_in(port: alicloud_security_group_rule_port_not_in_range,
                          ipv4_range: alicloud_security_group_rule_cidr)
    }
    it {
      should_not allow_in(port: alicloud_security_group_rule_port_in_range,
                          ipv4_range: alicloud_security_group_rule_cidr_not_in)
    }
    it { should allow_in(ipv4_range: alicloud_security_group_rule_cidr) }
    it { should_not allow_in(ipv4_range: alicloud_security_group_rule_cidr_not_in) }
  end

  describe alicloud_security_group(group_id: alicloud_security_group_alpha_id, region: 'us-west-1') do
    it { should_not exist }
  end
end
