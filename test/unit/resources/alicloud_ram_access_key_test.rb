require 'helper'
require 'alicloud_ram_access_key'
require 'aws-sdk-core'

class AliCloudAccessKeyConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudAccessKey.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudAccessKey.new(access_key_id: '', client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudAccessKey.new(unexpected: 9) }
  end
end
