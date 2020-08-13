title "Test single Alicloud RAM user"

control 'alicloud-test-ram-users-1.0' do
    impact 1.0
    title 'Ensure RAM user list library has correct properties'

    describe alicloud_ram_users do
        its('entries.count') { should be > 1 }
    end
end
