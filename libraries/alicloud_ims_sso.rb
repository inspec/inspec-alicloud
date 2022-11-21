require 'alicloud_backend'

class AliCloudSsoSettings < AliCloudResourceBase
  name 'alicloud_ims_sso'
  desc 'Verifies settings for AliCloud SSO settings.'
  example <<-EXAMPLE
    describe alicloud_ims_sso do
      it { should exist}
      it { have_sso_enabled }
      its('idp_domain') { should cmp 'mydomain.com' }
    end
  EXAMPLE

  attr_reader :sso_enabled, :auxiliary_domain

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(region))

    catch_alicloud_errors do
      @resp = @alicloud.ims_client.request(
        action: 'GetSamlSsoSettings',
        params: {
          "RegionId": opts[:region],
        },
      )
    end

    if @resp.nil? || @resp['SamlSsoSettings'].nil?
      @sso_enabled = false
      @auxiliary_domain = nil
      return
    end

    @sso_enabled = @resp['SamlSsoSettings']['SsoEnabled']
    @auxiliary_domain = @resp['SamlSsoSettings']['AuxiliaryDomain']
  end

  def exists?
    !@resp.nil?
  end

  def has_sso_enabled?
    @sso_enabled
  end

  def to_s
    'AliCloud SSO Settings'
  end
end
