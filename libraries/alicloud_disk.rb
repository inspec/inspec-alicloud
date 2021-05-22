# frozen_string_literal: true

require "alicloud_backend"

class AliCloudDisk < AliCloudResourceBase
  name "alicloud_disk"
  desc "Verifies properties for an individual AliCloud disk"
  example "
  describe alicloud_disks('disk-12345678') do
    it { should exist }
    its('encrypted') { should eq true }
    its('size')      { should cmp 100 }
  end
  "
  attr_reader :description, :encrypted, :id, :category, :size, :kms_key_id, :name

  def initialize(opts = {})
    opts = { disk_id: opts } if opts.is_a?(String)
    opts[:disk_id] = opts.delete(:id) if opts.key?(:id) # id is an alias for group_id
    @opts = opts
    super(opts)
    validate_parameters(required: %i{disk_id region})

    catch_alicloud_errors do
      @resp = @alicloud.ecs_client.request(
        action: "DescribeDisks",
        params: {
          'RegionId': opts[:region],
          'DiskIds': [opts[:disk_id]],
        },
       opts: {
         method: "POST",
       }
      )["Disks"]["Disk"].select { |d| d["DiskId"] == opts[:disk_id] }.first
    end

    if @resp.nil?
      @encrypted = false
      return
    end

    @disk        = @resp
    @id          = @disk["DiskId"]
    @name        = @disk["DiskName"]
    @encrypted   = @disk["Encrypted"]
    @description = @disk["Description"]
    @category    = @disk["Category"]
    @kms_key_id  = @disk["KMSKeyId"]
    @size        = @disk["Size"]
  end

  def exists?
    !@disk.nil?
  end

  def to_s
    d = @name ? " Name: #{@name}" : ""
    @opts.key?(:region) ? "ECS Disk: ID: #{@opts[:disk_id]}#{d} in #{opts[:region]}" : "ECS Disk #{@opts[:disk_id]}#{d}"
  end
end
