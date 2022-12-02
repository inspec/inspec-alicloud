#!/usr/bin/env rake
# frozen_string_literal: true

require "rake/testtask"
require "chefstyle"
require "rubocop/rake_task"
require_relative "test/integration/configuration/alicloud_inspec_config"

INTEGRATION_DIR = File.join("test", "integration")
CONTROLS_DIR = File.join(INTEGRATION_DIR, "verify")
TERRAFORM_DIR = File.join(INTEGRATION_DIR, "build")
TF_VAR_FILE_NAME = "inspec-alicloud.tfvars.json"
TF_VAR_FILE = File.join(TERRAFORM_DIR, TF_VAR_FILE_NAME)
TF_PLAN_FILE = "inspec-alicloud.plan"
PROFILE_ATTRIBUTES = "alicloud-inspec-attributes.yaml"

# Rubocop
desc "Run Rubocop lint checks"

RuboCop::RakeTask.new(:lint) do |task|
  task.options << "--display-cop-names"
end

# Minitest
Rake::TestTask.new do |t|
  t.libs << "libraries"
  t.libs << File.join("test", "unit")
  t.warning = false
  t.verbose = true
  t.pattern = File.join("test", "unit", "**", "*_test.rb")
end

# run tests
#  Disabling inspec check on profile with path dependency due to https://github.com/inspec/inspec/issues/3571 - 'test:check'
desc "Run robocop linter + unit tests"
task default: [:lint, :test]

namespace :test do
  task :check do
    # Run inspec check to verify that the profile is properly configured
    sh("bundle exec inspec check #{CONTROLS_DIR}")
  end

  task setup_integration_tests: ["tf:tf_dir", "tf:plan_integration_tests", "tf:setup_integration_tests"]

  task plan_integration_tests: ["tf:tf_dir", "tf:init_workspace", "tf:plan_integration_tests"]

  task :run_integration_tests do
    puts "----> Running InSpec tests"
    target = ENV["INSPEC_PROFILE_TARGET"] || CONTROLS_DIR
    reporter_name = ENV["INSPEC_REPORT_NAME"] || "inspec-output"
    # Since the default behaviour is to skip tests, the below absorbs an inspec "101 run okay + skipped only" exit code as successful
    cmd = "bundle exec inspec exec %s -t alicloud:// --input-file %s --reporter cli json:%s.json html:%s.html --chef-license=accept-silent"
    cmd += ENV["INSPEC_TRAP_NON_ZERO_EXIT"] ? " || true" : "; rc=$?; if [ $rc -eq 0 ] || [ $rc -eq 101 ]; then exit 0; else exit 1; fi"
    cmd = format(cmd, target, File.join(TERRAFORM_DIR.to_s, PROFILE_ATTRIBUTES), reporter_name, reporter_name)
    sh(cmd)
  end

  task cleanup_integration_tests: ["tf:tf_dir", "tf:cleanup_integration_tests"]

  desc "Perform Integration Tests"
  task integration: ["tf:setup_integration_tests"] do
    Dir.chdir(File.join(File.dirname(__FILE__)))
    Rake::Task["test:run_integration_tests"].execute
    # Rake::Task['tf:cleanup_integration_tests'].execute
  end
end

namespace :tf do
  task :tf_dir do
    Dir.chdir(TERRAFORM_DIR)
  end

  task init_workspace: [:tf_dir] do
    puts "----> Initializing Terraform"
    cmd = format("terraform init")
    sh(cmd)
  end

  task plan_integration_tests: [:tf_dir, :init_workspace] do
    if File.exist?(TF_VAR_FILE)
      puts "----> Previous run not cleaned up - running cleanup..."
      Rake::Task["tf:cleanup_integration_tests"].execute
    end
    puts "----> Generating Terraform and InSpec variable files"
    AliCloudInspecConfig.store_json(TF_VAR_FILE_NAME)
    AliCloudInspecConfig.store_yaml(PROFILE_ATTRIBUTES)
    puts "----> Generating the Plan"
    # Create the plan that can be applied to AliCloud
    cmd = format("terraform plan -var-file=%s -out %s", TF_VAR_FILE_NAME, TF_PLAN_FILE)
    sh(cmd)
  end

  task setup_integration_tests: [:tf_dir, :plan_integration_tests] do
    puts "----> Applying the plan"
    # Apply the plan on AliCloud
    cmd = format("terraform apply %s", TF_PLAN_FILE)
    sh(cmd)
    puts "----> Adding terraform outputs to InSpec variable file"
    AliCloudInspecConfig.update_yaml(PROFILE_ATTRIBUTES)
  end

  task cleanup_integration_tests: [:tf_dir] do
    puts "----> Cleanup"
    cmd = "terraform destroy -var-file=%s "
    cmd += " || true" if ENV["CLEANUP_TRAP_NON_ZERO_EXIT"]
    cmd = format(cmd, TF_VAR_FILE_NAME)
    sh(cmd)
  end
end

namespace :docs do
  desc "Prints markdown links for resource doc files to update the README"
  task :resource_links do
    puts "\n"
    # Until we have documentation, just generate list from the resources directly
    # Dir.entries('docs/resources').sort
    #  .collect { |file| "- [#{file.split('.')[0]}](docs/resources/#{file})" }

    Dir.entries("libraries").sort
      .reject { |file| File.directory?(file) }
      .collect { |file| "- [#{file.split(".")[0]}](libraries/#{file})" }
      .map { |link| puts link }
    puts "\n"
  end
end
