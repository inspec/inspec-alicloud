title "Test single AliCloud VPC"

alicloud_vpc_id = input(:alicloud_vpc_id, value: "", description: "AliCloud VPC ID")
alicloud_vpc_name = input(:alicloud_vpc_name, value: "", description: "AliCloud VPC name")
alicloud_vpc_description = input(:alicloud_vpc_description, value: "", description: "AliCloud VPC description")
alicloud_vpc_cidr = input(:alicloud_vpc_cidr, value: "", description: "AliCloud VPC IPv4 CIDR block")
alicloud_vpc_vswitch_id = input(:alicloud_vswitch_id, value: "", description: "AliCloud VSwitch ID")
alicloud_vpc_vrouter_id = input(:alicloud_vrouter_id, value: "", description: "AliCloud VRouter ID")

control "alicloud-vpc-1.0" do
  impact 1.0
  title "Ensure AliCloud VPC has the correct properties."

  describe alicloud_vpc(alicloud_vpc_id) do
    it { should exist }
    its("is_default") { should eq false }
    its("vpc_name") { should eq alicloud_vpc_name }
    its("cidr_block") { should eq alicloud_vpc_cidr }
    its("vswitch_ids") { should include alicloud_vpc_vswitch_id }
    its("vrouter_id") { should eq alicloud_vpc_vrouter_id }
    its("status") { should cmp "Available" }
    its("description") { should eq alicloud_vpc_description }
    its("cen_attached?") { should eq false }
  end

  describe alicloud_vpc(vpc_id: "no-such-vpc") do
    it { should_not exist }
  end
end
