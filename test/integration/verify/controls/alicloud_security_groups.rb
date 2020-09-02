title 'Test AliCloud Security Groups in bulk'

control 'alicloud-security-groups-1.0' do
  impact 1.0
  title 'Ensure AliCloud security group plural resource has the correct properties.'

  # Verify that you have security groups defined
  describe alicloud_security_groups do
    it { should exist }
  end

  # Verify you have more than the default security group
  # We are creating 20 additional security groups to test the AliCloudCommonClient pagination code
  describe alicloud_security_groups do
    its('entries.count') { should be > 20 }
  end
end
