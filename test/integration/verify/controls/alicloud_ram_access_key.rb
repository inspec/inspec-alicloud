title 'Test AliCloud access key'

control 'alicloud-access-key-1.0' do
    impact 1.0
    title 'Ensure Alicloud access key library has correct properties'

    describe alicloud_access_key(ENV['ALICLOUD_ACCESS_KEY']) do
        its('access_key_id') { should eq ENV['ALICLOUD_ACCESS_KEY'] }
        its('status') { should eq 'Active' }
        its('create_date') { should_not be_nil }
    end

    describe alicloud_access_key('not-exists') do
        it { should_not exist }
    end
end
