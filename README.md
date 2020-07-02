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
