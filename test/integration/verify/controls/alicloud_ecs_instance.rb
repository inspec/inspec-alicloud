alicloud_instance_id = input(:alicloud_instance_id, value: "", description: "AliCloud test instance ID.")

title "Test single AliCloud ECS Instance"

control "alicloud-instance-1.0" do
  impact 1.0
  title "Ensure Alicloud ECS Instance Class has correct attributes"

  describe alicloud_ecs_instance(instance_id: alicloud_instance_id) do  # gets region from env var
    it { should exist }
    its("description") { should eq "" }
    its("memory") { should eq 8192 }
    its("instance_charge_type") { should eq "PostPaid" }
    its("cpu") { should eq 2 }
    its("instance_network_type") { should eq "vpc" }
    its("public_ip_address") { should_not be_nil }
    its("inner_ip_address") { should_not be_nil }
    its("expired_time") { should_not be_nil }
    its("image_id") { should_not be_nil }
    its("eip_address") { should_not be_nil }
    its("instance_type") { should eq "ecs.g6.large" }
    its("host_name") { should_not be_nil }
    its("vlan_id") { should_not be_nil }
    its("status") { should eq "Running" }
    its("io_optimized") { should eq "optimized" }
    its("request_id") { should_not be_nil }
    its("zone_id") { should_not be_nil }
    its("cluster_id") { should_not be_nil }
    its("stopped_mode") { should eq "Not-applicable" }
    its("dedicated_host_attribute") { should_not be_nil }
    its("security_group_ids") { should_not be_nil }
    its("vpc_attributes") { should_not be_nil }
    its("operation_locks") { should_not be_nil }
    its("internet_charge_type") { should eq "PayByTraffic" }
    its("instance_name") { should_not be_nil }
    its("internet_max_bandwidth_out") { should_not be_nil }
    its("internet_max_bandwidth_in") { should_not be_nil }
    its("serial_number") { should_not be_nil }
    its("creation_time") { should_not be_nil }
    its("region_id") { should_not be_nil }
    its("credit_specification") { should_not be_nil }

  end
end
