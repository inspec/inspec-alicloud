require 'set'
require 'openssl'
require 'rest-client'
require 'active_support/all'
require 'alicloud/helpers/authentication'
require 'alicloud/helpers/params'
require 'inspec' unless defined?(::Inspec::VERSION) # tests don't recognise inspec version unless required!

module AliCloud
  ConnectionError = Class.new(StandardError)
  class APIClient
    include Helpers::Authentication
    include Helpers::Params
    attr_accessor :endpoint, :api_version, :access_key_id, :access_key_secret, :security_token, :codes, :opts, :verbose,
                  :http_method

    DEFAULT_UA = "Inspec-Alicloud #{Gem::Platform.local.os} #{Gem::Platform.local.cpu}) Ruby/#{RUBY_VERSION} Core/#{Inspec::VERSION}".freeze
    DEFAULT_CONTENT_TYPE = 'application/x-www-form-urlencoded'.freeze
    def initialize(config, verbose: false)
      validate(config)

      self.endpoint = config[:endpoint]
      self.api_version = config[:api_version]
      self.access_key_id = config[:access_key_id]
      self.access_key_secret = config[:access_key_secret]
      self.security_token = config[:security_token]
      self.opts = config[:opts] || {}
      self.verbose = verbose.instance_of?(TrueClass) && verbose
      self.codes = Set.new([200, '200', 'OK', 'Success'])
      codes.merge(config[:codes]) if config[:codes]
    end

    def request(action:, params: {}, opts: {})
      opts = self.opts.merge(opts)
      self.http_method = (opts[:method] || 'GET').upcase
      querystring = querystring_from(opts, action, params)
      uri = http_method == 'POST' ? '/' : "/?#{querystring}"

      headers = { 'User-Agent' => DEFAULT_UA }
      if http_method == 'POST'
        headers['Content-Type'] = DEFAULT_CONTENT_TYPE
        body = querystring
      end

      response = execute_request(http_method, uri, headers, body)
      JSON.parse(response.body)
    rescue RestClient::ExceptionWithResponse => e
      handle_rest_client_exception(e, uri)
    rescue StandardError => e
      handle_generic_exception(e)
    end

    private

    def execute_request(method, uri, headers, body)
      RestClient::Request.execute(
        method: method.downcase.to_sym,
        url: "#{endpoint}#{uri}",
        headers: headers,
        payload: body,
      )
    end

    def handle_rest_client_exception(exception, uri)
      response_body = JSON.parse(exception.response.body)
      if response_body['Code'] && !response_body['Code'].to_s.empty? && !codes.include?(response_body['Code'])
        raise StandardError, "Code: #{response_body['Code']}, Message: #{response_body['Message']}, URL: #{uri}"
      end

      response_body
    end

    def handle_generic_exception(exception)
      raise AliCloud::ConnectionError, "Failed to execute request: #{exception.message}"
    end
  end
end
