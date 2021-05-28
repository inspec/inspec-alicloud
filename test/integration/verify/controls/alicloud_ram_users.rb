alicloud_ram_user_name = input(:alicloud_ram_user_name, value: "", description: "AliCloud RAM User's name.")
alicloud_ram_user_name_2 = input(:alicloud_ram_user_name_2, value: "", description: "AliCloud second RAM User's name.")

title "Test Alicloud RAM plural users"

control "alicloud-ram-users-1.0" do
  impact 1.0
  title "Ensure RAM user list library has correct properties"

  describe alicloud_ram_users do
    its("entries.count") { should be > 1 }
  end

  describe alicloud_ram_users.where(has_console_access: true) do
    its("user_names") { should include alicloud_ram_user_name }
  end

  describe alicloud_ram_users.where(has_console_and_key_access: true) do
    its("user_names") { should include alicloud_ram_user_name }
  end

  describe alicloud_ram_users.where(has_console_access: false) do
    its("user_names") { should include alicloud_ram_user_name_2 }
  end
end
