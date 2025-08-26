# spec/spec_helper.rb
require "bundler/setup"
require "wallet_passkit"
require "googleauth"


RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before do
    allow(::Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(
      double("FakeCredentials",
             client_email: "test@example.com",
             signing_key: OpenSSL::PKey::RSA.new(2048) # genera chiave finta runtime
      )
    )
  end
end
