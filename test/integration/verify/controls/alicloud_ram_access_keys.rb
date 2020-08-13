title 'Test AliCloud access keys group'

control 'alicloud-access-keys-1.0' do
    impact 1.0
    title 'Ensure Alicloud access key library has correct properties'

    describe alicloud_access_keys do
        it { should exist }
        its('access_key_ids') { should include ENV['ALICLOUD_ACCESS_KEY'] }  # gets key of running user
    end
end
