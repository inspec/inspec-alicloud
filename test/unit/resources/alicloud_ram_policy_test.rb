require "helper"
require "alicloud_ram_policy"

class AliCloudRamPolicyConstructorTest < Minitest::Test
  def setup
    ENV["ALICLOUD_REGION"] = "us-east-1"

    AliCloudRamPolicy.any_instance.stubs(:get_policy).returns({ "Policy" => { "PolicyType" => "Custom",
      "Description" => "Test policy", "AttachmentCount" => 0, "PolicyName" => "test-policy", "DefaultVersion" => "v2" },
      "DefaultPolicyVersion" => { "VersionId" => "v1", "IsDefaultVersion" => true,
      "PolicyDocument" => "{\n  \"Version\": \"1\",\n  \"Statement\": [\n    {\n      \"Action\": [\n        \"ecs:Describe*\"\n      ],\n" +
      "      \"Effect\": \"Allow\",\n      \"Resource\": \"*\"\n    },\n    {\n      \"NotAction\": \"oss:DeleteBucket\",\n" +
      "      \"Effect\": \"Allow\",\n      \"Resource\": \"acs:oss:::*\"\n    }\n  ]\n}\n", "CreateDate" => "2021-01-01T00:00:00Z" } })

    @policy_document = '{
  "Version": "1",
  "Statement": [
    {
      "Action": [
        "ecs:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "NotAction": "oss:DeleteBucket",
      "Effect": "Allow",
      "Resource": "acs:oss:::*"
    }
  ]
}
'
    AliCloudRamPolicy.any_instance.stubs(:get_attached_entities).returns({
     "Groups" => { "Group" => [{ "GroupName" => "group-1", "Comments" => "A comment" }] },
     "Roles" => { "Role" => [{ "RoleName" => "role-1", "Description" => "", "Arn" => "acs:ram::12345:role/role-1", "RoleId" => "55555" }] },
     "Users" => { "User" => [{ "UserName" => "user-1", "UserId" => "66666", "DisplayName" => "user-1" },
                             { "UserName" => "user-2", "UserId" => "88888", "DisplayName" => "user-2" }] } })
  end

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AliCloudRamPolicy.new }
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AliCloudRamPolicy.new(rubbish: 9) }
  end

  def test_accepts_string_argument
    policy = AliCloudRamPolicy.new("atestpolicy")
    assert_equal "atestpolicy", policy.policy_name
  end

  def test_accepts_key_value_argument_and_resource_works
    policy = AliCloudRamPolicy.new(policy_name: "atestpolicy")
    assert_equal "atestpolicy", policy.policy_name
    assert_equal "v2", policy.default_version
    assert_equal @policy_document, policy.policy_document
    assert_equal true, policy.has_statement?({ Effect: "Allow", Resource: "acs:oss:::*", NotAction: "oss:DeleteBucket" })
    assert_equal true, policy.has_statement?({ 'Effect': "Allow", 'Resource': "acs:oss:::*", 'NotAction': "oss:DeleteBucket" })
    assert_equal true, policy.has_statement?({ 'effect': "Allow", 'resource': "acs:oss:::*", 'notaction': "oss:DeleteBucket" })
    assert_equal 2, policy.statement_count
    assert_equal true, policy.attached_to_user?("user-2")
    assert_equal 2, policy.attached_user_count
    assert_equal true, policy.attached_to_group?("group-1")
    assert_equal 1, policy.attached_group_count
    assert_equal true, policy.attached_to_role?("acs:ram::12345:role/role-1")
    assert_equal 1, policy.attached_role_count
    assert_equal 4, policy.attachment_count
    assert_equal true, policy.attached?
  end

  def test_accepts_policy_name_and_region
    policy = AliCloudRamPolicy.new(policy_name: "atestpolicy", region: "eu-west-1")
    assert_equal "atestpolicy", policy.policy_name
  end

  def test_accepts_policy_name_and_custom_type
    policy = AliCloudRamPolicy.new(policy_name: "atestpolicy", type: "Custom")
    assert_equal "v2", policy.default_version
  end

  def test_accepts_policy_name_and_system_type
    policy = AliCloudRamPolicy.new(policy_name: "atestpolicy", type: "System")
    assert_equal @policy_document, policy.policy_document
  end

  def test_not_attached
    AliCloudRamPolicy.any_instance.stubs(:get_attached_entities).returns(nil)
    policy = AliCloudRamPolicy.new(policy_name: "atestpolicy")
    assert_equal 0, policy.attachment_count
  end
end
