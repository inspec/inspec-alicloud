# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudAccessKey < AliCloudResourceBase
  name 'alicloud_access_key'
  desc 'Verifies properties of an AliCloud access key'
  example '
  # check key is active
  describe alicloud_access_key(<access key id>) do
    its("status") { should eq "Active" }
  end
  '

  attr_reader :access_key_id, :status, :create_date

  def initialize(opts = {})
    opts = { access_key_id: opts } if opts.is_a?(String)
    @opts = opts
    super(opts)
    validate_parameters(required: %i[access_key_id], allow: %i[user_name])
    @opts = opts

    catch_alicloud_errors do
      params = { "RegionId": opts[:region] }
      params[:UserName] = opts[:user_name] if opts.key?(:user_name)
      @keys = @alicloud.ram_client.request(
        action: 'ListAccessKeys',
        params: params,
        opts: {
          method: 'POST'
        }
      )['AccessKeys']['AccessKey']

      @keys.map do |key|
        # rubocop:disable Style/Next
        if key['AccessKeyId'] == opts[:access_key_id]
          @access_key_id = key['AccessKeyId']
          @status = key['Status']
          @create_date = key['CreateDate']
          break
        end
        # rubocop:enable Style/Next
      end
    end
  end

  def exists?
    !@access_key_id.nil?
  end

  def resource_id
    "#{@access_key_id|| @opts[:access_key_id]}_#{@opts[:region]}"
  end

  def to_s
    "Alicloud Access Key #{@opts[:access_key_id]}"
  end
end
