require "spec_helper"

RSpec.describe WalletPasskit::Google::PassUpdater do
  let(:object_id) { "issuer-id.customer-123" }
  let(:service_account_path) { "spec/fixtures/service_account.json" }

  it "builds the correct PATCH request for points update" do
    allow(WalletPasskit::Google::Auth).to receive(:access_token).and_return("fake_token")

    stub_request(:patch, "https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject/#{object_id}")
      .with(
        headers: { "Authorization" => "Bearer fake_token" },
        body: hash_including({
                               loyaltyPoints: hash_including({
                                                               balance: { int: 150 }
                                                             })
                             })
      )
      .to_return(status: 200, body: { success: true }.to_json, headers: {})

    updater = described_class.new(object_id: object_id, service_account_path: service_account_path)

    expect {
      updater.update_points(new_point_value: 150)
    }.not_to raise_error
  end
end
