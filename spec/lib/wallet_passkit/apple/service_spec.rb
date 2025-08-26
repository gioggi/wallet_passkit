# frozen_string_literal: true

require "spec_helper"

RSpec.describe WalletPasskit::Apple::Service do
  before do
    WalletPasskit.configure do |c|
      c.apple_pass_certificate_p12_path = "/tmp/fake.p12"
      c.apple_pass_certificate_password = "password"
      c.apple_wwdr_certificate_path = "/tmp/fake_wwdr.pem"
    end
  end

  it "builds a valid pass payload with colors" do
    payload = described_class.build_pass_payload(
      description: "Loyalty Card",
      pass_type_identifier: "pass.com.example.loyalty",
      serial_number: "ABC123",
      logo_text: "My Store",
      primary_fields: [ { key: 'points', label: 'Points', value: '100' } ],
      background_color: 'rgb(255,0,0)',
      foreground_color: 'rgb(255,255,255)'
    )

    expect(payload[:formatVersion]).to eq(1)
    expect(payload[:passTypeIdentifier]).to eq("pass.com.example.loyalty")
    expect(payload[:serialNumber]).to eq("ABC123")
    expect(payload[:storeCard]).to be_kind_of(Hash)
    expect(payload[:backgroundColor]).to eq('rgb(255,0,0)')
    expect(payload[:foregroundColor]).to eq('rgb(255,255,255)')
  end

  it "generates a pkpass using a stubbed signer" do
    payload = { foo: "bar" }
    assets = { "icon.png" => "PNGDATA" }

    allow(File).to receive(:binread).with("/tmp/fake.p12").and_return("P12DATA")
    allow(File).to receive(:read).with("/tmp/fake_wwdr.pem").and_return("WWDR")

    allow(WalletPasskit::Apple::Signer).to receive(:sign).and_return("DER_SIGNATURE")

    pkpass = described_class.generate_pkpass(pass_payload: payload, assets: assets)
    expect(pkpass).to be_a(String)
    expect(pkpass.bytesize).to be > 0
  end
end