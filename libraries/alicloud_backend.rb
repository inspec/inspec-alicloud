require 'aliyunsdkcore'
require 'aliyun/oss'
require 'rspec/expectations'
require 'alicloud/oss/client'

# AliCloud Inspec Backend Classes
#
# Class to manage the AliCloud connection, instantiates all required clients for inspec resources
#
class AliCloudConnection
  # include AliCloud::OSS

  def initialize(params)
    params = {} if params.nil?
    if params.is_a?(Hash)

      # TODO: look into this a bit more below is the original code from AWS
      # it does not look like we implement client_args at this point
      # this was stopping us from passing a region parameter as params.fetch(:client_args, nil)
      # always returns nill
      # @client_args = params.fetch(:client_args, nil)

      # replacement for now
      @client_args = params
    end
    @cache = {}
  end

  def alicloud_client(api:, api_version:)
    region = @client_args.fetch(:region, nil) || ENV['ALICLOUD_REGION'] if @client_args
    region ||= ENV['ALICLOUD_REGION']

    endpoint = @client_args.fetch(:endpoint, nil) if @client_args
    endpoint ||= if %w{sts ram resourcemanager ims rds}.include?(api)
                   "https://#{api}.aliyuncs.com"
                 elsif %w{vpc
                          slb}.include?(api) && %w{cn-qingdao cn-beijing cn-beijing cn-shanghai cn-shenzhen cn-hongkong ap-southeast-1 us-west-1
                                                   us-east-1 cn-shanghai-finance-1 cn-shenzhen-finance-1 cn-north-2-gov-1}.include?(region)
                   # AliCloud VPN endpoints vary between regions, so the following accounts for that variability
                   "https://#{api}.aliyuncs.com"
                 elsif api == 'ecs' && %w{cn-hongkong ap-southeast-1 us-west-1 us-east-1
                                          cn-north-2-gov-1}.include?(region)
                   "https://#{api}.#{region}.aliyuncs.com"
                 else
                   "https://#{api}.#{region}.aliyuncs.com"
                 end
    client = RPCClient.new(
      access_key_id: ENV['ALICLOUD_ACCESS_KEY'],
      access_key_secret: ENV['ALICLOUD_SECRET_KEY'],
      security_token: ENV['ALICLOUD_SECURITY_TOKEN'],
      endpoint: endpoint,
      api_version: api_version,
    )
    AliCloudCommonClient.new(client)
  end

  def aliyun_oss_client
    region = @client_args.fetch(:region, nil) || ENV['ALICLOUD_REGION'] if @client_args
    region ||= ENV['ALICLOUD_REGION']

    endpoint = "https://oss-#{region}.aliyuncs.com"
    Aliyun::OSS::Client.new(
      endpoint: endpoint,
      access_key_id: ENV['ALICLOUD_ACCESS_KEY'],
      access_key_secret: ENV['ALICLOUD_SECRET_KEY'],
      sts_token: ENV['ALICLOUD_SECURITY_TOKEN'],
    )
  end

  def alicloud_oss_client_custom
    region = @client_args.fetch(:region, nil) || ENV['ALICLOUD_REGION'] if @client_args
    region ||= ENV['ALICLOUD_REGION']

    endpoint = "https://oss-#{region}.aliyuncs.com"
    AliCloud::OSS::Client.new(
      endpoint: endpoint,
      access_key_id: ENV['ALICLOUD_ACCESS_KEY'],
      access_key_secret: ENV['ALICLOUD_SECRET_KEY'],
      sts_token: ENV['ALICLOUD_SECURITY_TOKEN'],
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

  def oss_client
    aliyun_oss_client
  end

  def sts_client
    alicloud_client(api: 'sts', api_version: '2015-04-01')
  end

  def ram_client
    alicloud_client(api: 'ram', api_version: '2015-05-01')
  end

  def rm_client
    alicloud_client(api: 'resourcemanager', api_version: '2020-03-31')
  end

  def vpc_client
    alicloud_client(api: 'vpc', api_version: '2016-04-28')
  end

  def ims_client
    alicloud_client(api: 'ims', api_version: '2019-08-15')
  end

  def rds_client
    alicloud_client(api: 'rds', api_version: '2014-08-15')
  end
end

# an AliCloud RPCClient Wrapper to handle pagination response
class AliCloudCommonClient
  def initialize(client)
    @client = client
  end

  # same method signature as RPCClient.request
  def request(action:, params: {}, opts: {})
    page_number = 1
    response_total = nil
    loop do
      # add PageNumber only for paginated request when PageNumber > 1
      params[:PageNumber] = page_number if page_number > 1
      response = @client.request(
        action: action,
        params: params,
        opts: opts,
      )
      if response_total.nil?
        response_total = response
      else
        # merge response
        response.each_key do |key|
          if response[key].instance_of? Hash
            response[key].each_key do |key_next|
              next unless response[key][key_next].instance_of? Array

              # combine the data
              response_total[key][key_next] += response[key][key_next]
            end
          else
            # overwrite other values
            response_total[key] = response[key]
          end
        end
      end
      # stop looping if the response is not paginated or has reached the last page
      if response['PageNumber'].nil? || response['PageSize'].nil? || (page_number * response['PageSize'] >= response['TotalCount'])
        break
      end

      page_number += 1
    end
    response_total
  end
end

# Base class for AliCloud resources
class AliCloudResourceBase < Inspec.resource(1)
  attr_reader :opts, :alicloud

  def initialize(opts)
    @opts = opts
    # ensure we have a AliCloud connection, resources can choose which of the clients to instantiate
    client_args = {}
    if @opts.is_a?(Hash)
      # below allows each resource to optionally and conveniently set a region
      client_args[:region] = opts[:region] if opts[:region]
      # below allows each resource to optionally and conveniently set an endpoint
      client_args[:endpoint] = opts[:endpoint] if opts[:endpoint]
      # Default region to ALICLOUD_REGION env var - needed in the resource requests for most resources
      @opts[:region] ||= ENV['ALICLOUD_REGION']
    end
    @alicloud = AliCloudConnection.new(client_args)
  end

  # Ensure required parameters have been set to perform backend operations.
  # Some resources may require several parameters to be set, in which case use `required`
  # Some resources may require at least 1 of n parameters to be set, in which case use `require_any_of`
  # If a parameter is entirely optional, use `allow`
  def validate_parameters(allow: [], required: nil, require_any_of: nil)
    if required
      unless required.is_a?(Array) && required.all? do |r|
               r.is_a?(Symbol)
             end
        raise ArgumentError,
              "Expected required parameters as Array of Symbols, got #{required}"
      end

      if required.include?(:region) && (!@opts.is_a?(Hash) || (@opts[:region].nil? || @opts[:region] == ''))
        raise ArgumentError,
              "#{@__resource_name__}: region must be provided via environment variable or hash parameter"
      end
      unless @opts.is_a?(Hash) && required.all? do |req|
               @opts.key?(req) && !@opts[req].nil? && @opts[req] != ''
             end
        raise ArgumentError,
              "#{@__resource_name__}: `#{required}` must be provided"
      end

      allow += required
    end

    if require_any_of
      unless require_any_of.is_a?(Array) && require_any_of.all? do |r|
               r.is_a?(Symbol)
             end
        raise ArgumentError,
              "Expected required parameters as Array of Symbols, got #{require_any_of}"
      end
      unless @opts.is_a?(Hash) && require_any_of.any? do |req|
               @opts.key?(req) && !@opts[req].nil? && @opts[req] != ''
             end
        raise ArgumentError,
              "#{@__resource_name__}: One of `#{require_any_of}` must be provided."
      end

      allow += require_any_of
    end

    allow += %i(region) unless allow.include?(:region)
    allow += %i(endpoint) unless allow.include?(:endpoint)
    @opts.delete(:region) if @opts.is_a?(Hash) && @opts[:region].nil?

    raise ArgumentError, 'Scalar arguments not supported' unless defined?(@opts.keys)
    raise ArgumentError, 'Unexpected arguments found' unless @opts.keys.all? { |a| allow.include?(a) }
    raise ArgumentError, 'Provided parameter should not be empty' unless @opts.values.all? do |a|
      return true if a.instance_of?(Integer) || a.instance_of?(TrueClass) || a.instance_of?(FalseClass)

      !a.empty?
    end

    true
  end

  def failed_resource?
    @failed_resource ||= false
  end

  # Intercept AliCloud exceptions
  def catch_alicloud_errors(ignore = [])
    yield # Catch and create custom messages as needed
  rescue ArgumentError
    Inspec::Log.error 'It appears that you have not set your AliCloud credentials.'
    fail_resource('No AliCloud credentials available')
  rescue StandardError => e
    ignore = [ignore] if ignore.is_a?(String)
    ignore.each { |error| return nil if e.message =~ /\b#{error}\b/ }
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

  def to_s
    nil
  end
end
