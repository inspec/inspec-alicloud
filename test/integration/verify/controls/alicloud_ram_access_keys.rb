title 'Test AliCloud access keys group'

control 'alicloud-access-keys-1.0' do
    impact 1.0
    title 'Ensure Alicloud access key library has correct properties'

    describe alicloud_access_keys do
        its('entries.count')  { should eq 1 }
        its('entries.first.access_key_id') { should eq ENV['ALICLOUD_ACCESS_KEY'] }  # gets key of running user
        its('entries.first.status') { should eq "Active" }
        its('entries.first.create_date') { should_not be_nil }
    end
end
