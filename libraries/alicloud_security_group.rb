require 'alicloud_backend'

class AliCloudSecurityGroup < AliCloudResourceBase
  name 'alicloud_security_group'
  desc 'Verifies settings for an individual AliCloud Security Group.'
  example <<-EXAMPLE
    describe alicloud_security_group('sg-1234567890') do
      it { should exist }
      it { should_not allow_in(port: 443, ipv4_range: '0.0.0.0/0')}
    end
  EXAMPLE

  attr_reader :description, :group_id, :group_name, :vpc_id, :inbound_rules, :outbound_rules, :inbound_rules_count,
              :outbound_rules_count

  def initialize(opts = {})
    opts = { group_id: opts } if opts.is_a?(String)
    opts[:group_id] = opts.delete(:id) if opts.key?(:id) # id is an alias for group_id
    @opts = opts
    super(opts)
    validate_parameters(required: %i(group_id region))

    catch_alicloud_errors(ignore: 'InvalidSecurityGroupId.NotFound') do
      @resp = @alicloud.ecs_client.request(
        action: 'DescribeSecurityGroupAttribute',
        params: {
          "RegionId": opts[:region],
          "SecurityGroupId": opts[:group_id],
        },
      )
    end

    if @resp.nil?
      @inbound_rules = []
      @outbound_rules = []
      @group_id = 'empty response'
      return
    end

    @security_group = @resp
    @group_id       = @security_group['SecurityGroupId']
    @vpc_id         = @security_group['VpcId']
    @description    = @security_group['Description']
    @group_name     = @security_group['SecurityGroupName']
    @inbound_rules  = @security_group['Permissions']['Permission'].select { |r| r['Direction'] == 'ingress' }
    @outbound_rules = @security_group['Permissions']['Permission'].select { |r| r['Direction'] == 'egress' }

    @inbound_rules_count = @inbound_rules.count
    @outbound_rules_count = @outbound_rules.count
  end

  def allow_in?(criteria = {})
    return false unless @inbound_rules.count.positive? && (criteria.key?(:ipv4_range) || criteria.key?(:ipv6_range) || \
    criteria.key?(:port))

    # Port is an optional parameter so we can write controls against CIDR masks only
    port = criteria[:port] unless criteria[:port].nil?
    ipv4_range = criteria[:ipv4_range] unless criteria[:ipv4_range].nil?
    ipv6_range = criteria[:ipv6_range] unless criteria[:ipv6_range].nil?

    if ipv4_range.nil? && ipv6_range.nil? && !port.nil?
      @inbound_rules.each do |rule|
        port_start, port_end = rule['PortRange'].split('/').map(&:to_i)
        return true if (port >= port_start) && (port <= port_end)
      end
    else
      @inbound_rules.each do |rule|
        # If our rule has a securitygroup ID or IP address familiy does not match the one in criteria, skip it...
        next if !rule['SourceGroupId'].empty? || (criteria.key?(:ipv4_range) && rule['SourceCidrIp'].empty?) \
        || (criteria.key?(:ipv6_range) && rule['Ipv6SourceCidrIp'].empty?)

        policy = rule['Policy']
        next unless policy == 'Accept'

        cidr = IPAddr.new(rule['SourceCidrIp'], Socket::AF_INET) unless rule['SourceCidrIp'].empty?
        cidr_6 = IPAddr.new(rule['Ipv6SourceCidrIp'], Socket::AF_INET6) unless rule['Ipv6SourceCidrIp'].empty?

        # If the authorized source address does not include IP range in the criteria, skip it...
        next if (!rule['SourceCidrIp'].empty? && !cidr.include?(IPAddr.new(ipv4_range, Socket::AF_INET))) ||
          (!rule['Ipv6SourceCidrIp'].empty? && !cidr_6.include?(IPAddr.new(ipv6_range, Socket::AF_INET6)))

        # This block is conditional on 'port' having been passed in, otherwise we only care about the previous two checks
        if port.nil?
          return true
        else
          port_start, port_end = rule['PortRange'].split('/').map(&:to_i)
          return true if (port >= port_start) && (port <= port_end)
        end
      end
    end
    false
  end

  RSpec::Matchers.alias_matcher :allow_in, :be_allow_in

  def exists?
    !@security_group.nil?
  end

  def resource_id
    @group_id
  end

  def to_s
    if @group_id
      sg = "AliCloud Security GroupId: #{@group_id}"
      sg += "AliCloud Security GroupName: #{@group_name}" if @group_name
      sg += "AliCloud Security VPC ID: #{@vpc_id}" if @vpc_id
    else
      sg = "AliCloud Security GroupId #{opts[:group_id]}"
    end
    opts.key?(:region) ? "AliCloud ECS Security Group:#{sg} in #{opts[:region]}" : "ECS Security Group#{sg}"
  end
end
