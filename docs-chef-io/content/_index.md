+++
title = "About Chef InSpec Alibaba Cloud resources"
platform = "alicloud"
draft = false
gh_repo = "inspec-alicloud"

[menu.alicloud]
title = "About resources"
identifier = "inspec/resources/alicloud/alicloud_apsaradb_rds_instance Resource"
parent = "inspec/resources/alicloud"
+++

Chef InSpec has resources for auditing Alibaba.

You will need to install AliCloud SDK version 0.8.0 and require AliCloud credentials to use the Chef InSpec AliCloud resources.

## Set AliCloud credentials

You can configure AliCloud credentials in an [.envrc file](https://github.com/inspec/inspec-alicloud/blob/main/.envrc_example) or export them in your shell.

```bash
# Example configuration
export ALICLOUD_ACCESS_KEY="anaccesskey"
export ALICLOUD_SECRET_KEY="asecretkey"
export ALICLOUD_REGION="eu-west-1"
```

## Alibaba Cloud resources

{{< inspec_resources_filter >}}

The following Chef InSpec Alibaba Cloud resources are available in this resource pack.

{{< inspec_resources section="alicloud" platform="alicloud" >}}
