# frozen_string_literal: true

require "spec_helper"

RSpec.describe WalletPasskit::Google::Pass do
  let(:company) do
    {
      issuer_id: "issuer-id",
      class_id: "loyalty-class-id"
    }
  end

  let(:customer) do
    {
      id: "customer-123",
      first_name: "Mario",
      last_name: "Rossi",
      points: 50
    }
  end

  let(:service_account_path) { "spec/fixtures/service_account.json" }

  it "generates a valid Google Wallet save URL" do
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
  end
end
