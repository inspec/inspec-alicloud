# AliCloud Terraform Templates for InSpec Testing

terraform {
  required_version = ">= 0.12"
}

# Configure variables
variable "alicloud_region" {}
variable "alicloud_vpc_name" {}
variable "alicloud_vpc_cidr" {}
variable "alicloud_security_group_name" {}
variable "alicloud_security_group_description" {}
variable "alicloud_action_trail_name" {}
variable "alicloud_action_trail_bucket_name" {}
variable "alicloud_action_trail_ram_role_name" {}
variable "alicloud_action_trail_ram_role_description" {}
variable "alicloud_action_trail_ram_policy_name" {}
variable "alicloud_action_trail_ram_policy_description" {}
variable "alicloud_enable_create" {}

provider "alicloud" {
  version = "1.88"
  region  = var.alicloud_region
}

data "alicloud_caller_identity" "creds" {}

data "alicloud_regions" "current" {}

resource "alicloud_vpc" "inspec_vpc" {
  count      = var.alicloud_enable_create
  name       = var.alicloud_vpc_name
  cidr_block = var.alicloud_vpc_cidr
}

# there is no default security group it seems in alicloud
# creating two so the security_groups verify tests can count
# more than 1

resource "alicloud_security_group" "default" {
  count  = var.alicloud_enable_create
  name   = var.alicloud_security_group_name
  vpc_id = alicloud_vpc.inspec_vpc.0.id
}

resource "alicloud_security_group" "alpha" {
  count       = var.alicloud_enable_create
  name        = var.alicloud_security_group_name
  description = var.alicloud_security_group_description
  vpc_id      = alicloud_vpc.inspec_vpc.0.id
}


########### ActionTrail #########################

resource "alicloud_ram_role" "actiontrail-role" {
  count       = var.alicloud_enable_create
  name        = var.alicloud_action_trail_ram_role_name
  document    = <<ROLE
{
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "actiontrail.aliyuncs.com"
                ]
            }
        }
    ],
    "Version": "1"
}

ROLE
  description = var.alicloud_action_trail_ram_role_description
  force       = "true"
}

resource "alicloud_ram_policy" "actiontrail-policy" {
  count       = var.alicloud_enable_create
  name        = var.alicloud_action_trail_ram_policy_name
  document    = <<POLICY
{
  "Version": "1",
  "Statement": [
    {
      "Action": [
        "oss:ListObjects",
        "oss:PutObject",
        "oss:GetBucketLocation"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "log:PostLogStoreLogs",
        "log:CreateLogstore"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
POLICY
  description = var.alicloud_action_trail_ram_policy_description
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "actiontrail-attachment" {
  count       = var.alicloud_enable_create
  policy_name = alicloud_ram_policy.actiontrail-policy.0.name
  role_name   = alicloud_ram_role.actiontrail-role.0.name
  policy_type = alicloud_ram_policy.actiontrail-policy.0.type
}

resource "alicloud_oss_bucket" "action-trail-bucket" {
  count  = var.alicloud_enable_create
  bucket = var.alicloud_action_trail_bucket_name
}

resource "alicloud_actiontrail" "action-trail" {
  name            = var.alicloud_action_trail_name
  oss_bucket_name = alicloud_oss_bucket.action-trail-bucket.0.id
  role_name       = alicloud_ram_role_policy_attachment.actiontrail-attachment.0.role_name
}
