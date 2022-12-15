alicloud_instance_id = input(:alicloud_instance_id, value: '', description: 'AliCloud test instance ID.')

title 'Test AliCloud ECS Group resource'

control 'alicloud-instances-1.0' do
  title 'Ensure AliCloud ECS Instances Class has correct attributes'

  describe alicloud_ecs_instances do  # gets region from env var
    it { should exist }
    its('entries.count') { should be >= 1 }
  end

  describe alicloud_ecs_instances.where(deletion_protection: false) do
    its('instance_ids') { should include alicloud_instance_id }
  end

  describe(alicloud_ecs_instances.where { ram_role.count == 1 }) do
    its('instance_ids') { should include alicloud_instance_id }
  end
end
