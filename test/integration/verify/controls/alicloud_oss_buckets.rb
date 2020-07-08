title 'Test AliCloud OSS Buckets in bulk'

alicloud_oss_bucket_public_name = attribute(:alicloud_oss_bucket_public_name, default: '', description: 'The AliCloud OSS bucket name.')
alicloud_oss_bucket_private_name = attribute(:alicloud_oss_bucket_private_name, default: '', description: 'The AliCloud OSS bucket name.')

control 'alicloud-oss-buckets-1.0' do

  impact 1.0
  title 'Ensure AliCloud OSS Buckets plural resource has the correct properties.'

  describe alicloud_oss_buckets do
    it { should exist }
    its('count') { should be >= 1 }
    its('bucket_names') { should include alicloud_oss_bucket_public_name }
    its('bucket_names') { should include alicloud_oss_bucket_private_name }
    its('bucket_names') { should_not include 'not-there-hopefully' }
  end
end
