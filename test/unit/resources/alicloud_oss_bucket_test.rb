require 'helper'
require 'alicloud_oss_bucket'
require 'aws-sdk-core'

class AliCloudOssBucketConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudOssBucket.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudOssBucket.new(bucket_name: '', client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudOssBucket.new(unexpected: 9) }
  end
end
