require 'helper'
require 'alicloud_vpcs'
require 'aws-sdk-core'

class AliCloudVpcsConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudVpcs.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudVpcs.new(client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudVpcs.new(unexpected: 9) }
  end
end
