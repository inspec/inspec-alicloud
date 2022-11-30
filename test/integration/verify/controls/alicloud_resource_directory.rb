title 'Test single AliCloud Resource Directory'

control 'alicloud_resource_directory-1.0' do
  impact 1.0
  title 'Ensure AliCloud Resource Directory has the correct properties.'

  describe alicloud_resource_directory do
    it { should exist }
    its('resource_directory_id') { should_not eq 'rd_id' }
    its('master_account_name') { should_not eq 'master_acct_name' }
  end
end
