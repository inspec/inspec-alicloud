title 'Test AliCloud ActionTrails in bulk'

alicloud_action_trail_name = input(:alicloud_action_trail_name, value: '', description: 'Action trail name')

control 'alicloud-actiontrails-1.0' do
  title 'Ensure AliCloud ActionTrail plural resource has the correct properties.'

  describe alicloud_actiontrail_trails do
    it { should exist }
    its('count') { should be >= 1 }
    its('names') { should include alicloud_action_trail_name }
  end
end
