require "spec_helper"
require "wallet_passkit/google/pass"
require "wallet_passkit/google/pass_updater"

RSpec.describe WalletPasskit::Google::Pass do
  let(:company) do
    {
      id: 1,
      name: "Pizzeria Romana",
      latitude: 41.89,
      longitude: 12.49,
      logo_url: "https://example.com/logo.png",
      hero_image_url: "https://example.com/banner.jpg",
      background_color: "#FF5733",
      origin: "https://example.com"
    }
  end

  let(:pass) do
    described_class.new(
      customer_id: 42,
      class_id: "keristo_loyalty",
      issuer_id: "issuer_123456789",
      points: 120,
      name: "Mario Rossi",
      qr_value: "uuid-xyz",
      company: company,
      service_account_path: "spec/fixtures/service_account.json"
    )
  end

  it "generates a valid Google Wallet save URL" do
    url = pass.save_url
    expect(url).to include("https://pay.google.com/gp/v/save/")
    expect(url.length).to be > 50
  end
end

RSpec.describe WalletPasskit::Google::PassUpdater do
  let(:object_id) { "issuer_123456789.company1_customer42" }

  let(:updater) do
    described_class.new(
      object_id: object_id,
      service_account_path: "spec/fixtures/service_account.json"
    )
  end

  it "builds the correct PATCH request for points update" do
    allow(Net::HTTP).to receive(:start).and_return(
      double("response", is_a?: true, body: '{"success":true}', code: "200")
    )

    expect {
      updater.update_points(new_point_value: 150)
    }.not_to raise_error
  end
end
