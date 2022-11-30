require 'helper'
require 'alicloud_rd'

class AliCloudResourceDirectoryConstructorTest < Minitest::Test
  def setup
    AliCloudResourceDirectory.any_instance.stubs(:fetch_db_info).returns({ 'ResourceDirectory' =>
                                                                             {
                                                                               'RootFolderId' => 'test-root_folder_id',
                                                                               'ResourceDirectoryId' => 'test-id',
                                                                               'CreateTime' => '2019-02-18T15:32:10.473Z',
                                                                               'MasterAccountId' => 'test-master_account_id',
                                                                               'MasterAccountName' => 'aliyun-admin',
                                                                               'ControlPolicyStatus' => 'Enabled',
                                                                               'MemberDeletionStatus' => 'Enabled',
                                                                               'IdentityInformation' => 'test_identity_info',
                                                                             } })
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
