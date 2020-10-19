# frozen_string_literal: true

require "alicloud_backend"

class AliCloudAccessKeys < AliCloudResourceBase
  name "alicloud_access_keys"
  desc "Verifies properties of AliCloud access keys"
  example '
    # ensure no keys exist
    describe alicloud_access_keys do
        its("entries.count")  { should eq 0 }
    end
    '

  attr_reader :table

  # FilterTable setup
  FilterTable.create
    .register_column(:access_key_ids, field: :access_key_id)
    .register_column(:statuses, field: :status)
    .register_column(:create_dates, field: :create_date)
    .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    opts = { user_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(allow: %i{user_name})
    catch_alicloud_errors do
      params = { "RegionId": opts[:region] }
      params[:UserName] = opts[:user_name] if opts.key?(:user_name)
      @keys = @alicloud.ram_client.request(
        action: "ListAccessKeys",
          params: params,
          opts: {
            method: "POST",
          }
      )["AccessKeys"]["AccessKey"]
    end

    return [] if !@keys || @keys.empty?

    keys_rows = []
    @keys.map do |key|
      keys_rows += [{
        access_key_id: key["AccessKeyId"],
          status: key["Status"],
          create_date: key["CreateDate"],
      }]
    end

    @table = keys_rows
  end

  def exist?
    !@keys.nil? && !@keys.empty?
  end

  def to_s
    "Alicloud Access Keys (All)"
  end
end
