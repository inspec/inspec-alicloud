require 'helper'
require 'alicloud_vpc'
require 'aws-sdk-core'

class AliCloudVpcConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudVpc.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudVpc.new(vpc_id: '', client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudVpc.new(unexpected: 9) }
  end
end
