title 'Test AliCloud VPC in bulk'

control 'alicloud-vpcs-1.0' do
  title 'Ensure AliCloud VPC plural resource has the correct properties.'

  describe alicloud_vpcs do
    it { should exist }
  end
end
