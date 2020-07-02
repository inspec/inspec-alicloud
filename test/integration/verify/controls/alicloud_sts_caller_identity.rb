title 'Ensure AliCloud credentials being used for the Inspec scan have the correct properties.'

control 'alicloud-sts-caller-identity-1.0' do
  impact 1.0
  title 'Make sure we are not on GovCloud'

  describe alicloud_sts_caller_identity do
    it { should exist }
    its('arn') { should_not be_nil }
  end
end
