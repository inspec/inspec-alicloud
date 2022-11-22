require 'alicloud_backend'

class AliCloudRam < AliCloudResourceBase
  name 'alicloud_ram_password_policy'
  desc 'Verifies properties for an individual AliCloud RAM Password Policy.'
  example <<-EXAMPLE
    describe alicloud_ram_password_policy do
      it { should exist }
      its('require_uppercase_characters') { should eq true }
      its('require_lowercase_characters') { should eq true }
      its('require_symbols') { should eq true }
      its('require_numbers') { should eq true }
      its('password_reuse_prevention') { should be >= 5 }
      its('minimum_password_length') { should be >= 8 }
      its('max_password_age') { should eq 180 }
    end
  EXAMPLE

  attr_reader :hard_expiry, :max_login_attempts, :max_password_age, :minimum_password_length,
              :password_reuse_prevention, :require_lowercase_characters, :require_numbers,
              :require_symbols, :require_uppercase_characters

  def initialize(opts = {})
    super(opts)
    validate_parameters(required: %i(region))

    catch_alicloud_errors do
      @resp = @alicloud.ram_client.request(
        action: 'GetPasswordPolicy',
        params: {
          'RegionId': opts[:region],
        },
        opts: {
          method: 'POST',
        },
      )['PasswordPolicy']
    end
    if @resp.nil?
      @ram_id = 'empty response'
      return
    end

    @ram_info                     = @resp
    @hard_expiry                  = @ram_info['HardExpiry']
    @max_login_attempts           = @ram_info['MaxLoginAttemps']
    @max_password_age             = @ram_info['MaxPasswordAge']
    @minimum_password_length      = @ram_info['MinimumPasswordLength']
    @password_reuse_prevention    = @ram_info['PasswordReusePrevention']
    @require_lowercase_characters = @ram_info['RequireLowercaseCharacters']
    @require_numbers              = @ram_info['RequireNumbers']
    @require_symbols              = @ram_info['RequireSymbols']
    @require_uppercase_characters = @ram_info['RequireUppercaseCharacters']
  end

  def exists?
    !@ram_info.nil?
  end

  def resource_id
    "alicloud_ram_password_policy_#{@opts[:region]}"
  end

  def to_s
    'AliCloud RAM Password Policy'
  end
end
