alicloud_ram_user_name = input(:alicloud_ram_user_name, value: '', description: "AliCloud IMS User's name.")

title 'Test AliCloud IMS User Properties'

control 'alicloud_ims_user' do
  title 'Ensure AliCloud IMS User has correct attributes.'

  describe alicloud_ims_user(user_principal_name: alicloud_ram_user_name) do
    it { should exist }
    its('status') { should eq 'Active' }
    its('update_date') { should_not be_empty }
    its('password_reset_required') { should eq true }
    its('user_principal_name') { should eq alicloud_ram_user_name }
    its('mfa_bind_required') { should eq false }
  end
end
