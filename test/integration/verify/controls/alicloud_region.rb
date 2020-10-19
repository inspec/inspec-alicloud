title "Test single AliCloud region"

alicloud_region_exists = input(:alicloud_region_exists, value: "eu-west-1", description: "An AliCloud region.")
alicloud_region_endpoint_exists = input(:alicloud_region_endpoint_exists, value: "ecs.eu-west-1.aliyuncs.com", description: "An AliCloud region.")

control "alicloud-region-1.0" do
  impact 1.0
  title "Ensure AliCloud region has the correct properties."

  describe alicloud_region(region_name: alicloud_region_exists) do
    it { should exist }
    its("region_name") { should eq alicloud_region_exists }
    its("endpoint") { should eq alicloud_region_endpoint_exists }
  end

  describe alicloud_region(alicloud_region_exists) do
    it { should exist }
    its("region_name") { should eq alicloud_region_exists }
    its("endpoint") { should eq alicloud_region_endpoint_exists }
  end

  describe alicloud_region("not-a-real-region-1") do
    it { should_not exist }
  end
end
