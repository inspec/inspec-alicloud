alicloud_ram_user_name              = input(:alicloud_ram_user_name, value: '', description: 'AliCloud RAM User\'s name.')
alicloud_ram_user_display_name      = input(:alicloud_ram_user_display_name, value: '', description: 'AliCloud RAM User\'s display name.')
alicloud_ram_user_mobile            = input(:alicloud_ram_user_mobile, value: '', description: 'AliCloud RAM User\'s mobile.')
alicloud_ram_user_email             = input(:alicloud_ram_user_email, value: '', description: 'AliCloud RAM User\'s Email.')


title "Test single Alicloud RAM user"

control 'alicloud-test-ram-user-1.0' do
    impact 1.0
    title 'Ensure RAM user library has correct properties'

    describe alicloud_ram_user(alicloud_ram_user_name) do
        it { should exist }
        its('update_date') { should_not be_nil }
        its('user_name') { should eq alicloud_ram_user_name }
        its('email') { should eq alicloud_ram_user_email }
        its('user_id') { should_not be_nil }
        its('comments') { should_not be_nil }
        its('display_name') { should eq alicloud_ram_user_display_name }
        its('last_login_date') { should_not be_nil }
        its('create_date') { should_not be_nil }
        its('mobile_phone') { should_not be_nil }
    end
end
