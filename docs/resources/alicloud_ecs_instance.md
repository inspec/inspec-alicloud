---
title: About the alicloud_ecs_instance Resource
platform: alicloud
---

# alicloud\_ecs\_instance

Use the `alicloud_ecs_instance` InSpec audit resource to test properties of a single Alicloud ECS instance.

## Syntax

An `alicloud_ecs_instance` resource block declares the tests for a single Alicloud ECS instance by instance id.

    describe alicloud_ecs_instance('i-01a2349e94458a507') do
      it { should exist }
    end

#### Parameters

##### instance\_id _(required)_

The ID of the ECS instance. This can be passed either as a string or as an `instance_id: 'value'` key-value entry in a hash.

    describe alicloud_ecs_instance(instance_id: 'i-01a2349e94458a507') do
      it { should exist }
    end

See also the [documentation on Alicloud ECS instances](https://www.alibabacloud.com/help/doc-detail/25374.htm?spm=a2c63.l28256.b99.60.36277453JrAX8s).

## Properties

|Property                      | Description|
| ---                          | --- |
|instance\_id                  | The unique instance ID of the ECS instance. |
|instance\_name                | The name of the instance. |
|host\_name                    | The host name of the instance. |
|description                   | The description of the instance. |
|memory                        | The memory size of the instance, in MiB. |
|cpu                           | The number of vCPUs. |
|instance\_network\_type       | The network type of the instance: 'Classic' or 'VPC'. |
|public\_ip\_address           | The public IP address of the instance. |
|eip\_address                  | The Elastic IP address associated with the instance. |
|inner\_ip\_address            | The internal IP address of the classic network-type instance. |
|expired\_time                 | The expiration time of the instance, e.g. '2020-12-10T04:04Z'. |
|image\_id                     | The ID of the image that the instance is running. |
|instance\_type                | The instance type of the instance, e.g. 'ecs.g5.large'. |
|vlan\_id                      | The virtual local area network (VLAN) of the instance. |
|vpc\_attributes               | The VPC attributes of the instance. |
|status                        | The current state of the ECS Instance, for example 'running'.|
|io\_optimized                 | Boolean that specifies whether the instance is I/O optimized. |
|zone\_id                      | The zone ID of the instance. |
|cluster\_id                   | The ID of the cluster to which the instance belongs. |
|stopped\_mode                 | Indicates whether the instance continues to be billed after it is stopped: 'KeepCharging'/'StopCharging'/'Not-applicable'. |
|dedicated\_host\_attribute    | Details about dedicated hosts: an array consiting of the DedicatedHostClusterId, DedicatedHostId, and DedicatedHostName parameters. |
|security\_group\_ids          | The security group ids associated with the instance. |
|operation\_locks              | The reasons why the instance was locked. |
|instance\_charge\_type        | The billing method of the instance: 'Prepaid' or 'Postpaid'. |
|internet\_charge\_type        | The billing method of the EIP: 'PayByBandwidth' or 'PayByTraffic'. |
|internet\_max\_bandwidth_\out | The maximum outbound public bandwidth, in Mbit/s. |
|internet\_max\_bandwidth\_in  | The maximum outbound inbound bandwidth, in Mbit/s. |
|serial\_number                | The serial number of the instance. |
|creation\_time                | The time when the instance was created, e.g. '2020-12-10T04:04Z'. |
|region\_id                    | The region ID of the instance. |
|credit\_specification         | The performance mode of the burstable instance: 'Standard' or 'Unlimited'. |
|deletion\_protection          | Boolean value which indicates whether you can delete the instance. |
|ram\_roles                    | The RAM roles attached to the instance. |

## Examples

##### Test that an ECS instance is running, it is using the correct image ID, and its deletion protection is turned on

    describe alicloud_ecs_instance('i-090c29e4f4c165b74') do
      it { should be_running }
      its('image_id') { should eq 'ubuntu_18_04_64_20G_alibase_20190624.vhd' }
      its('deletion_protection') { should be true }
    end

##### Test that an ECS instance has exactly one RAM role attached

    describe alicloud_ecs_instance('i-090c29e4f4c165b74') do
      its('ram_roles.count') { should eq 1 }
    end

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers, please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

#### exist

The control will pass if the describe returns at least one result.

Use `should_not` to test the entity should not exist.

    it { should exist }

    it { should_not exist }

## Alicloud Permissions

Your Principal will need the `ecs:DescribeInstances`, `ecs:DescribeInstanceAttribute` and `ecs:DescribeInstanceRamRole` actions with Effect set to Allow.

See the [Alibaba Cloud Resource Access Management documentation](https://www.alibabacloud.com/help/doc-detail/57445.htm?spm=a2c63.p38356.b99.12.51ef1b28W18VZd) and
[documentation on authentication rules for ECS APIs](https://partners-intl.aliyun.com/help/doc-detail/25497.htm?spm=a2c63.p38356.b99.657.7b9f3481VdEA4g).
