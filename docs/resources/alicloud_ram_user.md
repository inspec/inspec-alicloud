---
title: About the alicloud_ram_user Resource
platform: alicloud
---

# alicloud\_ram\_user

Use the `alicloud_ram_user` InSpec audit resource to test properties of a single Alicloud RAM user.

## Syntax

An `alicloud_ram_user` resource block declares the tests for a single Alicloud RAM user by user name.

    describe alicloud_ram_user(user_name: 'psmith') do
      it { should exist }
    end

#### Parameters

##### user\_name _(required)_

This resource accepts a single parameter, the RAM user's user name which uniquely identifies the user.  
This can be passed either as a string or as a `user_name: 'value'` key-value entry in a hash.

See also the [Alicloud documentation on RAM users](https://www.alibabacloud.com/help/doc-detail/122148.htm?spm=a2c63.p38356.b99.20.12456fb6z4r7Hz).

## Properties

|Property             | Description|
| ---                 | --- |
|user_name            | The RAM user's username. |
|user\_id             | The RAM user's unique ID. |
|display\_name        | The RAM user's display name. |
|comments             | Comments about the user. |
|email                | The RAM user's email address. |
|mobile_phone         | The RAM user's mobile phone number. |
|create\_date         | The time when the RAM user was created. |
|update\_date         | The time when the information about the RAM user was last updated. |
|last_login_date      | The time when the RAM user last logged on to the console using their password. |
|access\_keys         | An array of hashes each containing metadata about the user's access keys (active and inactive).|
|active\_access\_keys | An array of hashes each containing metadata about the user's active access keys.|


## Examples

The following examples show how to use this InSpec audit resource.

##### Test that a RAM user does not exist
    describe alicloud_ram_user(user_name: 'invalid-user') do
      it { should_not exist }
    end

##### Ensure a RAM user has no active access keys
    describe alicloud_ram_user('psmith') do
      it { should exist }
      it { should not have_active_access_key }
      its('active_access_keys.count') { should eq 0 }
    end

##### Ensure a RAM user has 0 or 1 active access keys
    describe alicloud_ram_user('psmith') do
      its('active_access_keys.count') { should be <= 1 }
    end

##### Ensure that a RAM user does not have both console access and active access key(s)
    describe alicloud_ram_user('psmith') do
      it { should_not have_console_and_key_access }
    end

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers, please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

#### exist

The control will pass if the describe returns at least one result.

Use `should_not` to test the entity should not exist.

    it { should exist }

#### has\_console\_access

This will check whether the requested user has a login profile for console access.

    it { should have_console_access }

#### has\_active\_access\_key

This will check whether the requested user has at least one active access key and secret key.

    it { should have_active_access_key }

#### has\_console\_and\_key\_access

This will check whether the requested user has a login profile for console access, as well as at least one active access key/secret key pair.

## Alicloud Permissions

Your Principal will need the following permissions action with Effect set to Allow: `ram:Getuser`, `ram:GetLoginProfile`, `ram:ListAccessKeys`.

See the [Alibaba Cloud Resource Access Management documentation](https://www.alibabacloud.com/help/doc-detail/57445.htm?spm=a2c63.p38356.b99.12.51ef1b28W18VZd) and
[documentation on authentication to RAM APIs](https://partners-intl.aliyun.com/help/doc-detail/102666.htm).
