# frozen_string_literal: true

require "alicloud_backend"

class AliCloudVpc < AliCloudResourceBase
  name "alicloud_vpc"
  desc "Verifies properties for an individual AliCloud Virtual Private Network"
  example "
  describe alicloud_vpc('vpc-1234567890') do
    it { should exist }
  end
  "
  attr_reader :vpc_id, :vpc_name, :description, :status, :created_time_stamp, :is_default, :resource_group_id,
              :cidr_block, :ipv6_cidr_block, :vrouter_id, :vswitch_ids, :user_cidrs, :attached_cens

  def initialize(opts = {})
    opts = { vpc_id: opts } if opts.is_a?(String)
    @opts = opts
    super(opts)
    validate_parameters(required: %i{vpc_id region})

    catch_alicloud_errors do
      @resp = @alicloud.vpc_client.request(
        action: "DescribeVpcAttribute",
        params: {
          'RegionId': opts[:region],
          'VpcId': opts[:vpc_id],
        }
      )
    end

    # DescribeVpcAttribute will always return a hash with all attributes set to empty string even if the given VpcId is incorrect.
    if @resp.nil? || @resp["VpcId"].empty?
      @vpc_id = "empty response"
      return
    end

    @vpc_info           = @resp
    @vpc_id             = @vpc_info["VpcId"]
    @vpc_name           = @vpc_info["VpcName"]
    @description        = @vpc_info["Description"]
    @status             = @vpc_info["Status"]
    @created_time_stamp = @vpc_info["CreationTime"]
    @is_default         = @vpc_info["IsDefault"]
    @resource_group_id  = @vpc_info["ResourceGroupId"]
    @cidr_block         = @vpc_info["CidrBlock"]
    @ipv6_cidr_block    = @vpc_info["Ipv6CidrBlock"]
    @vrouter_id         = @vpc_info["VRouterId"]
    @vswitch_ids        = @vpc_info["VSwitchIds"]["VSwitchId"]
    @user_cidrs         = @vpc_info["UserCidrs"]["UserCidr"]
    @attached_cens      = []
    # AssociatedCens will only be returned when the VPC is attached to CEN
    return if @vpc_info["AssociatedCens"].nil?

    @vpc_info["AssociatedCens"]["AssociatedCen"].each do |cen|
      @attached_cens.append(cen["CenId"])
    end
  end

  def exists?
    !@vpc_info.nil?
  end

  def cen_attached?
    !@attached_cens.empty?
  end

  def to_s
    "Virtual Private Cloud #{@opts[:vpc_id]}"
  end
end
