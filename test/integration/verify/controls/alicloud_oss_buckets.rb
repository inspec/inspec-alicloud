title 'Test AliCloud OSS Buckets in bulk'

alicloud_action_trail_bucket_id = input(:alicloud_action_trail_bucket_id, value: '', description: 'Action trail bucket name')
alicloud_bucket_acl_name = input(:alicloud_bucket_acl_name, value: '', description: 'OSS bucket name')
alicloud_bucket_encrypted_name = input(:alicloud_bucket_encrypted_name, value: '', description: 'OSS bucket name')
alicloud_bucket_lifecycle_name = input(:alicloud_bucket_lifecycle_name, value: '', description: 'OSS bucket name')
alicloud_bucket_logging_name = input(:alicloud_bucket_logging_name, value: '', description: 'OSS bucket name')
alicloud_bucket_logging_target_name = input(:alicloud_bucket_logging_target_name, value: '', description: 'OSS bucket name')
alicloud_bucket_tags_name = input(:alicloud_bucket_tags_name, value: '', description: 'OSS bucket name')
alicloud_bucket_versioning_name = input(:alicloud_bucket_versioning_name, value: '', description: 'OSS bucket name')
alicloud_bucket_website_name = input(:alicloud_bucket_website_name, value: '', description: 'OSS bucket name')

control 'alicloud-oss-buckets-1.0' do

  impact 1.0
  title 'Ensure AliCloud OSS Buckets plural resource has the correct properties.'

  describe alicloud_oss_buckets do
    it { should exist }
    its('count') { should be >= 9 }
    its('bucket_names') { should include alicloud_action_trail_bucket_id }
    its('bucket_names') { should include alicloud_bucket_acl_name }
    its('bucket_names') { should include alicloud_bucket_encrypted_name }
    its('bucket_names') { should include alicloud_bucket_lifecycle_name }
    its('bucket_names') { should include alicloud_bucket_logging_name }
    its('bucket_names') { should include alicloud_bucket_logging_target_name }
    its('bucket_names') { should include alicloud_bucket_tags_name }
    its('bucket_names') { should include alicloud_bucket_versioning_name }
    its('bucket_names') { should include alicloud_bucket_website_name }
    its('bucket_names') { should_not include 'not-there-hopefully' }
  end
end
