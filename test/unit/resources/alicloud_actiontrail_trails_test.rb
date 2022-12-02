require 'helper'
require 'alicloud_actiontrail_trails'

class AliCloudActionTrailTrailsConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudActionTrailTrails.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudActionTrailTrails.new(client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudActionTrailTrails.new(rubbish: 9) }
  end

  def test_rejects_string_argument
    assert_raises(ArgumentError) { AliCloudActionTrailTrails.new('not-there') }
  end
end
