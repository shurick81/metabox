begin

  require 'simplecov'    

  coverage_value = ENV['simplecov_custom_coverage'] || 2

  SimpleCov.start do
    @filters = []
    add_filter '/spec'
    add_filter '/tasks'
    add_filter '/Rakefile'

    simplecov_custom_filters = ENV['simplecov_custom_filters'] unless ENV['simplecov_custom_filters'].to_s.empty?    

    puts simplecov_custom_filters
    # excluding additional files from SimpleCov coverage report
    if(!simplecov_custom_filters.nil?)
      simplecov_custom_filters.split(',').each do | filter |
        puts "Custom filter: #{filter}"
        add_filter filter
      end
    end
  end

  puts "-- Running with SimpleCov, expect #{coverage_value}% coverage"
  
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([ SimpleCov::Formatter::HTMLFormatter ])
  SimpleCov.minimum_coverage coverage_value
rescue LoadError
  puts '-- SimpleCov gem not available. skipping coverage analysis'
end                                                               

ENV['METABOX_LOG_LEVEL'] = 'VERBOSE'

SPEC_DIR = File.expand_path(File.dirname(__FILE__))
SPEC_DATA_DIR = File.expand_path(File.dirname(__FILE__) + "/data")
SPEC_DOCUMENTS_DATA_DIR = File.expand_path(File.dirname(__FILE__) + "/data/documents")
SPEC_PACKER_DATA_DIR = File.expand_path(File.dirname(__FILE__) + "/data/packer")

require 'json'
require "bundler/setup"
require File.expand_path "#{Dir.pwd}/metabox/lib/metabox.rb"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
