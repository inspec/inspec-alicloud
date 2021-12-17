# frozen_string_literal: true

source "https://rubygems.org"

gem "bundle"

# Use Latest Inspec
gem "inspec-bin"
gem "aliyunsdkcore"
gem "aliyun-sdk", "~> 0.8.0"
gem "train-alicloud", "~> 0.0.4"

if Gem.ruby_version < Gem::Version.new("2.7.0")
  gem "activesupport", "6.1.4.4"
end

if Gem.ruby_version.to_s.start_with?("2.5")
  # 16.7.23 required ruby 2.6+
  gem "chef-utils", "< 16.7.23" # TODO: remove when we drop ruby 2.5
end

group :development do
  gem "pry"
  gem "bundler"
  gem "byebug"
  gem "minitest"
  gem "mocha"
  gem "m"
  gem "rake"
  gem "chefstyle"
end
