# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudRamPolicy < AliCloudResourceBase
  name 'alicloud_ram_policy'
  desc 'Verifies settings for a RAM Policy'

  example "
    describe alicloud_ram_policy('policy-1') do
      it { should exist }
      its('default_version') { should be 'v1' }
      it { should have_statement('Effect' => 'Allow', 'Resource' => '*', 'Action' => 'ecs:Describe*') }
      its('statement_count') { should > 1 }
      its{'attached_users') { should include 'user-1' }
      it { should be_attached_to_role('acs:ram::12345:role/role-1') }
      its('attachment_count') { should be > 1 }
    end
  "

  attr_reader :policy_name, :default_version, :policy_document,
              :attached_users, :attached_roles, :attached_groups,
              :attached_user_count, :attached_role_count, :attached_group_count,
              :attachment_count

  def initialize(opts = {})
    opts = { policy_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: %i(policy_name region), allow: %i(type))
    @opts = opts

    if opts[:type]
      @resp = get_policy(opts)
    else
      opts[:type] = 'Custom'
      @resp = get_policy(opts)
      if @resp.nil?
        opts[:type] = 'System'
        @resp = get_policy(opts)
      end
    end
    return if @resp.nil?

    @policy = @resp['Policy']
    @policy_name = opts[:policy_name]
    @default_version = @resp['Policy']['DefaultVersion']
    @policy_document = @resp['DefaultPolicyVersion']['PolicyDocument']

    @attached_users = @attached_groups = @attached_roles = @attachment_count = 0

    entities = get_attached_entities(opts)
    return if entities.nil?

    @attached_users = entities['Users']['User'].map { |x| x['UserName'] }
    @attached_user_count = @attached_users.length
    @attached_groups = entities['Groups']['Group'].map { |x| x['GroupName'] }
    @attached_group_count = @attached_groups.length
    @attached_roles = entities['Roles']['Role'].map { |x| x['Arn'] }
    @attached_role_count = @attached_roles.length
    @attachment_count = @attached_user_count + @attached_group_count + @attached_role_count
  end

  def get_policy(opts)
    filters = { RegionId: opts[:region],
                PolicyName: opts[:policy_name],
                PolicyType: opts[:type] }
    catch_alicloud_errors('EntityNotExist.Policy') do
      resp = @alicloud.ram_client.request(
        action: 'GetPolicy',
        params: filters,
        opts: {
          method: 'POST',
        },
      )

      return resp
    end
  end

  def exists?
    !@policy.nil?
  end

  def has_statement?(criteria = {})
    return false unless @policy_document

    document = JSON.parse(URI.decode_www_form_component(@policy_document), { symbolize_names: true })
    statements = document[:Statement].is_a?(Array) ? document[:Statement] : [document[:Statement]].compact
    # downcase keys to eliminate formatting issue
    # put values in an array for standard match checking
    criteria = criteria.each_with_object({}) { |(k, v), h| h[k.downcase.to_sym] = v.is_a?(Array) ? v : [v] }
    return false if criteria.empty? || statements.empty?

    allowed_statement_elements = %i(Action Effect Sid Resource NotAction NotResource)
    # downcase keys to eliminate formatting issue
    unless criteria.keys.all? { |k| allowed_statement_elements.map(&:downcase).include?(k) }
      raise ArgumentError,
            "Valid statement elements are #{allowed_statement_elements}, provided elements are: #{criteria.keys}"
    end

    statements.each do |statement|
      # This is to comply with the document that allowing keys in lowercase format.
      statement = statement.transform_keys(&:downcase)
      @statement_match = false
      criteria_match = []
      criteria.each do |k_c, v_c|
        criteria_match << v_c.all? do |v|
          statement_item_in_array = statement[k_c].is_a?(Array) ? statement[k_c] : [statement[k_c]].compact
          statement_item_in_array.include?(v)
        end
      end
      @statement_match = true if criteria_match.all?(true)
      break if criteria_match.all?(true)
    end
    @statement_match
  end

  def get_attached_entities(_policy_name, policy_type = 'Custom')
    catch_alicloud_errors('EntityNotExist.Policy') do
      resp = @alicloud.ram_client.request(
        action: 'ListEntitiesForPolicy',
        params: {
          RegionId: opts[:region],
          PolicyName: opts[:policy_name],
          PolicyType: policy_type,
        },
        opts: {
          method: 'POST',
        },
      )
      return resp
    end
  end

  def statement_count
    return false unless @policy_document

    document = JSON.parse(URI.decode_www_form_component(@policy_document), { symbolize_names: true })
    statements = document[:Statement].is_a?(Hash) ? [document[:Statement]] : document[:Statement]
    statements.length
  end

  def attached_to_user?(username)
    !@attached_users.nil? && @attached_users.include?(username)
  end

  def attached_to_group?(group_name)
    !@attached_groups.nil? && @attached_groups.include?(group_name)
  end

  def attached_to_role?(role_arn)
    !@attached_roles.nil? && @attached_roles.include?(role_arn)
  end

  def attached?
    @attachment_count.positive?
  end

  def resource_id
    "#{@opts[:policy_name]}_#{@opts[:region]}"
  end

  def to_s
    "Alicloud RAM Policy #{@opts[:policy_name]}"
  end
end
