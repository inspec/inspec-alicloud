require 'helper'
require 'alicloud_sts_caller_identity'
require 'aws-sdk-core'

class AliCloudStsCallerIdentityConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudStsCallerIdentity.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudStsCallerIdentity.new(client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudStsCallerIdentity.new(unexpected: 9) }
  end
end
