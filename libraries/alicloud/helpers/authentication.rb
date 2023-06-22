# frozen_string_literal: true

module AliCloud
  module Helpers
    module Authentication
      private

      def generate_signature(string_to_sign)
        key = "#{access_key_secret}&"
        Base64.encode64(OpenSSL::HMAC.digest('sha1', key, string_to_sign)).strip
      end

      def default_params
        default_params = {
          'Format' => 'JSON',
          'SignatureMethod' => 'HMAC-SHA1',
          'SignatureNonce' => SecureRandom.hex(16),
          'SignatureVersion' => '1.0',
          'Timestamp' => Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
          'AccessKeyId' => access_key_id,
          'Version' => api_version,
        }
        default_params.merge!('SecurityToken' => security_token) if security_token
        default_params
      end
    end
  end
end
