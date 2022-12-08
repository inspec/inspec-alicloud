control 'alicloud_oss_bucket' do
  impact 1.0
  title 'Ensure AliCloud ECS Instances Class has correct attributes.'

  describe alicloud_oss_bucket(bucket_name: 'soumyo') do
    it { should exist }
  end
end