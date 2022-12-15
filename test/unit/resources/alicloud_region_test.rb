require 'helper'
require 'alicloud_region'

class AliCloudRegionConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudRegion.new }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudRegion.new(rubbish: 9) }
  end

  def test_accepts_key_value_argument_and_resource_works
    reg = AliCloudRegion.new(region_name: 'us-east-1')
    assert_equal 'us-east-1', reg.region_name
  end
end
