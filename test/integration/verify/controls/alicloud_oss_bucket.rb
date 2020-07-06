title 'Test single AliCloud OSS Bucket'

alicloud_action_trail_bucket_id = input(:alicloud_action_trail_bucket_id, value: '', description: 'Action trail bucket name')

control 'alicloud-ossbucket-1.0' do
  impact 1.0
  title 'Ensure AliCloud OSS Bucket has the correct properties.'

  describe alicloud_oss_bucket('not-there-bucket') do
    it { should_not exist }
  end

  describe alicloud_oss_bucket(bucket_name: alicloud_action_trail_bucket_id) do
    it { should exist }
    it { should_not be_public }
    its('has_default_encryption_enabled') { should eq true }
  end
end
