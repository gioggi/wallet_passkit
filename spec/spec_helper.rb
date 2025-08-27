# spec/spec_helper.rb
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"
  minimum_coverage 89
end

require "bundler/setup"
require "wallet_passkit"
require "googleauth"
require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
