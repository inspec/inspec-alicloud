require 'helper'
require 'alicloud_regions'

class AliCloudRegionsConstructorTest < Minitest::Test
  def setup
    ENV['ALICLOUD_REGION'] = 'us-east-1'

    AliCloudRegions.any_instance.stubs(:fetch_data).returns({ 'Items' =>
                                                                { 'DescribeRegions' =>
                                                                    { 'Regions' =>
                                                                        [{ 'RegionEndpoint' => 'vpc.aliyuncs.com',
                                                                           'LocalName' => '华北 1',
                                                                           'RegionId' => 'cn-qingdao',
                                                                         }]
                                                                    }
                                                                }
                                                            })
  end
  
  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudRegions.new(rubbish: 9) }
  end
  
  def test_rejects_string_argument
    assert_raises(ArgumentError) { AliCloudRegions.new('not-there') }
  end
end
