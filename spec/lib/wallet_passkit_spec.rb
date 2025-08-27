# frozen_string_literal: true

require "spec_helper"

RSpec.describe WalletPasskit do
  before do
    # Reset configuration before each test
    @original_config = described_class.instance_variable_get(:@config)
    described_class.instance_variable_set(:@config, nil)
  end

  after do
    # Restore original configuration after each test
    described_class.instance_variable_set(:@config, @original_config)
  end

  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class.config)
    end

    it "allows configuration changes" do
      described_class.configure do |config|
        config.apple_team_identifier = "TEAM123"
        config.google_issuer_id = "issuer-123"
      end

      expect(described_class.config.apple_team_identifier).to eq("TEAM123")
      expect(described_class.config.google_issuer_id).to eq("issuer-123")
    end
  end

  describe ".config" do
    it "returns a Configuration instance" do
      expect(described_class.config).to be_a(WalletPasskit::Configuration)
    end

    it "returns the same instance on subsequent calls" do
      config1 = described_class.config
      config2 = described_class.config
      expect(config1).to be(config2)
    end

    it "initializes with default values" do
      config = described_class.config
      expect(config.apple_pass_certificate_p12_path).to be_nil
      expect(config.google_service_account_credentials).to be_nil
    end
  end

  describe "Error class" do
    it "is defined in the module" do
      expect(described_class::Error).to be_truthy
    end

    it "inherits from StandardError" do
      expect(described_class::Error).to be < StandardError
    end
  end
end
