# InSpec for AliCloud

* **[Project State](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md): Prototyping**

This InSpec resource pack uses the AliCloud SDK v0.8.0 and provides the required resources to write tests for resources in AliCloud.

## Prerequisites

- Ruby
- Bundler installed
- AliCloud Cloud Account

### AliCloud Cloud Account

Your AliCloud Service Principal Account must have a minimum of `reader` role of the [AliCloud roles](https://www.alibabacloud.com/help/en/elastic-compute-service/latest/use-ram-roles-to-access-other-alibaba-cloud-services)

#### Setup the AliCloud account

1. [Install the AliCloud CLI](https://www.alibabacloud.com/help/en/alibaba-cloud-cli/latest/installation-guide)
2. [Configure the AliCloud credentials](https://www.alibabacloud.com/help/en/alibaba-cloud-cli/latest/configure-credential)

You must have the following pieces of information:

#### AliCloud Credentials

Valid AliCloud credentials are required.

- ALICLOUD_ACCESS_KEY
- ALICLOUD_SECRET_KEY
- ALICLOUD_REGION

#### Find the AliCloud credentials

- ALICLOUD_ACCESS_KEY and ALICLOUD_SECRET_KEY

1. Log in to the **AliCloud portal**.
2. Go to the **Products and Services**.
3. Search for **Resource Access Management**.
4. Click on the **Resource Access Management**.
5. Click on the **Users**.
6. Search for your **User Logon Name** (For Example: sam@1234567890.onaliyun.com)
7. Click for your **User Logon Name**
8. Click on **Create AccessKey**.
9. On a popup you will get the **AccessKey ID** and the **AccessKey Secret**.
10. CLick on **Download CSV File**. A file will get downloaded.
11. Click on **OK**.

- ALICLOUD_REGION

To see the list of regions, use this [Regions and Zones](https://www.alibabacloud.com/help/en/basics-for-beginners/latest/regions-and-zones)

For example, if you are using the Region `Singapore`, then use the Region ID `ap-southeast-1`.

#### Environment Variables

To know how to setup the alicloud credentials please use this [Installation Guide of AliCloud](https://www.alibabacloud.com/help/en/alibaba-cloud-cli/latest/installation-guide)

Set your AliCloud credentials in an `.envrc` file or export them in your shell. (See example [.envrc file](.envrc_example))
    
```bash
    # Example AliCloud Configuration
    export ALICLOUD_ACCESS_KEY="ABCAabcP1234SLS9ABCQ"
    export ALICLOUD_SECRET_KEY="vD2lfoNvPdwsofqyuO9jRuWU"
    export ALICLOUD_REGION="eu-west-1"
```

#### Test whether the setup is successful.

```bash
aliyun ecs DescribeInstances --output cols=RequestId
```

This will return the output: The RequestId will vary.

```bash
RequestId
---------
2A76BCCD-A123-123E-CD12-1234567U890
```

If it returns the result in your terminal then the setup is successful.

### Run the a custom test from your profile.

1. Create a Custom AliCloud Profile.
2. Add the test in the control.
3. Run the profile with the below command.

```bash
inspec exec <sample-alicloud-profile> -t alicloud://
```

Output:
```
Profile:   Ali Cloud InSpec Profile (my-alicloud-profile)
Version:   0.1.0
Target:    alicloud://eu-west-1

  ActionTrail testtrial
     ✔  is expected to exist

Test Summary: 1 successful, 0 failures, 0 skipped
```

## Resources

This resource pack allows the testing of the following AliCloud resources. If a resource you wish to test is not listed, please feel free to open an [Issue](https://github.com/chef-customers/inspec-alicloud/issues). As an open source project, we also welcome public contributions via [Pull Request](https://github.com/chef-customers/inspec-alicloud/pulls).

|        Module Name        | Singular Resource                                                              | Plural Resource                                                                 |
|:-------------------------:|--------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
|         Security          | [alicloud_actiontrail_trail](libraries/alicloud_actiontrail_trail.rb)          | [alicloud_actiontrail_trails](libraries/alicloud_actiontrail_trails.rb)         |
|         Database          | [alicloud_apsaradb_rds_instance](libraries/alicloud_apsaradb_rds_instance.rb)  | [alicloud_apsaradb_rds_instances](libraries/alicloud_apsaradb_rds_instances.rb) |
|     Elastic Computing     | [alicloud_disk](libraries/alicloud_disk.rb)                                    | [alicloud_disks](libraries/alicloud_disks.rb)                                   |
|                           | [alicloud_ecs_instance](libraries/alicloud_ecs_instance.rb)                    | [alicloud_ecs_instances](libraries/alicloud_ecs_instances.rb)                   |
|                           | [alicloud_security_group](libraries/alicloud_security_group.rb)                | [alicloud_security_groups](libraries/alicloud_security_groups.rb)               |
|                           | [alicloud_vpc](libraries/alicloud_vpc.rb)                                      | [alicloud_vpcs](libraries/alicloud_vpcs.rb)                                     |
| Management and Governance | [alicloud_ims_sso](libraries/alicloud_ims_sso.rb)                              | No Plural Resource                                                              |
|                           | [alicloud_rd](libraries/alicloud_rd.rb)                                        | No Plural Resource                                                              |
|          Storage          | [alicloud_oss_bucket](libraries/alicloud_oss_bucket.rb)                        | [alicloud_oss_buckets](libraries/alicloud_oss_buckets.rb)                       |
|            RAM            | [alicloud_ram_access_key](libraries/alicloud_ram_access_key.rb)                | [alicloud_ram_access_keys](libraries/alicloud_ram_access_keys.rb)               |
|                           | [alicloud_ram_password_policy](libraries/alicloud_ram_password_policy.rb)      | No Plural Resource                                                              |
|                           | [alicloud_ram_policy](libraries/alicloud_ram_policy.rb)                        | [alicloud_ram_policies](libraries/alicloud_ram_policies.rb)                     |
|                           | [alicloud_ram_user](libraries/alicloud_ram_user.rb)                            | [alicloud_ram_users](libraries/alicloud_ram_users.rb)                           |
|                           | [alicloud_sts_caller_identity](libraries/alicloud_sts_caller_identity.rb)      | No Plural Resource                                                              |
|     Networking & CDN      | [alicloud_slb](libraries/alicloud_slb.rb)                                      | [alicloud_slbs](libraries/alicloud_slbs.rb)                                     |
|                           | [alicloud_slb_https_listener](libraries/alicloud_slb_https_listener.rb)        | No Plural Resource                                                              |
|          Others           | [alicloud_region](libraries/alicloud_region.rb)                                | [alicloud_regions](libraries/alicloud_regions.rb)                               |

## Environment and Setup Notes

#### Train and InSpec Dependencies

InSpec AliCloud depends on version 0.0.4 of the AliCloud SDK that is provided via [Train AliCloud](https://github.com/chef-customers/train-alicloud). InSpec does not ship with Train AliCloud so this is explicitly listed in the Gemfile here.

### Running the unit and integration tests

Run the linting ~and unit tests~ via the below:

```bash
bundle exec rake
```

```
Running RuboCop...
Inspecting 19 files
................

19 files inspected, no offenses detected
```

To keep things simple the AliCloud credentials can either be supplied via environmental variables.

Running the integration tests requires resources so first `setup_integration_tests` which uses Terraform:

```bash
bundle exec rake test:setup_integration_tests
```

```
----> Initializing Terraform
terraform init

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
----> Generating Terraform and InSpec variable files
----> Generating the Plan
terraform plan -var-file=inspec-alicloud.tfvars.json -out inspec-alicloud.plan
...
This plan was saved to: inspec-alicloud.plan

To perform exactly these actions, run the following command to apply:
    terraform apply "inspec-alicloud.plan"

----> Applying the plan
terraform apply inspec-alicloud.plan
...
Apply complete! Resources: 24 added, 0 changed, 0 destroyed.
```

Next, run the integration tests themselves with `run_integration_tests`

```bash
bundle exec rake test:run_integration_tests
```

```
----> Running InSpec tests
bundle exec inspec exec test/integration/verify -t alicloud:// --input-file test/integration/build/alicloud-inspec-attributes.yaml --reporter cli json:inspec-output.json html:inspec-output.html --chef-license=accept-silent; rc=$?; if [ $rc -eq 0 ] || [ $rc -eq 101 ]; then exit 0; else exit 1; fi

Profile: AliCloud Resource Pack (inspec-alicloud)
Version: 0.1.0
Target:  alicloud://eu-west-1

  ✔  alicloud-slb-1.0: Ensure AliCloud Server Load Balancer has the correct properties.
     ✔  Server Load Balancer:  in eu-west-1 is expected not to exist
     ✔  Server Load Balancer: ID: lb-f2z9xjgwvww9xwvrl07mv Name: slb-http-lcgieqmyicjcjynbmnnszwfnk  in eu-west-1 is expected to exist
     ✔  Server Load Balancer: ID: lb-f2z9xjgwvww9xwvrl07mv Name: slb-http-lcgieqmyicjcjynbmnnszwfnk  in eu-west-1 https_listeners? is expected to eq false
     ✔  Server Load Balancer: ID: lb-f2z9xjgwvww9xwvrl07mv Name: slb-http-lcgieqmyicjcjynbmnnszwfnk  in eu-west-1 https_only? is expected to eq false
     ✔  Server Load Balancer: ID: lb-f2z91sk3h9qrnvo0vakq0 Name: slb-https-zueiskuwtotbnkhxfhwelwvio  in eu-west-1 is expected to exist
     ✔  Server Load Balancer: ID: lb-f2z91sk3h9qrnvo0vakq0 Name: slb-https-zueiskuwtotbnkhxfhwelwvio  in eu-west-1 https_listeners? is expected to eq true
     ✔  Server Load Balancer: ID: lb-f2z91sk3h9qrnvo0vakq0 Name: slb-https-zueiskuwtotbnkhxfhwelwvio  in eu-west-1 https_only? is expected to eq true
     ✔  Server Load Balancer:  in us-west-1 is expected not to exist
     ✔  https_listener: Load balancer id: lb-f2z91sk3h9qrnvo0vakq0 Port: 443  tls_cipher_policy is expected to eq "tls_cipher_policy_1_2"
  ✔  alicloud-sts-caller-identity-1.0: Ensure AliCloud STS caller identity has the correct properties.
     ✔  AliCloud Security Token Service Caller Identity is expected to exist
     ✔  AliCloud Security Token Service Caller Identity arn is expected not to be nil
  ✔  alicloud-slbs-1.0: Ensure AliCloud server load balancers plural resource has the correct properties.
     ✔  AliCloud SLBs is expected to exist
     ✔  AliCloud SLBs entries.count is expected to be > 1
  ×  alicloud-actiontrail-1.0: Ensure AliCloud Action Trail has the correct properties. (1 failed)
     ✔  ActionTrail at-pxloqgagcismmqfrvdaxvzojp is expected to exist
     ✔  ActionTrail empty response is expected not to exist
     ✔  ActionTrail at-pxloqgagcismmqfrvdaxvzojp is expected to exist
     ✔  ActionTrail at-pxloqgagcismmqfrvdaxvzojp oss_bucket_name is expected to eq "atb-fbqqvzofggorbyrkeeljuvcle"
     ✔  ActionTrail at-pxloqgagcismmqfrvdaxvzojp delivered_logs_days_ago is expected to eq 0
  ✔  alicloud-disk-1.0: Ensure AliCloud Diks has the correct properties.
     ✔  ECS Disk  is expected not to exist
     ✔  ECS Disk ID: d-d7o60wzvfooatqul7zrv Name: d-cdcyfxgcgqmxozvrgtvuppcay  is expected to exist
     ✔  ECS Disk ID: d-d7o60wzvfooatqul7zrv Name: d-cdcyfxgcgqmxozvrgtvuppcay  id is expected to eq "d-d7o60wzvfooatqul7zrv"
     ✔  ECS Disk ID: d-d7o60wzvfooatqul7zrv Name: d-cdcyfxgcgqmxozvrgtvuppcay  name is expected to eq "d-cdcyfxgcgqmxozvrgtvuppcay"
     ✔  ECS Disk ID: d-d7o60wzvfooatqul7zrv Name: d-cdcyfxgcgqmxozvrgtvuppcay  description is expected to cmp == "Test disk for inspec"
     ✔  ECS Disk ID: d-d7o60wzvfooatqul7zrv Name: d-cdcyfxgcgqmxozvrgtvuppcay  size is expected to cmp == "20"
     ✔  ECS Disk ID: d-d7o60wzvfooatqul7zrv Name: d-cdcyfxgcgqmxozvrgtvuppcay  category is expected to cmp == "cloud_efficiency"
     ✔  ECS Disk ID: d-d7o60wzvfooatqul7zrv Name: d-cdcyfxgcgqmxozvrgtvuppcay  encrypted is expected to cmp == false
     ✔  ECS Disk  is expected not to exist
  ✔  alicloud-ram-1.0: Ensure AliCloud RAM password policy has the correct properties
     ✔  AliCloud RAM Password Policy is expected to exist
     ✔  AliCloud RAM Password Policy require_uppercase_characters is expected to eq true
     ✔  AliCloud RAM Password Policy require_lowercase_characters is expected to eq true
     ✔  AliCloud RAM Password Policy require_symbols is expected to eq true
     ✔  AliCloud RAM Password Policy require_numbers is expected to eq true
     ✔  AliCloud RAM Password Policy password_reuse_prevention is expected to be >= 5
     ✔  AliCloud RAM Password Policy minimum_password_length is expected to be >= 8
     ✔  AliCloud RAM Password Policy max_password_age is expected to eq 180
  ✔  alicloud-disks-1.0: Ensure AliCloud disk plural resource has the correct properties.
     ✔  alicloud_disks is expected to exist
     ✔  alicloud_disks entries.count is expected to be > 1
  ✔  alicloud-actiontrails-1.0: Ensure AlicCloud Action Trail plural resource has the correct properties.
     ✔  alicloud_actiontrail_trails is expected to exist
     ✔  alicloud_actiontrail_trails count is expected to be >= 1
     ✔  alicloud_actiontrail_trails names is expected to include "at-pxloqgagcismmqfrvdaxvzojp"
  ✔  alicloud-security-groups-1.0: Ensure AliCloud security group plural resource has the correct properties.
     ✔  alicloud_security_groups is expected to exist
     ✔  alicloud_security_groups entries.count is expected to be > 1
  ✔  alicloud-security-group-1.0: Ensure AliCloud security group has the correct properties.
     ✔  ECS Security Group ID: empty response  is expected not to exist
     ✔  ECS Security Group ID: sg-d7oc67sykxtoi2w78cxx Name: sg-ifmifcolmsjofbrnjzwlewpyd VPC ID: vpc-d7o01mxxscv6fmlhrz7yv  is expected to exist
     ✔  ECS Security Group ID: sg-d7oc67sykxtoi2w78cxx Name: sg-ifmifcolmsjofbrnjzwlewpyd VPC ID: vpc-d7o01mxxscv6fmlhrz7yv  vpc_id is expected to eq "vpc-d7o01mxxscv6fmlhrz7yv"
     ✔  ECS Security Group ID: sg-d7oc67sykxtoi2w78cxx Name: sg-ifmifcolmsjofbrnjzwlewpyd VPC ID: vpc-d7o01mxxscv6fmlhrz7yv  group_name is expected to eq "sg-ifmifcolmsjofbrnjzwlewpyd"
     ✔  ECS Security Group ID: sg-d7oc67sykxtoi2w78cxx Name: sg-ifmifcolmsjofbrnjzwlewpyd VPC ID: vpc-d7o01mxxscv6fmlhrz7yv  description is expected to cmp == "Test security group for inspec"
     ✔  ECS Security Group ID: sg-d7oc67sykxtoi2w78cxx Name: sg-ifmifcolmsjofbrnjzwlewpyd VPC ID: vpc-d7o01mxxscv6fmlhrz7yv  inbound_rules.count is expected to be zero
     ✔  ECS Security Group ID: sg-d7oc67sykxtoi2w78cxx Name: sg-ifmifcolmsjofbrnjzwlewpyd VPC ID: vpc-d7o01mxxscv6fmlhrz7yv  outbound_rules.count is expected to be zero
     ✔  ECS Security Group ID: empty response  is expected not to exist
  ✔  alicloud-region-1.0: Ensure AliCloud region has the correct properties.
     ✔  Region eu-west-1 is expected to exist
     ✔  Region eu-west-1 region_name is expected to eq "eu-west-1"
     ✔  Region eu-west-1 endpoint is expected to eq "ecs.eu-west-1.aliyuncs.com"
     ✔  Region eu-west-1 is expected to exist
     ✔  Region eu-west-1 region_name is expected to eq "eu-west-1"
     ✔  Region eu-west-1 endpoint is expected to eq "ecs.eu-west-1.aliyuncs.com"
     ✔  Region not-a-real-region-1 is expected not to exist
  ✔  alicloud-regions-1.0: Ensure AliCloud regions plural resource has the correct properties.
     ✔  alicloud_regions is expected to exist
     ✔  alicloud_regions count is expected to be >= 1
     ✔  alicloud_regions region_names is expected to include "eu-west-1"
     ✔  alicloud_regions endpoints is expected to include "ecs.eu-west-1.aliyuncs.com"
  ✔  alicloud-ossbucket-1.0: Ensure AliCloud OSS Bucket has the correct properties.
     ✔  OSS Bucket not-there-bucket is expected not to exist
     ✔  OSS Bucket atb-fbqqvzofggorbyrkeeljuvcle is expected to exist
     ✔  OSS Bucket atb-fbqqvzofggorbyrkeeljuvcle is expected not to be public
     ✔  OSS Bucket ossbkt-rxpuubzmptugerrcomxvppxzm is expected to exist
     ✔  OSS Bucket ossbkt-rxpuubzmptugerrcomxvppxzm is expected not to be public
     ✔  OSS Bucket ossbkt-izzhnzzftjkhprxbgtzqcwofn is expected to exist
     ✔  OSS Bucket ossbkt-izzhnzzftjkhprxbgtzqcwofn is expected to have default encryption enabled
     ✔  OSS Bucket ossbkt-izzhnzzftjkhprxbgtzqcwofn bucket_lifecycle_rules is expected to be empty
     ✔  OSS Bucket ossbkt-ovjhudwiyftoqcdpftrgrslhq is expected to exist
     ✔  OSS Bucket ossbkt-ovjhudwiyftoqcdpftrgrslhq is expected not to have default encryption enabled
     ✔  OSS Bucket ossbkt-ovjhudwiyftoqcdpftrgrslhq bucket_lifecycle_rules is expected not to be empty
     ✔  OSS Bucket ossbkt-eeiwcntbikgvecbzogrsifrcn is expected to exist
     ✔  OSS Bucket ossbkt-eeiwcntbikgvecbzogrsifrcn is expected to have access logging enabled
     ✔  OSS Bucket ossbkt-nkeoxljuxkfuzejgmokflboif is expected to exist
     ✔  OSS Bucket ossbkt-nkeoxljuxkfuzejgmokflboif is expected not to have access logging enabled
     ✔  OSS Bucket ossbkt-zcdwvsmmatqwcvtbtqkulbbxl is expected to exist
     ✔  OSS Bucket ossbkt-bdliblqlxytomrstzomllhxwf is expected to exist
     ✔  OSS Bucket ossbkt-bdliblqlxytomrstzomllhxwf is expected to have versioning enabled
     ✔  OSS Bucket ossbkt-ypdzvuykcxloppdwhfnapljqg is expected to exist
     ✔  OSS Bucket ossbkt-ypdzvuykcxloppdwhfnapljqg is expected not to have versioning enabled
     ✔  OSS Bucket ossbkt-ypdzvuykcxloppdwhfnapljqg is expected to have website enabled
  ✔  alicloud-oss-buckets-1.0: Ensure AliCloud OSS Buckets plural resource has the correct properties.
     ✔  alicloud_oss_buckets is expected to exist
     ✔  alicloud_oss_buckets count is expected to be >= 9
     ✔  alicloud_oss_buckets bucket_names is expected to include "atb-fbqqvzofggorbyrkeeljuvcle"
     ✔  alicloud_oss_buckets bucket_names is expected to include "ossbkt-rxpuubzmptugerrcomxvppxzm"
     ✔  alicloud_oss_buckets bucket_names is expected to include "ossbkt-izzhnzzftjkhprxbgtzqcwofn"
     ✔  alicloud_oss_buckets bucket_names is expected to include "ossbkt-ovjhudwiyftoqcdpftrgrslhq"
     ✔  alicloud_oss_buckets bucket_names is expected to include "ossbkt-eeiwcntbikgvecbzogrsifrcn"
     ✔  alicloud_oss_buckets bucket_names is expected to include "ossbkt-nkeoxljuxkfuzejgmokflboif"
     ✔  alicloud_oss_buckets bucket_names is expected to include "ossbkt-zcdwvsmmatqwcvtbtqkulbbxl"
     ✔  alicloud_oss_buckets bucket_names is expected to include "ossbkt-bdliblqlxytomrstzomllhxwf"
     ✔  alicloud_oss_buckets bucket_names is expected to include "ossbkt-ypdzvuykcxloppdwhfnapljqg"
     ✔  alicloud_oss_buckets bucket_names is expected not to include "not-there-hopefully"


Profile: AliCloud Resource Pack (inspec-alicloud)
Version: 0.0.1
Target:  alicloud://eu-west-1

     No tests executed.

Profile Summary: 14 successful controls, 0 control failure, 0 controls skipped
Test Summary: 94 successful, 0 failure, 0 skipped
```

You should also clean up your Terraform created resources once you are done testing.

```bash
bundle exec rake test:cleanup_integration_tests
```


```
----> Cleanup
terraform destroy -force -var-file=inspec-alicloud.tfvars.json
...
Destroy complete! Resources: 24 destroyed.
```
