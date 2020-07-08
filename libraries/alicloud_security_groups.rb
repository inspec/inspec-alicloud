# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudSecurityGroups < AliCloudResourceBase
  name 'alicloud_security_groups'
  desc 'Verifies settings for AliCloud Security Groups in bulk'
  example "
    # Verify that you have security groups defined
    describe alicloud_security_groups do
      it { should exist }
    end

    # Verify you have more than the default security group
    describe alicloud_security_groups do
      its('entries.count') { should be > 1 }
    end
  "

  attr_reader :table

  # FilterTable setup
  FilterTable.create
             .register_column(:group_ids, field: :group_id)
             .register_column(:group_descriptions, field: :group_description)
             .register_column(:vpc_ids, field: :vpc_id)
             .register_column(:tags, field: :tags)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters
    @table = fetch_data
  end

  def fetch_data
    security_group_rows = []

    catch_alicloud_errors do
      @security_groups = @alicloud.ecs_client.request(
        action: 'DescribeSecurityGroups',
        params: {
          "RegionId": opts[:region],
        },
      )['SecurityGroups']['SecurityGroup']
    end

    return [] if !@security_groups || @security_groups.empty?
    @security_groups.map do |security_group|
      security_group_rows += [{
        group_id: security_group['SecurityGroupId'],
        group_description: security_group['Description'],
        vpc_id: security_group['VpcId'],
        tags: security_group['Tags']['Tag'],
      }]
    end

    @table = security_group_rows
  end
end
