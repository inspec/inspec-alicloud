---
title: About the alicloud_ram_user_mfa Resource
platform: alicloud
---

# alicloud\_ram\_user\_mfa

Use the `alicloud_ram_user_mfa` InSpec audit resource to test properties of a single Alicloud RAM user's MFA settings.

## Syntax

An `alicloud_ram_user_mfa` resource block declares the tests for a single Alicloud RAM user's MFA settings by user name.

    describe alicloud_ram_user_mfa(user_name: 'rpatel') do
      it { should exist }
    end

#### Parameters

##### user\_name _(required)_

This resource accepts a single parameter, the RAM user's username which uniquely identifies the user.  
This can be passed either as a string or as a `user_name: 'value'` key-value entry in a hash.

See also the [Alicloud documentation on RAM users](https://www.alibabacloud.com/help/doc-detail/122148.htm?spm=a2c63.p38356.b99.20.12456fb6z4r7Hz).

## Properties

|Property             | Description|
| ---                 | --- |
|user_name            | The RAM user's username. |
|serial_number        |The serial number of the RAM User's MFA device.|
|type                 |The MFA type (VMFA: virtual NFA device, or U2F: Universal 2nd Factor security key)|

## Examples

The following example shows how to use this InSpec audit resource.

##### Test that a user has MFA configured
    describe alicloud_ram_user_mfa(user_name: 'jakobp') do
      it { should exist }
      its('serial_number') { should eq 'acs:ram::1234567890123456:mfa/jakobp' }
      its('type') { should eq 'VMFA' }
    end

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers, please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

#### exist

The control will pass if the describe returns at least one result.

    it { should exist }

Use `should_not` to test the entity should not exist.

    it { should_not exist }

## Alicloud Permissions

Your Principal will need the following permissions action with Effect set to Allow: `ram:GetUserMFAInfo`

See the [Alibaba Cloud Resource Access Management documentation](https://www.alibabacloud.com/help/doc-detail/57445.htm?spm=a2c63.p38356.b99.12.51ef1b28W18VZd) and
[documentation on authentication to RAM APIs](https://partners-intl.aliyun.com/help/doc-detail/102666.htm).
