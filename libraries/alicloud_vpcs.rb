# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudVpcs < AliCloudResourceBase
  name 'alicloud_vpcs'
  desc 'Verifies settings for AliCloud Virtual Private Cloud in bulk.'
  example <<-EXAMPLE
    # Verify that you have vpcs defined
    describe alicloud_vpcs do
      it { should exist }
    end
    # Verify you have more than the 1 vpc
    describe alicloud_vpcs do
      its('entries.count') { should be > 1 }
    end
  EXAMPLE

  attr_reader :table

  # FilterTable setup
  FilterTable.create
             .register_column(:vpc_ids, field: :vpc_id)
             .register_column(:vpc_names, field: :vpc_name)
             .register_column(:descriptions, field: :description)
             .register_column(:statuses, field: :status)
             .register_column(:created_time_stamps, field: :created_time_stamp)
             .register_column(:is_defaults, field: :is_default)
             .register_column(:cen_statuses, field: :cen_status)
             .register_column(:resource_group_ids, field: :resource_group_id)
             .register_column(:cidr_blocks, field: :cidr_block)
             .register_column(:ipv6_cidr_blocks, field: :ipv6_cidr_block)
             .register_column(:vrouter_ids, field: :vrouter_id)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(region))
    @table = fetch_data
  end

  def fetch_data
    vpc_rows = []

    catch_alicloud_errors do
      @vpcs = @alicloud.vpc_client.request(
        action: 'DescribeVpcs',
        params: {
          'RegionId': opts[:region],
        },
      )['Vpcs']['Vpc']
    end

    return [] if !@vpcs || @vpcs.empty?

    @vpcs.map do |vpc|
      vpc_rows += [{
        vpc_id: vpc['VpcId'],
        vpc_name: vpc['VpcName'],
        description: vpc['Description'],
        status: vpc['Status'],
        created_time_stamp: vpc['CreationTime'],
        is_default: vpc['IsDefault'],
        cen_status: vpc['CenStatus'],
        resource_group_id: vpc['ResourceGroupId'],
        cidr_block: vpc['CidrBlock'],
        ipv6_cidr_block: vpc['Ipv6CidrBlock'],
        vrouter_id: vpc['VRouterId'],
      }]
    end

    @table = vpc_rows
  end

  def to_s
    'AliCloud VPCs'
  end
end
