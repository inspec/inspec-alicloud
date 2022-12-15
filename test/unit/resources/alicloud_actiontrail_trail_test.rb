require 'helper'
require 'alicloud_actiontrail_trail'

class AliCloudActionTrailTrailConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudActionTrailTrail.new }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudActionTrailTrail.new(rubbish: 9) }
  end

  def test_accepts_string_argument
    at = AliCloudActionTrailTrail.new('not-there')
    assert_equal 'not-there', at.trail_name
  end

  def test_accepts_key_value_argument_and_resource_works
    at = AliCloudActionTrailTrail.new(trail_name: 'test-trial')
    assert_equal 'test-trial', at.trail_name
  end
end
