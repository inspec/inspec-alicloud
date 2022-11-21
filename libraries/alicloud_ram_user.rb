require 'alicloud_backend'

class AliCloudRamUser < AliCloudResourceBase
  name 'alicloud_ram_user'
  desc 'Verifies settings for AliCloud ram users.'
  example <<-EXAMPLE
    # Ensure a user exists
    describe alicloud_ram_user('ALICLOUD_USER_NAME') do
      it {should exist}
    end
  EXAMPLE

  attr_reader :user_name, :user_id, :display_name, :comments, :email,
              :mobile_phone, :create_date, :update_date, :last_login_date,
              :access_keys, :active_access_keys

  def initialize(opts = {})
    opts = { user_name: opts } if opts.is_a?(String)
    super(opts)
    @opts = opts
    validate_parameters(required: %i(user_name region))

    @resp = fetch_user_info(opts)
    return if @resp.nil?

    @user            = @resp
    @user_name       = @user['UserName']
    @user_id         = @user['UserId']
    @display_name    = @user['DisplayName']
    @comments        = @user['Comments']
    @email           = @user['Email']
    @mobile_phone    = @user['MobilePhone']
    @create_date     = @user['CreateDate']
    @update_date     = @user['UpdateDate']
    @last_login_date = @user['LastLoginDate']

    login_profile = fetch_login_profile(opts)
    @has_console_access = login_profile.nil? ? false : true

    access_keys = fetch_access_keys(opts)
    @access_keys = access_keys.nil? ? [] : access_keys.map { |x| x['AccessKeyId'] }
    @active_access_keys = if access_keys.nil?
                            []
                          else
                            access_keys.select do |x|
                              x['Status'] == 'Active'
                            end.map { |x| x['AccessKeyId'] }
                          end

    @has_active_access_key = @active_access_keys != []
    @has_console_and_key_access = has_console_and_key_access?
  end

  def has_console_and_key_access?
    @has_console_access && !@active_access_keys.nil? && @active_access_keys != []
  end

  def has_console_access?
    @has_console_access
  end

  def has_active_access_key?
    @has_active_access_key
  end

  def fetch_user_info(opts)
    catch_alicloud_errors('EntityNotExist.User') do
      resp = @alicloud.ram_client.request(
        action: 'GetUser',
        params: {
          'RegionId': opts[:region],
          'UserName': opts[:user_name],
        },
        opts: {
          method: 'POST',
        },
      )['User']
      return resp
    end
  end

  def fetch_login_profile(opts)
    catch_alicloud_errors('EntityNotExist.User.LoginProfile') do
      resp = @alicloud.ram_client.request(
        action: 'GetLoginProfile',
        params: {
          'RegionId': opts[:region],
          'UserName': opts[:user_name],
        },
        opts: {
          method: 'POST',
        },
      )['LoginProfile']
      return resp
    end
  end

  def fetch_access_keys(opts)
    catch_alicloud_errors do
      resp = @alicloud.ram_client.request(
        action: 'ListAccessKeys',
        params: {
          'RegionId': opts[:region],
          'UserName': opts[:user_name],
        },
        opts: {
          method: 'POST',
        },
      )['AccessKeys']['AccessKey']
      return resp
    end
  end

  def exists?
    !@user.nil?
  end

  def resource_id
    @user_id
  end

  def to_s
    "AliCloud RAM User #{@opts[:user_name]}"
  end
end
