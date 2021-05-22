# frozen_string_literal: true

require "alicloud_backend"

class AliCloudRamPolicies < AliCloudResourceBase
  name "alicloud_ram_policies"
  desc "Verifies settings for a collection of AliCloud RAM Policies"
  example '
    describe alicloud_ram_policies do
      it { should exist }
    end
  '

  attr_reader :table

  FilterTable.create
    .register_column(:policy_names,      field: :policy_name)
    .register_column(:default_versions,  field: :default_version)
    .register_column(:attachment_counts, field: :attachment_count)
    .register_column(:attached_groups,   field: :attached_groups)
    .register_column(:attached_roles,    field: :attached_roles)
    .register_column(:attached_users,    field: :attached_users)
    .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    opts = { type: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(allow: %i{only_attached type}, required: %i{region})

    @type = opts[:type]
    opts[:type] = "System" unless opts[:type]
    @table = fetch_data(opts)
    return unless @type.nil?

    opts[:type] = "Custom"
    @table += fetch_data(opts)
  end

  def fetch_data(opts)
    ram_policy_rows = []

    loop do
      response = list_policies(opts)
      return [] if !response || response.empty?

      response["Policies"]["Policy"].map do |policy|
        unless opts[:only_attached] && policy["AttachmentCount"] == 0
          row = { policy_name:      policy["PolicyName"],
                  default_version:  policy["DefaultVersion"],
                  attachment_count: policy["AttachmentCount"] }

          if policy["AttachmentCount"] > 0
            attached_entities = get_attached_entities(opts.merge({ policy_name: policy["PolicyName"] }))
            row[:attached_groups] = attached_entities["Groups"]["Group"].map { |x| x["GroupName"] }
            row[:attached_roles] = attached_entities["Roles"]["Role"].map { |x| x["RoleName"] }
            row[:attached_users] = attached_entities["Users"]["User"].map { |x| x["UserName"] }
          else
            row[:attached_groups] = []
            row[:attached_roles] = []
            row[:attached_users] = []
          end
          ram_policy_rows += [ row ]
        end
      end

      break unless response["IsTruncated"]

      opts[:marker] = response["Marker"]
    end
    opts.delete(:marker)
    ram_policy_rows
  end

  def list_policies(opts)
    filters = { RegionId: opts[:region] }
    filters["PolicyType"] = opts[:type]
    filters["Marker"] = opts[:marker] if opts[:marker]
    catch_alicloud_errors do
      resp = @alicloud.ram_client.request(
        action: "ListPolicies",
        params: filters,
        opts: {
          method: "POST",
        }
      )
      return resp
    end
  end

  def get_attached_entities(opts)
    filters = { RegionId: opts[:region], PolicyName: opts[:policy_name] }
    filters["PolicyType"] = opts[:type] || "System"
    catch_alicloud_errors do
      resp = @alicloud.ram_client.request(
        action: "ListEntitiesForPolicy",
        params: filters,
        opts: {
          method: "POST",
        }
      )
      return resp
    end
  end

  def exists?
    !@table.nil? && !@table.empty?
  end

  def to_s
    "AliCloud RAM Policies (#{@type.nil? ? "All" : @type})"
  end
end
