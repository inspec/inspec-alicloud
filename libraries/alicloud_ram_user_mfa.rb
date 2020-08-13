# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudRamUserMFA < AliCloudResourceBase
  name 'alicloud_ram_user_mfa'
  desc 'Verifies settings for users\' MFA'

  example '
  # make sure MFA exists
  describe alicloud_ram_user_mfa(<user name>) do
    it { should exist }
  end
  '

  attr_reader :serial_number

  def initialize(opts = {})
    opts = { user_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: %i(user_name))

    catch_alicloud_errors do
      @resp = @alicloud.ram_client.request(
        action: 'GetUserMFAInfo',
        params: {
          'RegionId': opts[:region],
          'UserName': opts[:user_name],
        },
        opts: {
          method: 'POST',
        },
      )['MFADevice']
    end

    if @resp.nil?
      @serial_number = 'empty response'
      return
    end

    @mfa                = @resp
    @serial_number      = @mfa['SerialNumber']
  end

  def exists?
    !@mfa.nil?
  end

  def to_s
    "MFA for #{serial_number}"
  end
end
