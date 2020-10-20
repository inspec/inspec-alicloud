title "Test AliCloud ECS Group resource"

control "alicloud-instances-1.0" do
  impact 1.0
  title "Ensure Alicloud ECS Instances Class has correct attributes"

  describe alicloud_ecs_instances do  # gets region from env var
    it { should exist }
    its("entries.count") { should be >= 1 }
  end

end
