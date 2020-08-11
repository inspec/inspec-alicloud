# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudRamUser < AliCloudResourceBase
  name 'alicloud_ram_user'
  desc 'Verifies settings for AliCloud ram users'

  example "
  # ensure a user exists
  describe alicloud_ram_user(alicloud_ram_user_name) do
    it {should exist}
  end
  "

  attr_reader :update_date, :user_name, :email, :user_id, :comments,
              :display_name, :last_login_date, :create_date, :mobile_phone

  def initialize(opts = {})
    opts = { user_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: %i(user_name))

    catch_alicloud_errors do
      @resp = @alicloud.ram_client.request(
        action: 'GetUser',
        params: {
          'RegionId': opts[:region],
          "UserName": opts[:user_name],
        },
        opts: {
          method: 'POST',
        },
      )['User']
    end

    if @resp.nil?
      @user_id = 'empty response'
      return
    end

    @user = @resp
    @update_date        = @resp['UpdateDate']
    @user_name          = @resp['UserName']
    @email              = @resp['Email']
    @user_id            = @resp['UserId']
    @comments           = @resp['Comments']
    @display_name       = @resp['DisplayName']
    @last_login_date    = @resp['LastLoginDate']
    @create_date        = @resp['CreateDate']
    @mobile_phone       = @resp['MobilePhone']
  end

  def exists?
    !@user.nil?
  end

  def to_s
    "RAM User #{@user_id}"
  end
end
