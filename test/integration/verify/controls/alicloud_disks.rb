# frozen_string_literal: true

title 'Test AliCloud Disk in bulk'

control 'alicloud-disks-1.0' do
  impact 1.0
  title 'Ensure AliCloud disk plural resource has the correct properties.'

  # Verify that you have disks defiend
  describe alicloud_disks do
    it { should exist }
  end

  # Verify you have more than 1 disk
  describe alicloud_disks do
    its('entries.count') { should be > 1 }
  end

  # Ensure auto snapshot is turned on for all disks
  describe alicloud_disks.where(enable_auto_snapshot: false) do
    it { should_not exist }
    its('ids') { should cmp [] }
  end
end
