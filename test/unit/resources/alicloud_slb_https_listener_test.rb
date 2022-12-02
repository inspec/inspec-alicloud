require 'helper'
require 'alicloud_slb_https_listener'
require 'aws-sdk-core'

class AliCloudSlbHttpsListenerConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudSlbHttpsListener.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudSlbHttpsListener.new(slb_id: '', listener_port: 443, client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudSlbHttpsListener.new(unexpected: 9) }
  end
end
