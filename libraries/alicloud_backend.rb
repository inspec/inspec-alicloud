# frozen_string_literal: true

require 'aliyunsdkcore'
require 'rspec/expectations'

# AliCloud Inspec Backend Classes
#
# Class to manage the AliCloud connection, instantiates all required clients for inspec resources
#
class AliCloudConnection
  def initialize(params)
    params = {} if params.nil?
    if params.is_a?(Hash)
      @client_args = params.fetch(:client_args, nil)
    end
    @cache = {}
  end

  def alicloud_client(api:, api_version:)
    region = @client_args.fetch(:region, nil) || ENV['ALICLOUD_REGION'] if @client_args
    region ||= ENV['ALICLOUD_REGION']

    endpoint = @client_args.fetch(:endpoint, nil) if @client_args
    endpoint ||= if api == 'sts'
                   "https://#{api}.aliyuncs.com"
                 else
                   "https://#{api}.#{region}.aliyuncs.com"
                 end

    RPCClient.new(
      access_key_id:     ENV['ALICLOUD_ACCESS_KEY'],
      access_key_secret: ENV['ALICLOUD_SECRET_KEY'],
      endpoint:          endpoint,
      api_version:       api_version
    )
  end

  def unique_identifier
    # use alicloud account id
    caller_identity = sts_client.request(action: 'GetCallerIdentity')
    caller_identity['AccountId']
  end

  # Client convenience methods
  def actiontrail_client
    alicloud_client(api: 'actiontrail', api_version: '2017-12-04')
  end

  def slb_client
    alicloud_client(api: 'slb', api_version: '2014-05-15')
  end

  def ecs_client
    alicloud_client(api: 'ecs', api_version: '2014-05-26')
  end

  def sts_client
    alicloud_client(api: 'sts', api_version: '2015-04-01')
  end
end

# Base class for AliCloud resources
class AliCloudResourceBase < Inspec.resource(1)
  attr_reader :opts, :alicloud

  def initialize(opts)
    @opts = opts
    # ensure we have a AliCloud connection, resources can choose which of the clients to instantiate
    client_args = {}
    if opts.is_a?(Hash)
      # below allows each resource to optionally and conveniently set a region
      client_args[:region] = opts[:region] if opts[:region]
      # below allows each resource to optionally and conveniently set an endpoint
      client_args[:endpoint] = opts[:endpoint] if opts[:endpoint]
    end
    # Default region to ALICLOUD_REGION env var - needed in the resource requests for most resources
    @opts[:region] ||= ENV['ALICLOUD_REGION']
    @alicloud = AliCloudConnection.new(client_args)
  end

  # Ensure required parameters have been set to perform backend operations.
  # Some resources may require several parameters to be set, in which case use `required`
  # Some resources may require at least 1 of n parameters to be set, in which case use `require_any_of`
  # If a parameter is entirely optional, use `allow`
  def validate_parameters(allow: [], required: nil, require_any_of: nil)
    if required
      raise ArgumentError, "Expected required parameters as Array of Symbols, got #{required}" unless required.is_a?(Array) && required.all? { |r| r.is_a?(Symbol) }
      raise ArgumentError, "#{@__resource_name__}: `#{required}` must be provided" unless @opts.is_a?(Hash) && required.all? { |req| @opts.key?(req) && !@opts[req].nil? && @opts[req] != '' }
      allow += required
    end

    if require_any_of
      raise ArgumentError, "Expected required parameters as Array of Symbols, got #{require_any_of}" unless require_any_of.is_a?(Array) && require_any_of.all? { |r| r.is_a?(Symbol) }
      raise ArgumentError, "#{@__resource_name__}: One of `#{require_any_of}` must be provided." unless @opts.is_a?(Hash) && require_any_of.any? { |req| @opts.key?(req) && !@opts[req].nil? && @opts[req] != '' }
      allow += require_any_of
    end

    allow += %i(region endpoint)
    raise ArgumentError, 'Scalar arguments not supported' unless defined?(@opts.keys)
    raise ArgumentError, 'Unexpected arguments found' unless @opts.keys.all? { |a| allow.include?(a) }
    raise ArgumentError, 'Provided parameter should not be empty' unless @opts.values.all? do |a|
      return true if a.class == Integer
      !a.empty?
    end
    true
  end

  def failed_resource?
    @failed_resource ||= false
  end

  # Intercept AliCloud exceptions
  def catch_alicloud_errors
    yield # Catch and create custom messages as needed
  rescue ArgumentError
    Inspec::Log.error 'It appears that you have not set your AliCloud credentials.'
    fail_resource('No AliCloud credentials available')
  rescue StandardError => e
    Inspec::Log.warn "AliCloud Service Error encountered running a control with Resource #{@__resource_name__}. " \
                      "Error message: #{e.message}. You should address this error to ensure your controls are " \
                      'behaving as expected.'
    @failed_resource = true
    nil
  end

  # Prevent undefined method error by returning nil.
  # This will prevent breaking a test when queried a non-existing method.
  # @return [NilClass]
  # @see https://github.com/inspec/inspec-azure/blob/master/libraries/support/azure/response.rb
  def method_missing(method_name, *args, &block)
    if respond_to?(method_name)
      super
    else
      NullResponse.new
    end
  end

  # This is to make RuboCop happy.
  def respond_to_missing?(*several_variants)
    super
  end
end

# Ensure to return nil recursively.
# @see https://github.com/inspec/inspec-azure/blob/master/libraries/support/azure/response.rb
#
class NullResponse
  def nil?
    true
  end
  alias empty? nil?

  def ==(other)
    other.nil?
  end
  alias === ==
  alias <=> ==

  def key?(_key)
    false
  end

  def method_missing(method_name, *args, &block)
    if respond_to?(method_name)
      super
    else
      self
    end
  end

  # This is to make RuboCop happy.
  def respond_to_missing?(*several_variants)
    super
  end

  def to_s
    nil
  end
end
