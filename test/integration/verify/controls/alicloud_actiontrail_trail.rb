title "Test single AliCloud ActionTrail"

alicloud_action_trail_name = input(:alicloud_action_trail_name, value: "", description: "Action trail name")
alicloud_action_trail_bucket_id = input(:alicloud_action_trail_bucket_id, value: "", description: "Action trail bucket name")

control "alicloud-actiontrail-1.0" do
  impact 1.0
  title "Ensure AliCloud Action Trail has the correct properties."

  describe alicloud_actiontrail_trail(alicloud_action_trail_name) do
    it { should exist }
  end

  describe alicloud_actiontrail_trail("not-there-trail") do
    it { should_not exist }
  end

  describe alicloud_actiontrail_trail(trail_name: alicloud_action_trail_name) do
    it { should exist }
    its("oss_bucket_name") { should eq alicloud_action_trail_bucket_id }
    its("delivered_logs_days_ago") { should eq 0 }
    its("status") { should cmp "Enable" }
    its("trail_region") { should cmp "All" }
  end
end
