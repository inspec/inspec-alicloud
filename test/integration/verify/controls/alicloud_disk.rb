alicloud_disk_id = input(:alicloud_disk_id, value: '', description: 'AliCloud Disk ID.')
alicloud_disk_name = input(:alicloud_disk_name, value: '', description: 'AliCloud Disk Name.')
alicloud_disk_desc = input(:alicloud_disk_desc, value: '', description: 'AliCloud Disk Desc.')
alicloud_disk_size = input(:alicloud_disk_size, value: '', description: 'AliCloud Disk Size.')
alicloud_disk_category = input(:alicloud_disk_category, value: '', description: 'AliCloud Disk Category.')
alicloud_disk_encrypted = input(:alicloud_disk_encrypted, value: '', description: 'AliCloud Disk Encrypted.')
alicloud_disk_delete_with_instance = input(:alicloud_disk_delete_with_instance, value: '', description: 'AliCloud Disk DeleteWithInstance.')
alicloud_disk_enable_auto_snapshot = input(:alicloud_disk_enable_auto_snapshot, value: '', description: 'AliCloud Disk EnableAutoSnapshot.')
alicloud_disk_delete_auto_snapshot = input(:alicloud_disk_delete_auto_snapshot, value: '', description: 'AliCloud Disk DeleteAutoSnapshot.')

title 'Test single AliCloud Disk'

control 'alicloud-disk-1.0' do
  title 'Ensure AliCloud Disk has the correct properties.'

  describe alicloud_disk(disk_id: 'd-nosuchdisk') do
    it { should_not exist }
  end

  describe alicloud_disk(disk_id: alicloud_disk_id) do
    it { should exist }
    its('id') { should eq alicloud_disk_id }
    its('name') { should eq alicloud_disk_name }
    its('description') { should cmp alicloud_disk_desc }
    its('size') { should cmp alicloud_disk_size }
    its('category') { should cmp alicloud_disk_category }
    its('encrypted') { should cmp alicloud_disk_encrypted }
    its('delete_with_instance') { should cmp alicloud_disk_delete_with_instance }
    its('enable_auto_snapshot') { should cmp alicloud_disk_enable_auto_snapshot }
    its('delete_auto_snapshot') { should cmp alicloud_disk_delete_auto_snapshot }
  end

  describe alicloud_disk(disk_name: alicloud_disk_name) do
    it { should exist }
    its('id') { should eq alicloud_disk_id }
    its('name') { should eq alicloud_disk_name }
  end

  describe alicloud_disk(disk_id: alicloud_disk_id, region: 'us-west-1') do
    it { should_not exist }
  end
end
