gem "mocha"

require "minitest/autorun"
require "minitest/unit"
require "minitest/pride"
require "inspec/resource"
require "inspec/log"
require "mocha/minitest"

Inspec::Log.logger = Logger.new(nil)
