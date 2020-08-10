# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudRamUserMFA < AliCloudResourceBase
  name 'alicloud_ram_user_mfa'
  desc 'Verifies settings for users\' MFA'

  attr_reader :serial_number

  def initialize(opts = {})
    opts = { user_name: opts } if opts.is_a?(String)
    super(opts)

    catch_alicloud_errors do
      @resp = @alicloud.ram_client.request(
        action: 'GetUserMFAInfo',
        params: {
          'RegionId': opts[:region],
          "UserName": opts[:user_name],
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
    !@serial_number.nil?
  end

  def to_s
    "MFA for #{user_name}"
  end
end
