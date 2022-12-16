require 'helper'
require 'alicloud_ims_sso'

class AliCloudSsoSettingsConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudSsoSettings.new(rubbish: 9) }
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudSsoSettings.new(client_args: { stub_responses: true }) }
  end
end
