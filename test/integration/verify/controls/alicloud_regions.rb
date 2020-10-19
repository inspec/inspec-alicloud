title "Test AliCloud Regions in bulk"

control "alicloud-regions-1.0" do
  impact 1.0
  title "Ensure AliCloud regions plural resource has the correct properties."

  describe alicloud_regions do
    it { should exist }
    its("count") { should be >= 1 }
    its("region_names") { should include "eu-west-1" }
    its("endpoints") { should include "ecs.eu-west-1.aliyuncs.com" }
  end
end
