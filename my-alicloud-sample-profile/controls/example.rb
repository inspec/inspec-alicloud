title 'Test AliCloud Instances count'

control 'ali-cloud-instances-1.0' do
  title 'Ensure AliCloud ECS Instances Class has correct attributes.'
  # describe alicloud_oss_bucket(bucket_name: 'soumyo') do
  #   it { should exist }
  #   it { should have_default_encryption_enabled }
  #   its('bucket_lifecycle_rules') { should be_empty }
  # end

  describe alicloud_oss_bucket(bucket_name: 'soumyo') do
    it { should exist }
    its("tagging") { should eq "{\"name\":\"soumyo\"}" }
  end
end

control 'alicloud_oss_bucket' do

  describe alicloud_oss_bucket(bucket_name: 'name') do
    it { should exist }
    its("tags") { should eq "{}" }
  end
end
