require 'helper'
require 'alicloud_ims_sso'

class AliCloudSsoSettingsConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'
  end
  
  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudSsoSettings.new(rubbish: 9) }
  end
  
  def test_accepts_key_value_argument_and_resource_works
    ss = AliCloudSsoSettings.new
    assert_equal false, ss.sso_enabled
    assert_equal nil, ss.auxiliary_domain
  end
end
