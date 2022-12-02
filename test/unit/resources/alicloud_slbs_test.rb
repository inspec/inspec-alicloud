require 'helper'
require 'alicloud_slbs'
require 'aws-sdk-core'

class AliCloudSlbsConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudSlbs.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudSlbs.new(client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudSlbs.new(unexpected: 9) }
  end
end
