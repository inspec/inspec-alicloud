alicloud_slb_https_id = input(:alicloud_slb_https_id, value: '', description: 'AliCloud slb https ID.')

title 'Test single AliCloud Server Load Balance HTTPS Listener'

control 'alicloud_slb_https_listener-1.0' do
  title 'Ensure AliCloud Server Load Balancer has the correct properties.'

  describe alicloud_slb_https_listener(slb_id: alicloud_slb_https_id, listener_port: 443) do
    it { should exist }
  end

  alicloud_slb(alicloud_slb_https_id).https_ports.each do |port|
    describe alicloud_slb_https_listener(slb_id: alicloud_slb_https_id, listener_port: port) do
      its('tls_cipher_policy') { should eq 'tls_cipher_policy_1_2' }
    end
  end
end
