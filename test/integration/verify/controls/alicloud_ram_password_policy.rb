title "Test Alicloud RAM Password Policy"

control "alicloud-ram-1.0" do
  impact 1.0
  title "Ensure AliCloud RAM password policy has the correct properties"

  describe alicloud_ram_password_policy do
    it { should exist }
    its("require_uppercase_characters") { should eq true }
    its("require_lowercase_characters") { should eq true }
    its("require_symbols") { should eq true }
    its("require_numbers") { should eq true }
    its("password_reuse_prevention") { should be >= 5 }
    its("minimum_password_length") { should be >= 8 }
    its("max_password_age") { should eq 180 }
  end
end
