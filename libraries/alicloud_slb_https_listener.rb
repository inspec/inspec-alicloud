# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudSlbHttpsListener < AliCloudResourceBase
  name 'alicloud_slb_https_listener'
  desc 'Verifies properties for an individual AliCloud Application Load Balancers https listener'
  example "
  describe alicloud_slb_https_listener(slb_id: 'slb-123456', listener_port: 443) do
    it { should exist }
  end
  "
  attr_reader :load_balancer_id, :tls_cipher_policy, :listener_port

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(slb_id listener_port))

    catch_alicloud_errors do
      @resp = @alicloud.slb_client.request(
        action: 'DescribeLoadBalancerHTTPSListenerAttribute',
        params: {
          'RegionId': opts[:region],
          'LoadBalancerId': opts[:slb_id],
          'ListenerPort': opts[:listener_port],
        },
      )
    end

    if @resp.nil?
      @tls_cipher_policy = nil
      return
    end

    @listener_info = @resp
    @load_balancer_id = opts[:slb_id]
    @tls_cipher_policy = @listener_info['TLSCipherPolicy']
    @listener_port = @listener_info['ListenerPort']
  end

  def exists?
    !@listener_info.nil?
  end

  # SB: mvp for q3 - this catch-all should allow some flexibility
  def method_missing(name)
    @listener_info[name.to_s]
    super
  end

  def to_s
    buf = ''
    buf += "Load balancer id: #{@load_balancer_id} " if @load_balancer_id
    buf += "Port: #{@listener_port} " if @listener_port
    opts.key?(:alicloud_region) ? "https_listener: #{buf} in #{opts[:alicloud_region]}" : "https_listener: #{buf}"
  end
end
