title 'Test AliCloud Instances count'

control 'ali-cloud-instances-1.0' do
  title 'Ensure AliCloud ECS Instances Class has correct attributes.'

  describe alicloud_ecs_instances do
    it { should exist }
    its('entries.count') { should be >= 1 }
  end
end

control 'alicloud_oss_bucket' do

  describe alicloud_oss_bucket(bucket_name: 'name') do
    it { should exist }
    its("tags") { should eq "{}" }
  end
end
