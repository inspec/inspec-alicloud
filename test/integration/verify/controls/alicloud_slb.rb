alicloud_slb_http_id = input(:alicloud_slb_http_id, value: "", description: "AliCloud slb http ID.")
alicloud_slb_https_id = input(:alicloud_slb_https_id, value: "", description: "AliCloud slb https ID.")

title "Test single AliCloud Server Load Balancer"

control "alicloud-slb-1.0" do
  impact 1.0
  title "Ensure AliCloud Server Load Balancer has the correct properties."

  describe alicloud_slb(slb_id: "no-such-slb") do
    it { should_not exist }
  end

  describe alicloud_slb(alicloud_slb_http_id) do
    it { should exist }
    its("https_listeners?") { should eq false }
    its("https_only?") { should eq false }
  end

  describe alicloud_slb(alicloud_slb_https_id) do
    it { should exist }
    its("https_listeners?") { should eq true }
    its("https_only?") { should eq true }
  end

  describe alicloud_slb(slb_id: alicloud_slb_https_id, region: "us-west-1") do
    it { should_not exist }
  end

  ### test slb_https_listener
  alicloud_slb(alicloud_slb_https_id).https_ports.each do |port|
    describe alicloud_slb_https_listener(slb_id: alicloud_slb_https_id, listener_port: port) do
      its("tls_cipher_policy") { should eq "tls_cipher_policy_1_2" }
    end
  end

end
