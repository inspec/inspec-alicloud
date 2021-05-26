title "Test a collection of AliCloud RAM Policies"

alicloud_ram_policy_name = attribute(:alicloud_ram_policy_name, value: "", description: "The Alicloud RAM Policy name.")
alicloud_ram_attached_policy_name_1 = attribute(:alicloud_ram_attached_policy_name_1, value: "", description: "The Alicloud RAM Attached Policy 1 name.")

control "alicloud-ram-policies-1.0" do

  impact 1.0
  title "Ensure AliCLoud RAM Policies have the correct properties."

  describe alicloud_ram_policies do
    it { should exist }
    its("policy_names") { should include "AdministratorAccess" }
    # Ensure multiple truncated responses are returned
    its("entries.count") { should be > 200 }
    its("policy_names.count") { should be > 200 }
  end

  describe alicloud_ram_policies(type: "System") do
    it { should exist }
    its("policy_names") { should include "AdministratorAccess" }
    its("policy_names") { should_not include alicloud_ram_policy_name }
  end

  describe alicloud_ram_policies(type: "Custom") do
    it { should exist }
    its("policy_names") { should_not include "AdministratorAccess" }
    its("policy_names") { should include alicloud_ram_policy_name }
    its("policy_names") { should include alicloud_ram_attached_policy_name_1 }
  end

  describe alicloud_ram_policies(only_attached: true, type: "Custom") do
    its("policy_names") { should_not include alicloud_ram_policy_name }
    its("policy_names") { should include alicloud_ram_attached_policy_name_1 }
  end
end
