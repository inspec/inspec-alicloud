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
    super(opts)
    validate_parameters(required: %i(access_key_id))

    catch_alicloud_errors do
      @keys = @alicloud.ram_client.request(
        action: 'ListAccessKeys',
            params: {
              "RegionId": opts[:region],
            },
            opts: {
              method: 'POST',
            },
      )['AccessKeys']['AccessKey']

      @keys.map do |key|
        # rubocop:disable Style/Next
        if key['AccessKeyId'] == opts[:access_key_id]
          @access_key_id = key['AccessKeyId']
          @status         = key['Status']
          @create_date    = key['CreateDate']
          break
        end
        # rubocop:enable Style/Next
      end
    end
  end

  def exists?
    !@access_key_id.nil?
  end

  def to_s
    "Alicloud Access Key #{access_key_id}"
  end
end
