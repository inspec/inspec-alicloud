# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudSecurityGroup < AliCloudResourceBase
  name 'alicloud_security_group'
  desc 'Verifies settings for an individual AliCloud Security Group'
  example "
  describe alicloud_security_group('sg-12345678') do
    it { should exist }
    it { should_not allow_in(port: 443, ipv4_range: '0.0.0.0/0')}
  end
  "
  attr_reader :description, :group_id, :group_name, :vpc_id, :inbound_rules, :outbound_rules, :inbound_rules_count, :outbound_rules_count

  def initialize(opts = {})
    opts = { group_id: opts } if opts.is_a?(String)
    opts[:group_id] = opts.delete(:id) if opts.key?(:id) # id is an alias for group_id

    super(opts)
    validate_parameters(required: %i(group_id))

    catch_alicloud_errors do
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
    return false unless @inbound_rules.count.positive? and criteria.key?(:port) and criteria.key?(:ipv4_range)
    port = criteria[:port]
    ipv4_range = criteria[:ipv4_range]
    @inbound_rules.each do |rule|
      policy = rule['Policy']
      next unless policy == 'Accept'
      cidr = IPAddr.new(rule['SourceCidrIp'])
      next unless cidr.include?(IPAddr.new(ipv4_range))
      port_start, port_end = rule['PortRange'].split('/').map(&:to_i)
      return true if port >= port_start and port <= port_end
    end
    false
  end

  RSpec::Matchers.alias_matcher :allow_in, :be_allow_in

  def exists?
    !@security_group.nil?
  end

  def to_s
    sg = ''
    sg += "ID: #{@group_id} " if @group_id
    sg += "Name: #{@group_name} " if @group_name
    sg += "VPC ID: #{@vpc_id} " if @vpc_id
    opts.key?(:alicloud_region) ? "ECS Security Group: #{sg} in #{opts[:alicloud_region]}" : "ECS Security Group #{sg}"
  end
end
