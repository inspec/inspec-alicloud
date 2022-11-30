require 'helper'
require 'alicloud_ram_access_keys'
require 'aws-sdk-core'

class AliCloudAccessKeysConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudAccessKeys.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudAccessKeys.new(client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudAccessKeys.new(unexpected: 9) }
  end
end
