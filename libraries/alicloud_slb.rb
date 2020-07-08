# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudSlb < AliCloudResourceBase
  name 'alicloud_slb'
  desc 'Verifies properties for an individual AliCloud Application Load Balancer'
  example "
  describe alicloud_slb('slb-123456') do
    it { should exist }
  end
  "
  attr_reader :load_balancer_id, :load_balancer_name, :status, :resource_group_id, :address, :listener_ports_and_protocol, :backend_servers,
              :has_reserved_info, :business_status, :listener_ports, :vswitch_id, :pay_type, :internet_charge_type,
              :vpc_id, :delete_protection, :end_time_stamp, :end_time, :support_private_link, :address_ip_version,
              :network_type, :bandwidth, :primary_zone_id, :create_time, :secondary_zone_id, :region_id_alias,
              :region_id, :address_type, :create_time_stamp

  def initialize(opts = {})
    opts = { slb_id: opts } if opts.is_a?(String)
    opts[:slb_id] = opts.delete(:id) if opts.key?(:id)

    super(opts)
    validate_parameters(required: %i(slb_id))
    catch_alicloud_errors do
      @resp = @alicloud.slb_client.request(
        action: 'DescribeLoadBalancerAttribute',
        params: {
          'RegionId': opts[:region],
          'LoadBalancerId': opts[:slb_id],
        }
     )
    end

    if @resp.nil?
      @slb_id = 'empty response'
      return
    end

    @slb_info                    = @resp
    @load_balancer_id            = @slb_info['LoadBalancerId']
    @load_balancer_name          = @slb_info['LoadBalancerName']
    @status                      = @slb_info['LoadBalancerStatus']
    @resource_group_id           = @slb_info['ResourceGroupId']
    @address                     = @slb_info['Address']
    @listener_ports_and_protocol = @slb_info['ListenerPortsAndProtocol']['ListenerPortAndProtocol']
    @backend_servers             = @slb_info['BackendServers']
    @has_reserved_info           = @slb_info['HasReservedInfo']
    @business_status             = @slb_info['BusinessStatus']
    @listener_ports              = @slb_info['ListenerPorts']
    @vswitch_id                  = @slb_info['VSwitchId']
    @pay_type                    = @slb_info['PayType']
    @internet_charge_type        = @slb_info['InternetChargeType']
    @vpc_id                      = @slb_info['VpcId']
    @delete_protection           = @slb_info['DeleteProtection']
    @end_time_stamp              = @slb_info['EndTimeStamp']
    @end_time                    = @slb_info['EndTime']
    @support_private_ling        = @slb_info['SupportPrivateLink']
    @address_ip_version          = @slb_info['AddressIPVersion']
    @network_type                = @slb_info['NetworkType']
    @bandwidth                   = @slb_info['Bandwidth']
    @primary_zone_id             = @slb_info['MasterZoneId']
    @create_time                 = @slb_info['CreateTime']
    @secondary_zone_id           = @slb_info['SlaveZoneId']
    @region_id_alias             = @slb_info['RegionIdAlias']
    @region_id                   = @slb_info['RegionId']
    @address_type                = @slb_info['AddressType']
    @create_time_stamp           = @slb_info['CreateTimeStamp']
  end

  def exists?
    !@slb_info.nil?
  end

  def https_listeners?
    @listener_ports_and_protocol.select { |lpp| lpp['ListenerProtocol'] == 'https' }.length > 0
  end

  def http_listeners?
    @listener_ports_and_protocol.select { |lpp| lpp['ListenerProtocol'] == 'http' }.length > 0
  end

  def udp_listeners?
    @listener_ports_and_protocol.select { |lpp| lpp['ListenerProtocol'] == 'udp' }.length > 0
  end

  def tcp_listeners?
    @listener_ports_and_protocol.select { |lpp| lpp['ListenerProtocol'] == 'tcp' }.length > 0
  end

  def listening_ports
    @listener_ports_and_protocol.select { |lpp| lpp['ListenerPort'] }
  end

  def https_ports
    @listener_ports_and_protocol.map { |lpp| lpp['ListenerPort'] if lpp['ListenerProtocol'] == 'https'}.compact
  end

  def http_ports
    @listener_ports_and_protocol.map { |lpp| lpp['ListenerPort'] if lpp['ListenerProtocol'] == 'http'}.compact
  end

  def udp_ports
    @listener_ports_and_protocol.map { |lpp| lpp['ListenerPort'] if lpp['ListenerProtocol'] == 'udp'}.compact
  end

  def tcp_ports
    @listener_ports_and_protocol.map { |lpp| lpp['ListenerPort'] if lpp['ListenerProtocol'] == 'tcp'}.compact
  end

  def https_only?
    https_ports.length == listening_ports.length
  end

  def to_s
    slb = ''
    slb += "ID: #{@load_balancer_id} " if @load_balancer_id
    slb += "Name: #{@load_balancer_name} " if @load_balancer_name
    opts.key?(:region) ? "Server Load Balancer: #{slb} in #{opts[:region]}" : "Server Load Balancer: #{slb}"
  end
end
