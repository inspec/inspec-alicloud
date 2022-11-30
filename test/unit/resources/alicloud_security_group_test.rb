require 'helper'
require 'alicloud_security_group'
require 'aws-sdk-core'

class AliCloudSecurityGroupConstructorTest < Minitest::Test

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudSecurityGroup.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudSecurityGroup.new(group_id: '', client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudSecurityGroup.new(unexpected: 9) }
  end
end
