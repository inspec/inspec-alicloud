require 'alicloud_backend'

class AliCloudIMSSettings < AliCloudResourceBase
  name 'alicloud_ims_user'
  desc 'Verifies settings for AliCloud IMO User setting.'
  example <<-EXAMPLE
    describe alicloud_ims_user do
      it { should exist}
      it { have_sso_enabled }
      its('idp_domain') { should cmp 'mydomain.com' }
    end
  EXAMPLE

  attr_reader :status, :update_date, :password_reset_required, :user_principal_name, :mfa_bind_required

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(user_principal_name))

    catch_alicloud_errors do
      @resp = @alicloud.ims_client.request(
        action: 'GetLoginProfile',
        params: {
          "RegionId": opts[:region],
          'UserPrincipalName': opts[:user_principal_name],
        },
      )
    end

    @status = @resp['LoginProfile']['Status']
    @update_date = @resp['LoginProfile']['UpdateDate']
    @password_reset_required = @resp['LoginProfile']['PasswordResetRequired']
    @user_principal_name = @resp['LoginProfile']['UserPrincipalName']
    @mfa_bind_required = @resp['LoginProfile']['MFABindRequired']
  end

  def exists?
    !@resp.nil?
  end

  def to_s
    'AliCloud IMO User'
  end
end
