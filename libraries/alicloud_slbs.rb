# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudSlbs < AliCloudResourceBase
  name 'alicloud_slbs'
  desc 'Verifies settings for AliCloud Application Loadbalancers in bulk'
  example "
    # Verify that you have slbs defined
    describe alicloud_slbs do
      it { should exist }
    end
    # Verify you have more than the 1 load balancer
    describe alicloud_slbs do
      its('entries.count') { should be > 1 }
    end
  "

  attr_reader :table

  # FilterTable setup
  FilterTable.create
             .register_column(:created_time_stamps, field: :created_time_stamp)
             .register_column(:load_balancer_ids, field: :load_balancer_id)
             .register_column(:load_balancer_names, field: :load_balancer_name)
             .register_column(:region_id_aliases, field: :region_id_alias)
             .register_column(:address_ip_versions, field: :address_ip_version)
             .register_column(:vswitch_ids, field: :vswitch_id)
             .register_column(:internet_charge_types, field: :internet_charge_type)
             .register_column(:vpc_ids, field: :vpc_id)
             .register_column(:secondary_zone_ids, field: :secondary_zone_id)
             .register_column(:network_types, field: :network_type)
             .register_column(:main_zone_ids, field: :main_zone_id)
             .register_column(:create_times, field: :create_time)
             .register_column(:addresses, field: :address)
             .register_column(:region_ids, field: :region_id)
             .register_column(:address_types, field: :address_type)
             .register_column(:pay_types, field: :pay_type)
             .register_column(:load_balancer_statuses, field: :load_balancer_status)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i[region])
    @table = fetch_data
  end

  def fetch_data
    load_balancer_rows = []

    catch_alicloud_errors do
      @load_balancers = @alicloud.slb_client.request(
        action: 'DescribeLoadBalancers',
        params: {
          'RegionId': opts[:region]
        }
      )['LoadBalancers']['LoadBalancer']
    end

    return [] if !@load_balancers || @load_balancers.empty?

    @load_balancers.map do |load_balancer|
      load_balancer_rows += [{
        created_time_stamp: load_balancer['CreateTimeStamp'],
        load_balancer_id: load_balancer['LoadBalancerId'],
        load_balancer_name: load_balancer['LoadBalancerName'],
        region_id_alias: load_balancer['RegionIdAlias'],
        address_ip_version: load_balancer['AddressIPVersion'],
        vswitch_id: load_balancer['VSwitchId'],
        internet_charge_type: load_balancer['InternetChargeType'],
        vpc_id: load_balancer['VpcId'],
        secondary_zone_id: load_balancer['SlaveZoneId'],
        network_type: load_balancer['NetworkType'],
        main_zone_id: load_balancer['MasterZoneId'],
        create_time: load_balancer['CreateTime'],
        address: load_balancer['Address'],
        region_id: load_balancer['RegionId'],
        address_type: load_balancer['AddressType'],
        pay_type: load_balancer['PayType'],
        load_balancer_status: load_balancer['LoadBalancerStatus']
      }]
    end

    @table = load_balancer_rows
  end

  def to_s
    'AliCloud SLBs'
  end
end
