# frozen_string_literal: true

alicloud_rds_db_id = attribute(:alicloud_rds_db_id, value: '', description: 'The Alicloud RDS DB identifier.')
alicloud_rds_db_name = attribute(:alicloud_rds_db_name, value: '', description: 'The Alicloud RDS DB name.')
alicloud_rds_db_engine = attribute(:alicloud_rds_db_engine, value: '', description: 'The Alicloud RDS DB engine.')
alicloud_rds_db_engine_version = attribute(:alicloud_rds_db_engine_version, value: '',
                                                                            description: 'The Alicloud RDS DB engine version.')
alicloud_rds_storage = attribute(:alicloud_rds_storage, value: '', description: 'The Alicloud RDS allocated storage.')
alicloud_rds_instance_type = attribute(:alicloud_rds_instance_type, value: '',
                                                                    description: 'The Alicloud RDS instance type.')
alicloud_rds_vpc_id = attribute(:alicloud_vpc_id, value: '', description: 'The Alicloud VPC ID for the DB.')
alicloud_rds_security_ips = attribute(:alicloud_vpc_cidr, value: '', description: 'The Alicloud RDS security IPs.')

title 'Test single Alicloud ApsaraDB RDS Instance'
control 'alicloud-apsaradb-rds-instance-1.0' do
  impact 1.0
  title 'Ensure Alicloud ApsaraDB RDS Instance has the correct properties.'

  describe alicloud_apsaradb_rds_instance(db_instance_id: alicloud_rds_db_id) do
    it { should exist }
    its('instance_id') { should eq alicloud_rds_db_id }
    its('description') { should eq alicloud_rds_db_name }
    its('instance_type') { should eq 'Primary' }
    its('category') { should eq 'Basic' }
    its('engine') { should eq alicloud_rds_db_engine }
    its('engine_version') { should eq alicloud_rds_db_engine_version }
    its('allocated_storage') { should cmp alicloud_rds_storage }
    its('storage_type') { should eq 'cloud_ssd' }
    its('memory') { should cmp '1024' }
    its('cpus') { should cmp '1' }
    its('instance_class') { should eq alicloud_rds_instance_type }
    its('network_type') { should eq 'VPC' }
    its('net_type') { should eq 'Intranet' }
    its('vpc_id') { should eq alicloud_rds_vpc_id }
    its('in_default_vpc') { should be false }
    its('security_ips') { should_not cmp '' }
    its('security_ips') { should_not include '0.0.0.0/0' }
    its('security_ips') { should include alicloud_rds_security_ips }
    its('security_ip_mode') { should eq 'normal' }
    its('status') { should eq 'Running' }
    its('pay_type') { should eq 'Postpaid' }
  end

  describe alicloud_apsaradb_rds_instance(alicloud_rds_db_id) do
    it { should exist }
  end

  describe alicloud_apsaradb_rds_instance('not-there') do
    it { should_not exist }
  end
end
