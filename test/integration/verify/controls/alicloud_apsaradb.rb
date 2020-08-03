title 'Test single AliCloud ApsaraDB instance'

alicoud_db_instance_region = input(:alicloud_db_instance_region, value: '', description: 'DB Instance region')
alicoud_db_instance_id = input(:alicoud_db_instance_id, value: '', description: 'DB Instance unique ID')

puts "db whatever"
puts "#{alicoud_db_instance_region}"
puts "#{alicoud_db_instance_id}"

control 'alicloud-apsaradb-1.0' do
    impact 1.0
    title 'Ensure Alicloud ApsaraDB instance has correct properties'

    describe alicloud_apsaradb_instance(region: alicoud_db_instance_region, db_instance_id: alicoud_db_instance_id) do
        it { should exist }
    end

end