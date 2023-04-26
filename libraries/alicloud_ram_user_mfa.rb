require 'alicloud_backend'

class AliCloudRamUserMFA < AliCloudResourceBase
  name 'alicloud_ram_user_mfa'
  desc "Verifies settings for users' MFA."
  example <<-EXAMPLE
    # Ensure that MFA exists
    describe alicloud_ram_user_mfa(<user name>) do
      it { should exist }
    end
  EXAMPLE

  attr_reader :user_name, :serial_number, :type

  def initialize(opts = {})
    opts = { user_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: %i(user_name region))
    @user_name = opts[:user_name]

    @resp = fetch_mfa_info(opts)
    if @resp.nil?
      @serial_number = 'empty response'
      return
    end

    @mfa           = @resp
    @serial_number = @mfa['SerialNumber']
    @type          = @mfa['Type']
  end

  def fetch_mfa_info(opts)
    catch_alicloud_errors(ignore: 'EntityNotExist.User.MFADevice') do
      resp = @alicloud.ram_client.request(action: 'GetUserMFAInfo',
                                          params: { RegionId: opts[:region], UserName: opts[:user_name] },
                                          opts: { method: 'POST' })
      resp['MFADevice']
    end
  end

  def exists?
    !@mfa.nil?
  end

  def resource_id
    "#{@user_id || @user_name}_#{@serial_number}"
  end

  def to_s
    "AliCloud MFA #{@serial_number} for #{@user_name}"
  end
end
