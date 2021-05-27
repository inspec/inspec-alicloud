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
    its('delete_with_instance') { should eq false }
    its('enable_auto_snapshot') { should eq true }
    its('delete_auto_snapshot') { should eq false }
  end
  "
  attr_reader :id, :name, :description, :size, :category, :encrypted, :kms_key_id,
              :enable_auto_snapshot, :delete_auto_snapshot, :delete_with_instance

  def initialize(opts = {})
    opts = { disk_id: opts } if opts.is_a?(String)
    opts[:disk_id] = opts.delete(:id) if opts.key?(:id) # id is an alias for disk_id
    opts[:disk_name] = opts.delete(:name) if opts.key?(:name) # name is an alias for disk_name
    @opts = opts
    super(opts)
    validate_parameters(require_any_of: %i{disk_id disk_name}, required: %i{region})

    if opts[:disk_id] && !opts[:disk_id].empty?
      raise ArgumentError, "#{@__resource_name__}: disk ID must be in the format 'd- followed by alphanumeric characters." if opts[:disk_id] !~ /^d\-[0-9a-z]+$/
      raise ArgumentError, "#{@__resource_name__}: expected only one of `disk_id` or `disk_name`" if opts[:disk_name]
    elsif !opts[:disk_name] || opts[:disk_name].empty?
      raise ArgumentError, "#{@__resource_name__}: `disk_id` or `disk_name` must be provided"
    end

    @resp = fetch_disk_info(opts)
    if @resp.nil?
      @encrypted = false
      return
    end

    @disk                 = @resp
    @id                   = @disk["DiskId"]
    @name                 = @disk["DiskName"]
    @description          = @disk["Description"]
    @size                 = @disk["Size"]
    @category             = @disk["Category"]
    @encrypted            = @disk["Encrypted"]
    @kms_key_id           = @disk["KMSKeyId"]
    @enable_auto_snapshot = @disk["EnableAutoSnapshot"]
    @delete_auto_snapshot = @disk["DeleteAutoSnapshot"]
    @delete_with_instance = @disk["DeleteWithInstance"]
  end

  def fetch_disk_info(opts)
    filters = opts.key?(:disk_id) ? { DiskIds: [opts[:disk_id]] } : { DiskName: opts[:disk_name] }
    filters[:RegionId] = opts[:region]

    catch_alicloud_errors do
      resp = @alicloud.ecs_client.request(
        action: "DescribeDisks",
        params: filters,
       opts: {
         method: "POST",
       }
      )["Disks"]["Disk"]

      if opts.key?(:disk_id)
        disk = resp.select { |d| d["DiskId"] == opts[:disk_id] }.first
      else
        disk = resp.select { |d| d["DiskName"] == opts[:disk_name] }.first
      end
      return disk
    end
  end

  def encrypted?
    @encrypted
  end

  def exists?
    !@disk.nil?
  end

  def to_s
    if @opts[:disk_name]
      d = "ECS Disk: Name: #{@opts[:disk_name]}"
      d += " ID: #{@id}" if @id
    else
      d = "ECS Disk: ID: #{@opts[:disk_id]}"
      d += " Name: #{@name}" if @name
    end
    "#{d} in #{opts[:region]}"
  end
end
