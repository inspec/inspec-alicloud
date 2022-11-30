require 'helper'
require 'alicloud_oss_buckets'
require 'aws-sdk-core'

class AliCloudOssBucketsConstructorTest < Minitest::Test
  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudOssBuckets.new(client_args: { stub_responses: true }) }
  end

  def test_empty_param_arg_not_ok
    assert_raises(ArgumentError) { AliCloudOssBuckets.new(app_id: '', client_args: { stub_responses: true }) }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudOssBuckets.new(unexpected: 9) }
  end
end
