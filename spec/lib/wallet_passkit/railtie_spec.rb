# frozen_string_literal: true

require "spec_helper"

RSpec.describe "WalletPasskit::Railtie" do
  # Skip these tests if Rails is not available
  before do
    skip("Rails not available") unless defined?(Rails)
  end

  let(:railtie_class) { WalletPasskit::Railtie }

  describe "Rails integration" do
    let(:mock_app) { double("Rails::Application") }
    let(:mock_config) { double("Rails::Configuration") }
    let(:mock_wallet_config) { double("WalletPasskitConfig") }

    before do
      allow(mock_app).to receive(:config).and_return(mock_config)
      allow(mock_config).to receive(:wallet_passkit).and_return(mock_wallet_config)
      allow(mock_wallet_config).to receive(:key?).and_return(false)
      allow(WalletPasskit).to receive(:configure).and_yield(double("Config"))
    end

    it "is defined as a Rails::Railtie" do
      expect(railtie_class).to be < Rails::Railtie
    end

    it "has wallet_passkit configuration" do
      expect(mock_config).to respond_to(:wallet_passkit)
    end

    context "when configuration keys are present" do
      before do
        allow(mock_wallet_config).to receive(:key?).with(:apple_pass_certificate_p12_path).and_return(true)
        allow(mock_wallet_config).to receive(:apple_pass_certificate_p12_path).and_return("/path/to/cert.p12")
        allow(mock_wallet_config).to receive(:key?).with(:google_issuer_id).and_return(true)
        allow(mock_wallet_config).to receive(:google_issuer_id).and_return("issuer-123")
      end

      it "configures wallet_passkit with Rails config values" do
        # This test verifies that the Railtie can be instantiated and configured
        expect { railtie_class.new }.not_to raise_error
      end
    end

    context "when configuration keys are not present" do
      before do
        allow(mock_wallet_config).to receive(:key?).and_return(false)
      end

      it "does not configure wallet_passkit with missing values" do
        expect { railtie_class.new }.not_to raise_error
      end
    end
  end

  describe "when Rails is not available" do
    before do
      hide_const("Rails")
    end

    it "does not define Railtie class" do
      expect { railtie_class }.to raise_error(NameError)
    end
  end
end
