+++
title = "About the Chef InSpec Alibaba Cloud resource pack"

draft = false

linkTitle = "Alibaba Cloud resource pack"
summary = "Chef InSpec resources for auditing Alibaba Cloud."

[cascade]
  [cascade.params]
    platform = "alicloud"

[menu.alicloud]
  title = "About Alibaba Cloud resources"
  identifier = "inspec/resources/alicloud/about"
  parent = "inspec/resources/alicloud"
  weight = 10
+++

Chef InSpec has resources for auditing Alibaba.

You will need to install Alibaba Cloud SDK version 0.8.0 and require Alibaba Cloud credentials to use the Chef InSpec Alibaba Cloud resources.

## Prerequisites

Before you begin you will need to:

- [Install the Alibaba Cloud CLI](https://www.alibabacloud.com/help/en/cli/installation-guide/)
- [Configure the Alibaba Cloud credentials](https://www.alibabacloud.com/help/en/cli/configure-credentials)

## Use the Alibaba Cloud resources

To use these resources in your controls, follow these steps:

1. Define your Alibaba Cloud credentials in an [`envrc` file](https://github.com/inspec/inspec-alicloud/blob/main/.envrc_example) or export them in your shell.

   ```bash
   # Example Alibaba Cloud Configuration
   export ALICLOUD_ACCESS_KEY="<ALICLOUD_ACCESS_KEY>"
   export ALICLOUD_SECRET_KEY="<ALICLOUD_SECRET_KEY>"
   export ALICLOUD_REGION="eu-west-1"
   ```

1. Create a profile:

    ```bash
    inspec init profile --platform Alibaba Cloud <PROFILE_NAME>
    ```

    In the generated profile, `inspec.yml` defines the `inspec/inspec-alicloud` repository tar file as a dependency:

    ```yaml
    name: <PROFILE_NAME>
    title: Ali Cloud InSpec Profile
    maintainer: The Authors
    copyright: The Authors
    copyright_email: you@example.com
    license: Apache-2.0
    summary: An InSpec Compliance Profile For Ali CLoud
    version: 0.1.0
    inspec_version: '~> 5'
    depends:
      - name: inspec-alicloud
        url: https://github.com/inspec/inspec-alicloud/archive/main.tar.gz
    supports:
      - platform: alicloud
    ```

1. In the controls directory, add controls using the InSpec Alibaba Cloud resources listed below to audit your Alibaba Cloud resources.

1. Run the profile:

    ```bash
    inspec exec <PROFILE_NAME> -t alicloud://
    ```

## Alibaba Cloud resources

{{< inspec_resources_filter >}}

The following Chef InSpec Alibaba Cloud resources are available in this resource pack.

{{< inspec_resources section="alicloud" platform="alicloud" >}}
