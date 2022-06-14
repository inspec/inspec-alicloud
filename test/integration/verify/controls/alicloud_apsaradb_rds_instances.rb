# frozen_string_literal: true

alicloud_rds_db_id = attribute(:alicloud_rds_db_id, value: '', description: 'The Alicloud RDS DB identifier.')

title 'Test multiple Alicloud ApsaraDB RDS Instances'
control 'alicloud-apsaradb-rds-instances-1.0' do
  impact 1.0
  title 'Ensure Alicloud ApsaraDB RDS Instances have the correct properties.'

  describe alicloud_apsaradb_rds_instances do
    it { should exist }
    its('db_instance_ids') { should include alicloud_rds_db_id }
  end

  alicloud_apsaradb_rds_instances.db_instance_ids.each do |db_instance_id|
    describe alicloud_apsaradb_rds_instance(db_instance_id) do
      its('in_default_vpc') { should be false }
      its('security_ips') { should_not cmp '' }
      its('security_ips') { should_not include '0.0.0.0/0' }
    end
  end
end
