require 'helper'
require 'alicloud_regions'

class AliCloudRegionsConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudRegions.new(rubbish: 9) }
  end

  def test_rejects_string_argument
    assert_raises(ArgumentError) { AliCloudRegions.new('not-there') }
  end
end
