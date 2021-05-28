output "alicloud_vpc_id" {
  value = alicloud_vpc.inspec_vpc.0.id
}
output "alicloud_vswitch_id" {
  value = alicloud_vswitch.inspec_vswitch.0.id
}
output "alicloud_vrouter_id" {
  value = alicloud_vpc.inspec_vpc.0.router_id
}
output "alicloud_security_group_id" {
  value = alicloud_security_group.default.0.id
}
output "alicloud_security_group_alpha_id" {
  value = alicloud_security_group.alpha.0.id
}
output "alicloud_rds_db_id" {
  value = alicloud_db_instance.rds.0.id
}
output "alicloud_action_trail_bucket_id" {
  value = alicloud_oss_bucket.action-trail-bucket.0.id
}
output "alicloud_disk_id" {
  value = alicloud_disk.alpha.0.id
}
output "alicloud_slb_http_id" {
  value = alicloud_slb.slb-http-test.0.id
}
output "alicloud_slb_https_id" {
  value = alicloud_slb.slb-https-test.0.id
}
output "alicloud_bucket_acl_name" {
  value = alicloud_oss_bucket.bucket-acl.0.id
}
output "alicloud_bucket_website_name" {
  value = alicloud_oss_bucket.bucket-website.0.id
}
output "alicloud_bucket_logging_target_name" {
  value = alicloud_oss_bucket.bucket-target.0.id
}
output "alicloud_bucket_logging_name" {
  value = alicloud_oss_bucket.bucket-logging.0.id
}
output "alicloud_bucket_lifecycle_name" {
  value = alicloud_oss_bucket.bucket-lifecycle.0.id
}
output "alicloud_bucket_encrypted_name" {
  value = alicloud_oss_bucket.bucket-sse.0.id
}
output "alicloud_bucket_tags_name" {
  value = alicloud_oss_bucket.bucket-tags.0.id
}
output "alicloud_bucket_versioning_name" {
  value = alicloud_oss_bucket.bucket-versioning.0.id
}
output "alicloud_instance_id" {
  value = alicloud_instance.instance.0.id
}
output "alicloud_ram_access_key_id" {
  value = alicloud_ram_access_key.ak.0.id
}
output "alicloud_ram_role_arn" {
  value = alicloud_ram_role.role.0.arn
}
