# no terraform module for mfa yet https://www.terraform.io/docs/providers/alicloud/index.html
# alicloud_ram_user_name = input(:alicloud_ram_user_name, value: "", description: "AliCloud RAM User's name.")
# alicloud_ram_user_mfa_serial_number   = input(:alicloud_ram_user_mfa_serial_number, value: '', description: 'AliCloud RAM User\'s mfa serial number.')

title 'Test AliCloud RAM User MFA'

control 'alicloud-ram-user-mfa-1.0' do
  title 'Ensure AliCloud RAM user MFA library has correct properties'

  # describe alicloud_ram_user_mfa(alicloud_ram_user_name) do
  #   it { should exist }
  #   its('serial_number') { should eq alicloud_ram_user_mfa_serial_number }
  #   its('type') { should eq 'VMFA' }
  # end
end
