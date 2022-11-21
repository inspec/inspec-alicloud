require 'alicloud_backend'

class AliCloudResourceDirectory < AliCloudResourceBase
  name 'alicloud_resource_directory'
  desc 'Verifies settings for an AliCloud resource management.'
  example <<-EXAMPLE
    describe alicloud_resource_directory do
      it { should exist}
      its('resource_directory_id') { should eq 'rd-directory-id' }
      its('master_account_name') { should eq 'master-account-name' }
    end
  EXAMPLE

  attr_reader :resource_directory_id, :master_account_name, :master_account_id

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(region))

    catch_alicloud_errors do
      @resp = @alicloud.rm_client.request(
        action: 'GetResourceDirectory',
        params: {
          "RegionId": opts[:region],
        },
      )
    end

    if @resp.nil? || @resp['ResourceDirectory'].nil?
      @resource_directory_id = nil
      @master_account_name = nil
      @master_account_id = nil
      return
    end

    @resource_directory_id = @resp['ResourceDirectory']['ResourceDirectoryId']
    @master_account_name = @resp['ResourceDirectory']['MasterAccountName']
    @master_account_id = @resp['ResourceDirectory']['MasterAccountId']
  end

  def exists?
    !@resp.nil?
  end

  def resource_id
    "#{@resource_directory_id}_#{@opts[:region]}"
  end

  def to_s
    "AliCloud Resource Directory: #{@resource_directory_id}, Master Account: #{@master_account_name}(#{@master_account_id})"
  end
end
