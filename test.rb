require_relative 'libraries/alicloud_backend'
client_args = { }
@alicloud = AliCloudConnection.new(client_args)

sts_client = @alicloud.sts_client

@alicloud.unique_identifier

caller_identity = sts_client.request(action: 'GetCallerIdentity')

actiontrail_client = @alicloud.actiontrail_client
