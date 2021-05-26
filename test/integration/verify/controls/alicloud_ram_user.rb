alicloud_ram_user_name              = input(:alicloud_ram_user_name, value: "", description: "AliCloud RAM User's name.")
alicloud_ram_user_display_name      = input(:alicloud_ram_user_display_name, value: "", description: "AliCloud RAM User's display name.")
alicloud_ram_user_mobile            = input(:alicloud_ram_user_mobile, value: "", description: "AliCloud RAM User's mobile.")
alicloud_ram_user_email             = input(:alicloud_ram_user_email, value: "", description: "AliCloud RAM User's Email.")
alicloud_ram_user_name_2            = input(:alicloud_ram_user_name_2, value: "", description: "AliCloud RAM Second User's name.")

title "Test single Alicloud RAM user"

control "alicloud-ram-user-1.0" do
  impact 1.0
  title "Ensure RAM user library has correct properties"

  describe alicloud_ram_user(alicloud_ram_user_name) do
    it { should exist }
    it { should have_console_access }
    it { should have_active_access_key }
    it { should have_console_and_key_access }
    its("update_date") { should_not be_nil }
    its("user_name") { should eq alicloud_ram_user_name }
    its("email") { should eq alicloud_ram_user_email }
    its("user_id") { should_not be_nil }
    its("comments") { should_not be_nil }
    its("display_name") { should eq alicloud_ram_user_display_name }
    its("last_login_date") { should_not be_nil }
    its("create_date") { should_not be_nil }
    its("mobile_phone") { should eq alicloud_ram_user_mobile }
    its("access_keys.count") { should eq 2 }
    its("active_access_keys.count") { should be <= 1 }
    its("has_console_access?") { should be true }
    its("has_active_access_key?") { should eq true }
    its("has_console_and_key_access?") { should be true }
  end

  describe alicloud_ram_user(user_name: alicloud_ram_user_name_2) do
    it { should_not have_console_access }
    it { should_not have_active_access_key }
    it { should_not have_console_and_key_access }
    its("access_keys.count") { should eq 0 }
    its("active_access_keys.count") { should eq 0 }
    its("has_console_access?") { should be false }
    its("has_active_access_key?") { should eq false }
    its("has_console_and_key_access?") { should be false }
  end

  describe alicloud_ram_user("no-such-user") do
    it { should_not exist }
  end
end
