# InSpec for AliCloud

This InSpec resource pack uses the AliCloud SDK v0 and provides the required resources to write tests for resources in AliCloud.

## Prerequisites

### AliCloud Credentials

Valid AliCloud credentials are required.

#### Environment Variables

Set your AliCloud credentials in an `.envrc` file or export them in your shell. (See example [.envrc file](.envrc_example))
    
```bash
    # Example configuration
    export ALICLOUD_ACCESS_KEY="anaccesskey"
    export ALICLOUD_SECRET_KEY="asecretkey"
    export ALICLOUD_REGION="eu-west-1"
```

## Resources
This resouce pack allows the testing of the following AliCloud resources. If a resource you wish to test is not listed, please feel free to open an [Issue](https://github.com/chef-customers/inspec-alicloud/issues). As an open source project, we also welcome public contributions via [Pull Request](https://github.com/chef-customers/inspec-alicloud/pulls).

- [alicloud_actiontrail_trail](libraries/alicloud_actiontrail_trail.rb)
- [alicloud_actiontrail_trails](libraries/alicloud_actiontrail_trails.rb)
- [alicloud_backend](libraries/alicloud_backend.rb)
- [alicloud_disk](libraries/alicloud_disk.rb)
- [alicloud_disks](libraries/alicloud_disks.rb)
- [alicloud_oss_bucket](libraries/alicloud_oss_bucket.rb)
- [alicloud_oss_buckets](libraries/alicloud_oss_buckets.rb)
- [alicloud_ram_password_policy](libraries/alicloud_ram_password_policy.rb)
- [alicloud_region](libraries/alicloud_region.rb)
- [alicloud_regions](libraries/alicloud_regions.rb)
- [alicloud_security_group](libraries/alicloud_security_group.rb)
- [alicloud_security_groups](libraries/alicloud_security_groups.rb)
- [alicloud_slb](libraries/alicloud_slb.rb)
- [alicloud_slb_https_listener](libraries/alicloud_slb_https_listener.rb)
- [alicloud_slbs](libraries/alicloud_slbs.rb)
- [alicloud_sts_caller_identity](libraries/alicloud_sts_caller_identity.rb)
