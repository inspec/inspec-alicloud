alicloud_instance_id = input(:alicloud_instance_id, value: '', description: 'AliCloud test instance ID.')


title 'Test single AliCloud ECS Instance'

control 'alicloud-instance-1.0' do
    impact 1.0
    title 'Ensure Alicloud ECS Instance Class has correct attributes'

    describe alicloud_ecs_instance(instance_id: alicloud_instance_id) do
        it { should exist }
    end
end