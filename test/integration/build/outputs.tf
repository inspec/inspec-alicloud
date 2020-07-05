output "alicloud_vpc_id" {
  value = alicloud_vpc.inspec_vpc.0.id
}

output "alicloud_security_group_id" {
  value = alicloud_security_group.default.0.id
}

output "alicloud_security_group_alpha_id" {
  value = alicloud_security_group.alpha.0.id
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
