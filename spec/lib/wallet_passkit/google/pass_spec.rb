# frozen_string_literal: true

require "spec_helper"
require "jwt"
require "base64"

RSpec.describe WalletPasskit::Google::Pass do
  let(:company) do
    {
      issuer_id: "issuer-id",
      class_id: "loyalty-class-id",
      background_color: "#112233",
      font_color: "#FFFFFF"
      # Rimossi logo_uri, hero_image_uri e locations (deprecati)
    }
  end

  let(:customer) do
    {
      id: "customer-123",
      first_name: "Mario",
      last_name: "Rossi",
      points: 50,
      qr_value: "QR-VAL-1"
    }
  end

  let(:service_account_path) { "spec/fixtures/service_account.json" }

  describe "#save_url" do
    it "generates a valid Google Wallet save URL with customizations" do
      fake_key = OpenSSL::PKey::RSA.generate(2048)
      fake_data = {
        "private_key_id" => "fake_key_id",
        "private_key" => fake_key.to_pem,
        "client_email" => "test@example.com"
      }

      allow(File).to receive(:read).and_return(fake_data.to_json)

      pass = described_class.new(
        company: company,
        customer: customer,
        service_account_path: service_account_path
      )

      url = pass.save_url
      expect(url).to include("https://pay.google.com/gp/v/save/")

      token = url.split("/").last
      decoded_payload = JWT.decode(token, nil, false).first

      lo = decoded_payload.fetch("payload").fetch("loyaltyObjects").first

      expect(lo["hexBackgroundColor"]).to eq("#112233")
      expect(lo["hexFontColor"]).to eq("#FFFFFF")
      expect(lo["barcode"]).to include({ "type" => "QR_CODE", "value" => "QR-VAL-1" })
      
      # Verifica JWT structure
      expect(decoded_payload["iss"]).to eq("test@example.com")
      expect(decoded_payload["aud"]).to eq("google")
      expect(decoded_payload["typ"]).to eq("savetowallet")
    end

    it "generates URL without deprecated fields" do
      fake_data = {
        "private_key_id" => "fake_key_id",
        "private_key" => OpenSSL::PKey::RSA.generate(2048).to_pem,
        "client_email" => "test@example.com"
      }

      allow(File).to receive(:read).and_return(fake_data.to_json)

      pass = described_class.new(
        company: company,
        customer: customer,
        service_account_path: service_account_path
      )

      url = pass.save_url
      token = url.split("/").last
      decoded_payload = JWT.decode(token, nil, false).first
      lo = decoded_payload.fetch("payload").fetch("loyaltyObjects").first

      # Verifica che i campi deprecati non siano presenti
      expect(lo).not_to have_key("locations")
      expect(lo).not_to have_key("imageModulesData")
    end
  end

  describe "#create_loyalty_object" do
    it "creates a loyalty object via API" do
      fake_token = "fake_access_token"
      allow(WalletPasskit::Google::Auth).to receive(:access_token).and_return(fake_token)

      stub_request(:post, "https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject")
        .with(
          headers: {
            "Authorization" => "Bearer #{fake_token}",
            "Content-Type" => "application/json"
          }
        )
        .to_return(
          status: 200,
          body: {
            id: "issuer-id.customer-123",
            state: "active",
            createTime: "2024-01-01T00:00:00Z"
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      pass = described_class.new(
        company: company,
        customer: customer,
        service_account_path: service_account_path
      )

      result = pass.create_loyalty_object

      expect(result["id"]).to eq("issuer-id.customer-123")
      expect(result["state"]).to eq("active")
      expect(result["createTime"]).to eq("2024-01-01T00:00:00Z")
    end

    it "handles API errors gracefully" do
      fake_token = "fake_access_token"
      allow(WalletPasskit::Google::Auth).to receive(:access_token).and_return(fake_token)

      stub_request(:post, "https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject")
        .to_return(
          status: 400,
          body: { error: { message: "Invalid request" } }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      pass = described_class.new(
        company: company,
        customer: customer,
        service_account_path: service_account_path
      )

      expect { pass.create_loyalty_object }.to raise_error(WalletPasskit::Error, /Failed to create loyalty object/)
    end
  end

  describe "#create_and_save_url" do
    it "creates object and returns save URL" do
      fake_token = "fake_access_token"
      allow(WalletPasskit::Google::Auth).to receive(:access_token).and_return(fake_token)

      # Stub per create_loyalty_object
      stub_request(:post, "https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject")
        .to_return(
          status: 200,
          body: { id: "issuer-id.customer-123", state: "active" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      # Stub per save_url
      fake_key = OpenSSL::PKey::RSA.generate(2048)
      fake_data = {
        "private_key_id" => "fake_key_id",
        "private_key" => fake_key.to_pem,
        "client_email" => "test@example.com"
      }
      allow(File).to receive(:read).and_return(fake_data.to_json)

      pass = described_class.new(
        company: company,
        customer: customer,
        service_account_path: service_account_path
      )

      url = pass.create_and_save_url

      expect(url).to include("https://pay.google.com/gp/v/save/")
    end
  end
end
