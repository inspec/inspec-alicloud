# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudRegion < AliCloudResourceBase
  name 'alicloud_region'
  desc 'Verifies settings for an AliCloud region'

  example "
    describe alicloud_region('eu-west-1') do
      it { should exist }
    end
  "
  attr_reader :region_name, :endpoint, :region_local_name

  def initialize(opts = {})
    opts = { region_name: opts } if opts.is_a?(String)

    super(opts)
    validate_parameters(required: %i(region_name region))

    @region_name = opts[:region_name]
    catch_alicloud_errors do
      @regions = @alicloud.ecs_client.request(action: 'DescribeRegions')['Regions']['Region']
      resp = @regions.find { |r| r['RegionId'] == @region_name }
      return if resp.nil?

      @endpoint = resp['RegionEndpoint']
      @region_local_name = resp['LocalName']
    end
  end

  def exists?
    !@endpoint.nil?
  end

  def resource_id
    @region_name
  end

  def to_s
    "Region #{@region_name}"
  end
end
