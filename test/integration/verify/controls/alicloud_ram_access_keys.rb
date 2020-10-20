alicloud_ram_user_name = input(:alicloud_ram_user_name, value: "", description: "AliCloud RAM User's name.")
alicloud_ram_access_key_id = input(:alicloud_ram_access_key_id, value: "", description: "AliCloud Access Key ID")

title "Test AliCloud access keys group"

control "alicloud-access-keys-1.0" do
  impact 1.0
  title "Ensure Alicloud access key library has correct properties"

  describe alicloud_access_keys do
    it { should exist }
    its("access_key_ids") { should include ENV["ALICLOUD_ACCESS_KEY"] }  # gets key of running user
  end

  describe alicloud_access_keys(alicloud_ram_user_name) do
    it { should exist }
    its("access_key_ids") { should include alicloud_ram_access_key_id }  # gets key of other user
  end
end
