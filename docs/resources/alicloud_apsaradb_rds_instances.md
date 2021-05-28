---
title: About the alicloud_apsaradb_rds_instances Resource
platform: alicloud
---

# alicloud\_apsaradb\_rds\_instances

Use the `alicloud_apsaradb_rds_instances` InSpec audit resource to test properties of a collection of ApsaraDB RDS instances.

ApsaraDB RDS supports the MySQL, SQL Server, PostgreSQL, PPAS (highly compatible with Oracle) and MariaDB database engines.

## Syntax

 Ensure you have exactly 3 instances

    describe alicloud_apsaradb_rds_instances do
      its('db_instance_ids.count') { should cmp 3 }
    end

#### Parameters

This resource does not expect any parameters.

See also the [Alicloud documentation on ApsaraDB RDS](https://www.alibabacloud.com/help/doc-detail/26092.htm).

## Properties

|Property                    | Description|
| ---                        | --- |
|db\_instance\_ids           | The unique IDs of the ApsaraDB RDS instances returned. |
|descriptions                | The display names of the returned instances. |
|resource\_groups            | The IDs of the resource groups to which read-only instances belong.
|net\_types                  | The network types of the returned instances: one of 'Internet' or 'Intranet' |
|instance\_types             | The roles of the returned instances: 'Primary'/'Readonly'/'Guard'/'Temp'. |
|multiple\_zone\_deployments | Boolean values indicating whether the instances are deployed in multiple zones (MutriORsignle API call). |
|network\_types              | The network types of the returned instances: one of 'Classic' or 'VPC'. |
|read\_only\_instance\_ids   | Lists of read-only instances attached to instances returned that are primary instances. |
|engines                     | The database engines the instances run, e.g. 'MySQL'. |
|engine\_versions            | The versions of the database engine that the instances run. |
|statuses                    | The status of the instances, e.g. 'Running'/'Rebooting' etc. |
|zone\_ids                   | The IDs of the zones to which the instances belong. |
|instance\_classes           | The instance classes of the returned instances, e.g. 'mysql.n2.medium.1' |
|create\_times               | The times when the returned instances were created. |
|vswitch\_ids                | The IDs of the vSwitches associated with the VPCs to which the returned instances belong. |
|pay\_types                  | The billing methods of the returned instances: 'Postpaid'/'Prepaid'. |
|lock\_modes                 | The lock status of the returned instances: 'Unlock'/'ManualLock'/'LockByExpiration'/'LockByRestoration'/'LockByDiskQuota'/'Released'. |
|storage\_types              | The types of disk storage of the returned instances: 'local\_ssd'/'ephemeral\_ssd'/'cloud\_ssd'/'cloud\_essd'. |
|vpc\_ids                    | The IDs of the VPCs to which the instances belong. |
|connection\_modes           | The connection modes of the returned instances: 'Standard'/'Safe'. |
|vpc\_cloud\_instance\_ids   | The IDs of the read-only instances returned, that reside in VPCs. |
|region\_ids                 | The region IDs of the returned instances. |
|expire\_times               | The expiration times of the returned instances. |
|entries                     | Provides access to the raw results of the query, which can be treated as an array of hashes. |

## Examples

##### Ensure a specific instance exists

    describe alicloud_apsaradb_rds_instances do
      its('db_instance_ids') { should include 'rm-a1b2c3d4e5f6' }
    end

##### Use the InSpec resource to request the IDs of all ApsaraDB RDS instances, then test in-depth using `alicloud_apsaradb_rds_instance` to ensure all instances have the expected network security settings.

    alicloud_apsaradb_rds_instances.db_instance_ids.each do |db_instance_id|
      describe alicloud_apsaradb_rds_instance(db_instance_id) do
        its('in_default_vpc') { should be false }
        its('security_ips') { should_not cmp '' }
        its('security_ips') { should_not include '0.0.0.0/0' }
      end
    end

## Matchers

For a full list of available matchers, please visit our [Universal Matchers page](https://www.inspec.io/docs/reference/matchers/).

#### exist

The control will pass if the describe returns at least one result.

    describe alicloud_apsaradb_rds_instances do
      it { should exist }
    end

Use `should_not` to test the entity should not exist.

    describe alicloud_apsaradb_rds_instances do
      it { should_not exist }
    end

## Alicloud Permissions

Your Principal will need the `rds:DescribeDBInstances` action with Effect set to Allow.

You can find documentation at [Use RAM to manage ApsaraDB for RDS permissions](https://www.alibabacloud.com/help/doc-detail/58932.htm#section-rhd-4ll-5gb).
