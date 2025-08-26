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
      font_color: "#FFFFFF",
      logo_uri: "https://example.com/logo.png",
      hero_image_uri: "https://example.com/hero.png",
      locations: [ { latitude: 45.0, longitude: 9.0 } ]
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

  it "generates a valid Google Wallet save URL with customizations" do
    fake_key = OpenSSL::PKey::RSA.generate(2048)
    fake_data = {
      "private_key_id" => "fake_key_id",
      "private_key" => fake_key.to_pem
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
    expect(lo["imageModulesData"]).to be_an(Array)
    expect(lo["locations"]).to be_an(Array)
    expect(lo["barcode"]).to include({ "type" => "QR_CODE", "value" => "QR-VAL-1" })
  end
end
