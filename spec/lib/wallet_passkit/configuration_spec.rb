# frozen_string_literal: true

require "spec_helper"

RSpec.describe WalletPasskit::Configuration do
  let(:config) { described_class.new }

  describe "initialization" do
    it "initializes with nil values" do
      expect(config.apple_pass_certificate_p12_path).to be_nil
      expect(config.apple_pass_certificate_password).to be_nil
      expect(config.apple_wwdr_certificate_path).to be_nil
      expect(config.apple_team_identifier).to be_nil
      expect(config.apple_organization_name).to be_nil
      expect(config.google_service_account_credentials).to be_nil
      expect(config.google_issuer_id).to be_nil
      expect(config.google_class_prefix).to be_nil
    end
  end

  describe "attribute accessors" do
    it "allows setting and getting apple_pass_certificate_p12_path" do
      config.apple_pass_certificate_p12_path = "/path/to/cert.p12"
      expect(config.apple_pass_certificate_p12_path).to eq("/path/to/cert.p12")
    end

    it "allows setting and getting apple_pass_certificate_password" do
      config.apple_pass_certificate_password = "password123"
      expect(config.apple_pass_certificate_password).to eq("password123")
    end

    it "allows setting and getting apple_wwdr_certificate_path" do
      config.apple_wwdr_certificate_path = "/path/to/wwdr.pem"
      expect(config.apple_wwdr_certificate_path).to eq("/path/to/wwdr.pem")
    end

    it "allows setting and getting apple_team_identifier" do
      config.apple_team_identifier = "TEAM123"
      expect(config.apple_team_identifier).to eq("TEAM123")
    end

    it "allows setting and getting apple_organization_name" do
      config.apple_organization_name = "My Company"
      expect(config.apple_organization_name).to eq("My Company")
    end

    it "allows setting and getting google_service_account_credentials" do
      config.google_service_account_credentials = "/path/to/credentials.json"
      expect(config.google_service_account_credentials).to eq("/path/to/credentials.json")
    end

    it "allows setting and getting google_issuer_id" do
      config.google_issuer_id = "issuer-123"
      expect(config.google_issuer_id).to eq("issuer-123")
    end

    it "allows setting and getting google_class_prefix" do
      config.google_class_prefix = "prefix"
      expect(config.google_class_prefix).to eq("prefix")
    end
  end
end
