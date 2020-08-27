# AliCloud Terraform Templates for InSpec Testing

terraform {
  required_version = ">= 0.12"
}

# Configure variables
variable "alicloud_region" {}
variable "alicloud_vpc_name" {}
variable "alicloud_vpc_description" {}
variable "alicloud_vpc_cidr" {}
variable "alicloud_vpc_vswitch_name" {}
variable "alicloud_vpc_vswitch_cidr" {}
variable "alicloud_security_group_name" {}
variable "alicloud_security_group_description" {}
variable "alicloud_security_group_rule_port_range" {}
variable "alicloud_security_group_rule_cidr" {}
variable "alicloud_bucket_acl_name" {}
variable "alicloud_bucket_website_name" {}
variable "alicloud_bucket_logging_target_name" {}
variable "alicloud_bucket_logging_name" {}
variable "alicloud_bucket_lifecycle_name" {}
variable "alicloud_bucket_encrypted_name" {}
variable "alicloud_bucket_tags_name" {}
variable "alicloud_bucket_versioning_name" {}
variable "alicloud_action_trail_name" {}
variable "alicloud_action_trail_bucket_name" {}
variable "alicloud_action_trail_ram_role_name" {}
variable "alicloud_action_trail_ram_role_description" {}
variable "alicloud_action_trail_ram_policy_name" {}
variable "alicloud_action_trail_ram_policy_description" {}
variable "alicloud_disk_name" {}
variable "alicloud_disk_size" {}
variable "alicloud_disk_desc" {}
variable "alicloud_disk_encrypted" {}
variable "alicloud_disk_category" {}
variable "alicloud_enable_create" {}
variable "alicloud_ram_user_name" {}
variable "alicloud_ram_user_display_name" {}
variable "alicloud_ram_user_mobile" {}
variable "alicloud_ram_user_email" {}
variable "alicloud_ecs_instance_type" {}
variable "alicloud_ecs_instance_system_disk_category" {}
variable "alicloud_ecs_instance_image_id" {}
variable "alicloud_ecs_instance_name" {}
variable "alicloud_ecs_instance_internet_max_bandwidth_out" {}
variable "alicloud_ecs_instance_disk_name" {}
variable "alicloud_ecs_instance_disk_size" {}
variable "alicloud_ecs_instance_disk_category" {}
variable "alicloud_ecs_instance_disk_encrypted" {}

provider "alicloud" {
  version = "1.88"
  region  = var.alicloud_region
}

data "alicloud_caller_identity" "creds" {}

data "alicloud_regions" "current" {}

resource "alicloud_vpc" "inspec_vpc" {
  count       = var.alicloud_enable_create
  name        = var.alicloud_vpc_name
  description = var.alicloud_vpc_description
  cidr_block  = var.alicloud_vpc_cidr
}

resource "alicloud_vswitch" "inspec_vswitch" {
  count             = var.alicloud_enable_create
  vpc_id            = alicloud_vpc.inspec_vpc.0.id
  cidr_block        = var.alicloud_vpc_vswitch_cidr
  availability_zone = data.alicloud_zones.zones_ds.zones.0.id
  name              = var.alicloud_vpc_vswitch_name
}

########### Security Groups #####################

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

resource "alicloud_security_group_rule" "sg-test" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = var.alicloud_security_group_rule_port_range
  priority          = 1
  security_group_id = alicloud_security_group.alpha.0.id
  cidr_ip           = var.alicloud_security_group_rule_cidr
}

########### OSS Buckets #########################

resource "alicloud_oss_bucket" "bucket-acl" {
  count         = var.alicloud_enable_create
  bucket        = var.alicloud_bucket_acl_name
  acl           = "private"
  force_destroy = true
}

resource "alicloud_oss_bucket" "bucket-website" {
  count         = var.alicloud_enable_create
  bucket        = var.alicloud_bucket_website_name
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "alicloud_oss_bucket" "bucket-target" {
  count         = var.alicloud_enable_create
  bucket        = var.alicloud_bucket_logging_target_name
  acl           = "private"
  force_destroy = true
}

resource "alicloud_oss_bucket" "bucket-logging" {
  count         = var.alicloud_enable_create
  bucket        = var.alicloud_bucket_logging_name
  acl           = "public-read"
  force_destroy = true

  logging {
    target_bucket = alicloud_oss_bucket.bucket-target.0.id
    target_prefix = "log/"
  }
}

resource "alicloud_oss_bucket" "bucket-lifecycle" {
  count         = var.alicloud_enable_create
  bucket        = var.alicloud_bucket_lifecycle_name
  force_destroy = true

  lifecycle_rule {
    id      = "rule-days"
    prefix  = "path1/"
    enabled = true

    expiration {
      days = 365
    }
  }
  lifecycle_rule {
    id      = "rule-date"
    prefix  = "path2/"
    enabled = true

    expiration {
      date = "2018-01-12"
    }
  }
}

resource "alicloud_oss_bucket" "bucket-sse" {
  count         = var.alicloud_enable_create
  bucket        = var.alicloud_bucket_encrypted_name
  force_destroy = true

  server_side_encryption_rule {
    sse_algorithm = "AES256"
  }
}

resource "alicloud_oss_bucket" "bucket-tags" {
  count         = var.alicloud_enable_create
  bucket        = var.alicloud_bucket_tags_name
  force_destroy = true

  tags = {
    key1 = "value1"
    key2 = "value2"
  }
}

resource "alicloud_oss_bucket" "bucket-versioning" {
  count         = var.alicloud_enable_create
  bucket        = var.alicloud_bucket_versioning_name
  acl           = "private"
  force_destroy = true

  versioning {
    status = "Enabled"
  }
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
  count         = var.alicloud_enable_create
  bucket        = var.alicloud_action_trail_bucket_name
  force_destroy = true
}

resource "alicloud_actiontrail" "action-trail" {
  name            = var.alicloud_action_trail_name
  oss_bucket_name = alicloud_oss_bucket.action-trail-bucket.0.id
  role_name       = alicloud_ram_role_policy_attachment.actiontrail-attachment.0.role_name
}


########### Disk ################################

data "alicloud_zones" "zones_ds" {
  available_resource_creation = "Disk"
}

resource "alicloud_disk" "alpha" {
  count             = var.alicloud_enable_create
  availability_zone = data.alicloud_zones.zones_ds.zones.0.id
  name              = var.alicloud_disk_name
  description       = var.alicloud_disk_desc
  category          = var.alicloud_disk_category
  size              = var.alicloud_disk_size
  encrypted         = var.alicloud_disk_encrypted
}

resource "alicloud_disk" "beta" {
  count             = var.alicloud_enable_create
  availability_zone = data.alicloud_zones.zones_ds.zones.0.id
  name              = "second-disk"
  description       = "second test disk"
  category          = var.alicloud_disk_category
  size              = var.alicloud_disk_size
}

############ SLB's ##############################

variable "alicloud_slb_http_name" {}
variable "alicloud_slb_http_address_type" {}
variable "alicloud_slb_https_name" {}
variable "alicloud_slb_https_address_type" {}
variable "alicloud_slb_https_specification" {}
variable "alicloud_slb_server_certificate_name" {}
variable "alicloud_http_listener_fe_port" {}
variable "alicloud_http_listener_be_port" {}
variable "alicloud_http_listener_protocol" {}
variable "alicloud_http_listener_bandwidth" {}
variable "alicloud_https_listener_fe_port" {}
variable "alicloud_https_listener_be_port" {}
variable "alicloud_https_listener_protocol" {}
variable "alicloud_https_listener_bandwidth" {}
variable "alicloud_https_listener_tls_cipher_policy" {}
variable "alicloud_tags" {}

data "alicloud_zones" "zones_slb" {
  available_resource_creation = "Slb"
}

resource "alicloud_slb" "slb-http-test" {
  count          = var.alicloud_enable_create
  master_zone_id = data.alicloud_zones.zones_slb.zones.0.id
  name           = var.alicloud_slb_http_name
  address_type   = var.alicloud_slb_http_address_type
  tags           = var.alicloud_tags
}

resource "alicloud_slb" "slb-https-test" {
  count          = var.alicloud_enable_create
  master_zone_id = data.alicloud_zones.zones_slb.zones.0.id
  name           = var.alicloud_slb_https_name
  address_type   = var.alicloud_slb_https_address_type
  specification  = var.alicloud_slb_https_specification
  tags           = var.alicloud_tags
}

############# SLB server certificate #############

resource "alicloud_slb_server_certificate" "slb-cert" {
  name               = var.alicloud_slb_server_certificate_name
  server_certificate = file("${path.module}/fixtures/certs/test.crt")
  private_key        = file("${path.module}/fixtures/certs/test.key")
}

############# SLB Listeners ######################

resource "alicloud_slb_listener" "http" {
  load_balancer_id = alicloud_slb.slb-http-test.0.id
  frontend_port    = var.alicloud_http_listener_fe_port
  backend_port     = var.alicloud_http_listener_be_port
  protocol         = var.alicloud_http_listener_protocol
  bandwidth        = var.alicloud_http_listener_bandwidth
}

resource "alicloud_slb_listener" "https" {
  load_balancer_id      = alicloud_slb.slb-https-test.0.id
  frontend_port         = var.alicloud_https_listener_fe_port
  backend_port          = var.alicloud_https_listener_be_port
  protocol              = var.alicloud_https_listener_protocol
  bandwidth             = var.alicloud_https_listener_bandwidth
  tls_cipher_policy     = var.alicloud_https_listener_tls_cipher_policy
  server_certificate_id = alicloud_slb_server_certificate.slb-cert.id
}

########### RAM Password Policy ##################

variable "alicloud_ram_account_password_policy_password_reuse_prevention" {}
variable "alicloud_ram_account_password_policy_max_password_age" {}

resource "alicloud_ram_account_password_policy" "test" {
  password_reuse_prevention = var.alicloud_ram_account_password_policy_password_reuse_prevention
  max_password_age          = var.alicloud_ram_account_password_policy_max_password_age
}

########### RAM User ##################

resource "alicloud_ram_user" "user" {
  name         = var.alicloud_ram_user_name
  display_name = var.alicloud_ram_user_display_name
  mobile       = var.alicloud_ram_user_mobile
  email        = var.alicloud_ram_user_email
}

########### ECS Instances ##################

resource "alicloud_kms_key" "ecs" {
        description             = "ecs test instance disk key"
        pending_window_in_days  = "7"
        key_state               = "Enabled"
}

resource "alicloud_instance" "instance" {
  availability_zone = data.alicloud_zones.zones_ds.zones.0.id
  security_groups   = [alicloud_security_group.default.0.id]

  # series III
  instance_type              = var.alicloud_ecs_instance_type
  system_disk_category       = var.alicloud_ecs_instance_system_disk_category
  image_id                   = var.alicloud_ecs_instance_image_id
  instance_name              = var.alicloud_ecs_instance_name
  vswitch_id                 = alicloud_vswitch.inspec_vswitch.0.id
  internet_max_bandwidth_out = var.alicloud_ecs_instance_internet_max_bandwidth_out
  data_disks {
     name         = var.alicloud_ecs_instance_disk_name
     size         = var.alicloud_ecs_instance_disk_size
     category     = var.alicloud_ecs_instance_disk_category
     description  = "Disk for ecs test instance"
     encrypted    = var.alicloud_ecs_instance_disk_encrypted
    }
}
