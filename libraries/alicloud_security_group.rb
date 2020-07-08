# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudSecurityGroup < AliCloudResourceBase
  name 'alicloud_security_group'
  desc 'Verifies settings for an individual AliCloud Security Group'
  example "
  describe alicloud_security_group('sg-12345678') do
    it { should exist }
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
