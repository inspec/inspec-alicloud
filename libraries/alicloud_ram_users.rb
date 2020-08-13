# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudRamUsers < AliCloudResourceBase
  name 'alicloud_ram_users'
  desc 'Verifies settings for AliCloud ram users'

  example "
    # ensure there's more than 1 users
    describe alicloud_ram_users do
    its('entries.count') { should be > 1 }
    end
    "

  attr_reader :table

  # FilterTable setup
  FilterTable.create
             .register_column(:update_dates, field: :update_date)
             .register_column(:user_names, field: :user_name)
             .register_column(:user_ids, field: :user_id)
             .register_column(:comments_s, field: :comments)
             .register_column(:display_names, field: :display_name)
             .register_column(:create_dates, field: :create_date)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters

    catch_alicloud_errors do
      @users = @alicloud.ram_client.request(
        action: 'ListUsers',
        params: {
          'RegionId': opts[:region],
        },
      )['Users']['User']
    end

    return [] if !@users || @users.empty?
    user_rows = []
    @users.map do |user|
      user_rows += [{
        update_date: user['UpdateDate'],
          user_name: user['UserName'],
          user_id: user['UserId'],
          comments: user['Comments'],
          display_name: user['DisplayName'],
          create_date: user['CreateDate'],
      }]
    end
    @table = user_rows
  end
end
