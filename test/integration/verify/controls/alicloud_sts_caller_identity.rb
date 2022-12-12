title 'Ensure AliCloud credentials being used for the Inspec scan have the correct properties.'

control 'alicloud-sts-caller-identity-1.0' do
  title 'Ensure AliCloud STS caller identity has the correct properties.'

  describe alicloud_sts_caller_identity do
    it { should exist }
    its('arn') { should_not be_nil }
  end
end
