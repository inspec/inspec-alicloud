---
title: About the alicloud_ram_users Resource
platform: alicloud
---

# alicloud\_ram\_users

Use the `alicloud_ram_users` InSpec audit resource to test properties of some or all Alicloud RAM users.


## Syntax

An `alicloud_ram_users` resource block returns all RAM users and allows the testing of that group of RAM users.

    describe alicloud_ram_users do
      its('user_names') { should include 'payroll-admin' }
    end

#### Parameters

This resource does not expect any parameters.

See also the [Alicloud documentation on RAM users](https://www.alibabacloud.com/help/doc-detail/122148.htm?spm=a2c63.p38356.b99.20.12456fb6z4r7Hz).

## Properties

|Property                        | Description|
|---                             | --- |
|user_names                      | The user names of the returned RAM users. |
|user\_ids                       | The unique IDs of the returned RAM users. |
|display\_names                  | Display names of the returned RAM users. |
|comments                        | Comments about the returned RAM users. |
|create\_dates                   | The times when the returned RAM users were created. |
|update\_dates                   | The times when the information about the returned RAM users was last updated. |
|access\_keys                    | An array of hashes each containing metadata about a user's access keys (active and inactive). |
|active\_access\_keys            | An array of hashes each containing metadata about a user's active access keys. |
|has\_access\_key                | Boolean indicating whether each user has any access keys or not. |
|has\_active\_access\_key        | Boolean indicating whether each user has any active access keys or not. |
|has\_console_access             | Boolean indicating whether each user has console access. |
|has\_console\_and\_key\_access  | Boolean indicating whether each user has both console access as well as one or more active access keys. |
|has\_mfa\_enabled               | Boolean indicating whether each user has MFA enabled or not. |
|entries                         | Provides access to the raw results of the query, which can be treated as an array of hashes. |

## Examples

##### Ensure there are no RAM users who do not have MFA enabled.
      describe alicloud_ram_users.where(has_mfa_enabled: false) do
        it { should_not exist }
        its('user_names') { should cmp [] }  # less readable test, but it gives better output
      end

##### Ensure there are no RAM users who have console access and do not have MFA enabled.
      alicloud_ram_users.where(has_console_access: true).user_names.each do |u|
        describe alicloud_ram_user_mfa(u) do
          it { should exist }
        end
      end

##### Ensure there are no RAM users with console access and one or more active access keys
      describe alicloud_ram_users.where(has_console_and_key_access: true) do
        its('user_names') { should be_empty }
      end

      or

      alicloud_ram_users.where { active_access_keys.count > 0 }.user_names.each do |u|
        describe alicloud_ram_user(u) do
          its('has_console_access') { should be false }
        end
      end

## Matchers

For a full list of available matchers, please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

#### exist

The control will pass if the describe returns at least one result.

Use `should_not` to test the entity should not exist.

    describe alicloud_ram_users.where( <property>: <value>) do
      it { should exist }
    end

    describe alicloud_ram_users.where( <property>: <value>) do
      it { should_not exist }
    end

## Alicloud Permissions

Your Principal will need the following permissions action with Effect set to Allow: `ram:Listusers`, `ram:GetLoginProfile`, `ram:ListAccessKeys`, `ram:GetUserMFAInfo`

See the [Alibaba Cloud Resource Access Management documentation](https://www.alibabacloud.com/help/doc-detail/57445.htm?spm=a2c63.p38356.b99.12.51ef1b28W18VZd) and
[documentation on authentication to RAM APIs](https://partners-intl.aliyun.com/help/doc-detail/102666.htm).

