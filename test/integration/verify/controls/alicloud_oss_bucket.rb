title 'Test single AliCloud OSS Bucket'

alicloud_action_trail_bucket_id = input(:alicloud_action_trail_bucket_id, value: '', description: 'Action trail bucket name')
alicloud_bucket_acl_name = input(:alicloud_bucket_acl_name, value: '', description: 'OSS bucket name')
alicloud_bucket_encrypted_name = input(:alicloud_bucket_encrypted_name, value: '', description: 'OSS bucket name')
alicloud_bucket_lifecycle_name = input(:alicloud_bucket_lifecycle_name, value: '', description: 'OSS bucket name')
alicloud_bucket_logging_name = input(:alicloud_bucket_logging_name, value: '', description: 'OSS bucket name')
alicloud_bucket_logging_target_name = input(:alicloud_bucket_logging_target_name, value: '', description: 'OSS bucket name')
alicloud_bucket_tags_name = input(:alicloud_bucket_tags_name, value: '', description: 'OSS bucket name')
alicloud_bucket_versioning_name = input(:alicloud_bucket_versioning_name, value: '', description: 'OSS bucket name')
alicloud_bucket_website_name = input(:alicloud_bucket_website_name, value: '', description: 'OSS bucket name')

control 'alicloud-ossbucket-1.0' do
  impact 1.0
  title 'Ensure AliCloud OSS Bucket has the correct properties.'

  describe alicloud_oss_bucket('not-there-bucket') do
    it { should_not exist }
  end

  describe alicloud_oss_bucket(bucket_name: alicloud_action_trail_bucket_id) do
    it { should exist }
    it { should_not be_public }
  end
  
  describe alicloud_oss_bucket(bucket_name: alicloud_bucket_acl_name) do
    it { should exist }
    it { should_not be_public }
  end
  
  describe alicloud_oss_bucket(bucket_name: alicloud_bucket_encrypted_name) do
    it { should exist }
    it { should have_default_encryption_enabled }
    its('bucket_lifecycle_rules') { should be_empty }
  end
  
  describe alicloud_oss_bucket(bucket_name: alicloud_bucket_lifecycle_name) do
    it { should exist }
    its('bucket_lifecycle_rules') { should_not be_empty }
  end
  
  describe alicloud_oss_bucket(bucket_name: alicloud_bucket_logging_name) do
    it { should exist }
    it { should have_access_logging_enabled }
  end

  describe alicloud_oss_bucket(bucket_name: alicloud_bucket_logging_target_name) do
    it { should exist }
    it { should_not have_access_logging_enabled }
  end
  
  describe alicloud_oss_bucket(bucket_name: alicloud_bucket_tags_name) do
    it { should exist }
    # its('tags')   { should include('Environment' => 'Dev',
    #   'Name' => aws_bucket_public_name)}
  end
  
  describe alicloud_oss_bucket(bucket_name: alicloud_bucket_versioning_name) do
    it { should exist }
    it { should have_versioning_enabled }
  end

  describe alicloud_oss_bucket(bucket_name: alicloud_bucket_website_name) do
    it { should exist }
    it { should_not have_versioning_enabled }
    it { should have_website_enabled }
  end
end
