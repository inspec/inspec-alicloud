require 'helper'
require 'alicloud_rd'

class AliCloudResourceDirectoryConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudResourceDirectory.new(rubbish: 9) }
  end

  def test_accepts_key_value_argument_and_resource_works
    rd = AliCloudResourceDirectory.new
    assert_equal nil, rd.resource_directory_id
    assert_equal nil, rd.master_account_name
    assert_equal nil, rd.master_account_id
  end
end
