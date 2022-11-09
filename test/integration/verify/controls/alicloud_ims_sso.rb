title 'Test AliCloud IMS SSO Properties'

control 'alicloud_ims_sso-1.0' do
  impact 1.0
  title 'Ensure AliCloud IMS SSO has correct attributes.'

  describe alicloud_ims_sso do
    it { should exist }
    it { have_sso_enabled }
    its('idp_domain') { should cmp 'mydomain.com' }
  end
end
