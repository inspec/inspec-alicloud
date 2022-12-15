require 'helper'
require 'alicloud_ram_password_policy'
require 'aws-sdk-core'

class AliCloudRamConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudRam.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudRam.new(client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudRam.new(unexpected: 9) }
  end
end
