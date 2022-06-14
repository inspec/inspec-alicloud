# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudRamUsers < AliCloudResourceBase
  name 'alicloud_ram_users'
  desc 'Verifies settings for AliCloud ram users'

  example "
    # ensure there's more than 1 users
    describe alicloud_ram_users do
    its('entries.count') { should be > 1 }
    end
    "

  attr_reader :table

  # FilterTable setup
  FilterTable.create
             .register_column(:update_dates, field: :update_date)
             .register_column(:user_names, field: :user_name)
             .register_column(:user_ids, field: :user_id)
             .register_column(:comments_s, field: :comments)
             .register_column(:display_names, field: :display_name)
             .register_column(:create_dates, field: :create_date)
             .register_column(:has_console_access, field: :has_console_access)
             .register_column(:access_keys, field: :access_keys)
             .register_column(:has_access_key, field: :has_access_key)
             .register_column(:active_access_keys, field: :active_access_keys)
             .register_column(:has_active_access_key, field: :has_active_access_key)
             .register_column(:has_console_and_key_access, field: :has_console_and_key_access)
             .register_column(:has_mfa_enabled, field: :has_mfa_enabled)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(region))

    @users = fetch_users(opt[:region])
    return [] if !@users || @users.empty?

    user_rows = []
    @users.map do |user|
      user_name = user['UserName']

      login_profile = fetch_login_profile(opts[:region], user_name)
      access_keys = fetch_access_keys(opts[:region], user_name)
      active_access_keys = if access_keys.nil?
                             []
                           else
                             access_keys.select do |x|
                               x['Status'] == 'Active'
                             end.map { |x| x['AccessKeyId'] }
                           end
      mfa = fetch_user_mfa(opts[:region], user_name)

      user_rows += [{
        update_date: user['UpdateDate'],
        user_name: user_name,
        user_id: user['UserId'],
        comments: user['Comments'],
        display_name: user['DisplayName'],
        create_date: user['CreateDate'],
        has_console_access: login_profile.nil? ? false : true,
        access_keys: access_keys.nil? ? [] : access_keys.map { |x| x['AccessKeyId'] },
        has_access_key: access_keys.nil? ? false : true,
        active_access_keys: if access_keys.nil?
                              []
                            else
                              access_keys.select do |x|
                                x['Status'] == 'Active'
                              end.map { |x| x['AccessKeyId'] }
                            end,
        has_active_access_key: active_access_keys.count.positive? ? true : false,
        has_console_and_key_access: !login_profile.nil? && active_access_keys.count.positive?,
        has_mfa_enabled: mfa.nil? ? false : true,
      }]
    end
    @table = user_rows
  end

  def fetch_users(_region)
    catch_alicloud_errors do
      resp = @alicloud.ram_client.request(
        action: 'ListUsers',
        params: {
          'RegionId': opts[:region],
        },
      )['Users']['User']
      return resp
    end
  end

  def fetch_login_profile(region, user)
    catch_alicloud_errors('EntityNotExist.User.LoginProfile') do
      resp = @alicloud.ram_client.request(
        action: 'GetLoginProfile',
        params: {
          'RegionId': region,
          'UserName': user,
        },
        opts: {
          method: 'POST',
        },
      )['LoginProfile']
      return resp
    end
  end

  def fetch_access_keys(region, user)
    catch_alicloud_errors do
      resp = @alicloud.ram_client.request(
        action: 'ListAccessKeys',
        params: {
          'RegionId': region,
          'UserName': user,
        },
        opts: {
          method: 'POST',
        },
      )['AccessKeys']['AccessKey']
      return resp
    end
  end

  def fetch_user_mfa(region, user)
    catch_alicloud_errors('EntityNotExist.User.MFADevice') do
      resp = @alicloud.ram_client.request(
        action: 'GetUserMFAInfo',
        params: {
          'RegionId': region,
          'UserName': user,
        },
        opts: {
          method: 'POST',
        },
      )['MFADevice']
      return resp
    end
  end

  def exists?
    !@user.nil?
  end
end
