require 'helper'
require 'alicloud_slb'
require 'aws-sdk-core'

class AliCloudSlbConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudSlb.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudSlb.new(slb_id: '', client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudSlb.new(unexpected: 9) }
  end
end
