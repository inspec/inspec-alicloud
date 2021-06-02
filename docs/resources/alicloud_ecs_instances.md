---
title: About the alicloud_ecs_instances Resource
platform: alicloud
---

# alicloud\_ecs\_instances

Use the `alicloud_ecs_instances` InSpec audit resource to test properties of a collection of Alicloud ECS instances.

## Syntax

An `alicloud_ecs_instances` resource block declares the tests a collection of Alicloud ECS instances.

    describe alicloud_ecs_instances
      it { should exist }
    end

#### Parameters

This resource does not expect any parameters.

See also the [documentation on Alicloud ECS instances](https://www.alibabacloud.com/help/doc-detail/25374.htm?spm=a2c63.l28256.b99.60.36277453JrAX8s).

## Properties

|Property                        | Description|
| ---                            | --- |
|instance\_ids                   | The unique instance IDs of the returned ECS instances. |
|instance\_names                 | The names of the instances. |
|host\_names                     | The host names of the instances. |
|descriptions                    | The descriptions of the instances. |
|memory                          | The memory sizes of the instances, in MiB. |
|cpus                            | The numbers of vCPUs the instances have. |
|cpu\_options                    | The CPU options of the instances. |
|gpu\_specs                      | The categories of GPU for the instance types. |
|image\_ids                      | The IDs of the images that the instances are running. |
|instance\_types                 | The instance types of the instances, e.g. 'ecs.g5.large'. |
|instance\_type\_families        | The instance families of the instances. |
|io\_optimized                   | Booleans that specify whether the instances are I/O optimized. |
|os\_names                       | The names of the operating systems for the instances. |
|os\_types                       | The types of operating systems for the instances: 'windows' or 'linux'. |
|instance\_network\_types        | The network types of the instances: 'Classic' or 'VPC'. |
|public\_ip\_addresses           | The public IP addresses of the instances. |
|inner\_ip\_addresses            | The internal IP addresses of the instances. |
|eip\_addresses                  | The Elastic IP addresses associated with the instances. |
|network\_interfaces             | The ENIs bound to the instances. |
|vlan\_ids                       | The virtual local area network (VLAN) of the instance. |
|vpc\_attributes                 | The VPC attributes of the instance. |
|internet\_max\_bandwidth\_out   | The maximum outbound public bandwidth, in Mbit/s. |
|internet\_max\_bandwidth\_in    | The maximum outbound inbound bandwidth, in Mbit/s. |
|instance\_charge\_types         | The billing method of the instance: 'Prepaid' or 'Postpaid'. |
|internet\_charge\_types         | The billing method of the EIP: 'PayByBandwidth' or 'PayByTraffic'. |
|spot\_price\_limits             | Maximum hourly prices for the instances, accurate to 3 decimal places. |
|spot\_strategies                | The bidding policies for the preemptible instances: 'NoSpot'/'SpotWithPriceLimit'/'SpotAsPriceGo'. |
|sale\_cycles                    | The billing cycles of the instances, e.g. 'month'. |
|creation\_times                 | The time when the instance was created, e.g. '2020-12-10T04:04Z'. |
|start\_times                    | The times when the instances were started. |
|expired\_times                  | The expiration times of the instances. |
|auto\_release\_times            | The automatic release times of pay-as-you-go instances. |
|statuses                        | The current state of the instances, for example 'running'.|
|stopped\_modes                  | Indicates whether the instances continue to be billed after they are stopped: 'KeepCharging'/'StopCharging'/'Not-applicable'. |
|metadata\_options               | The metadata options of the instances. |
|zone\_ids                       | The zone ID of the instances. |
|cluster\_ids                    | The ID of the cluster to which the instance belongs. |
|security\_group\_ids            | The security group ids associated with the instance. |
|deployment\_set\_ids            | The IDs of the deployment sets of the instances. |
|serial\_numbers                 | The serial number of the instances. |
|dedicated\_instance\_attributes | The attributes of the instances on dedicated hosts. |
|devices\_available              | Boolean value indicating whether data disks can be attached to the instances. |
|deletion\_protection            | Boolean value which indicates whether instances can be deleted. |
|ram\_roles                      | The RAM roles attached to the instances. |
|entries                         | Provides access to the raw results of the query, which can be treated as an array of hashes. |

## Examples

##### Ensure that you have less than 100 ECS instances

    describe alicloud_ecs_instances do
      its('instance_ids.count') { should be < 100 }
    end

##### Ensure that no instances have deletion protection turned off

    describe alicloud_ecs_instances.where(deletion_protection: false) do
      it { should not exist }
    end

##### Ensure that instances have exactly one RAM role attached

    describe(alicloud_ecs_instances.where { ram_role.count != 1 }) do
      it { should not exist }
    end

## Matchers

For a full list of available matchers, please visit our [Universal Matchers page](https://www.inspec.io/docs/reference/matchers/).

#### exist

The control will pass if the describe returns at least one result.

Use `should_not` to test the entity should not exist.

    describe alicloud_ecs_instances do
      it { should exist }
    end

    describe alicloud_ecs_instances do
      it { should_not exist }
    end

## Alicloud Permissions

Your Principal will need the `ecs:DescribeInstances` and `ecs:DescribeInstanceRamRole` actions with Effect set to Allow.

See the [Alibaba Cloud Resource Access Management documentation](https://www.alibabacloud.com/help/doc-detail/57445.htm?spm=a2c63.p38356.b99.12.51ef1b28W18VZd) and
[documentation on authentication rules for ECS APIs](https://partners-intl.aliyun.com/help/doc-detail/25497.htm?spm=a2c63.p38356.b99.657.7b9f3481VdEA4g).
