require "spec_helper"

RSpec.describe WalletPasskit::Google::PassUpdater do
  let(:object_id) { "issuer-id.customer-123" }
  let(:service_account_path) { "spec/fixtures/service_account.json" }

  describe "#update_points" do
    it "builds the correct PATCH request for points update" do
      allow(WalletPasskit::Google::Auth).to receive(:access_token).and_return("fake_token")

      stub_request(:patch, "https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject/#{object_id}")
        .with { |req|
          req.headers["Authorization"] == "Bearer fake_token" &&
            JSON.parse(req.body).dig("loyaltyPoints", "balance", "int") == 150
        }
        .to_return(status: 200, body: { success: true }.to_json, headers: { "Content-Type" => "application/json" })

      updater = described_class.new(object_id: object_id, service_account_path: service_account_path)

      expect {
        updater.update_points(new_point_value: 150)
      }.not_to raise_error
    end
  end

  describe "#retrieve_object" do
    it "retrieves object data via API" do
      allow(WalletPasskit::Google::Auth).to receive(:access_token).and_return("fake_token")

      stub_request(:get, "https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject/#{object_id}")
        .with(headers: { "Authorization" => "Bearer fake_token" })
        .to_return(
          status: 200,
          body: {
            id: object_id,
            state: "active",
            accountName: "Test Customer",
            accountId: "customer-123",
            loyaltyPoints: { balance: { int: 150 } },
            createTime: "2024-01-01T00:00:00Z",
            updateTime: "2024-01-02T00:00:00Z"
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      updater = described_class.new(object_id: object_id, service_account_path: service_account_path)
      result = updater.retrieve_object

      expect(result["id"]).to eq(object_id)
      expect(result["state"]).to eq("active")
      expect(result["accountName"]).to eq("Test Customer")
      expect(result["loyaltyPoints"]["balance"]["int"]).to eq(150)
    end

    it "handles API errors gracefully" do
      allow(WalletPasskit::Google::Auth).to receive(:access_token).and_return("fake_token")

      stub_request(:get, "https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject/#{object_id}")
        .to_return(
          status: 404,
          body: { error: { message: "Object not found" } }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      updater = described_class.new(object_id: object_id, service_account_path: service_account_path)

      expect { updater.retrieve_object }.to raise_error(WalletPasskit::Error, /Errore API/)
    end
  end

  describe "getter methods" do
    let(:updater) { described_class.new(object_id: object_id, service_account_path: service_account_path) }
    let(:mock_object_data) do
      {
        "id" => object_id,
        "state" => "active",
        "accountName" => "Test Customer",
        "accountId" => "customer-123",
        "loyaltyPoints" => { "balance" => { "int" => 150 } },
        "createTime" => "2024-01-01T00:00:00Z",
        "updateTime" => "2024-01-02T00:00:00Z"
      }
    end

    before do
      # Stub both methods to return our mock data
      allow(updater).to receive(:get_object).and_return(mock_object_data)
      allow(updater).to receive(:retrieve_object).and_return(mock_object_data)
    end

    it "#get_points returns loyalty points" do
      expect(updater.get_points).to eq(150)
    end

    it "#get_state returns object state" do
      expect(updater.get_state).to eq("active")
    end

    it "#get_account_name returns account name" do
      expect(updater.get_account_name).to eq("Test Customer")
    end

    it "#get_account_id returns account id" do
      expect(updater.get_account_id).to eq("customer-123")
    end

    it "#get_creation_time returns creation time" do
      expect(updater.get_creation_time).to eq("2024-01-01T00:00:00Z")
    end

    it "#get_update_time returns update time" do
      expect(updater.get_update_time).to eq("2024-01-02T00:00:00Z")
    end

    it "#get_object returns full object data" do
      expect(updater.get_object).to eq(mock_object_data)
    end
  end

  describe ".retrieve_object (class method)" do
    it "retrieves object data using class method" do
      allow(WalletPasskit::Google::Auth).to receive(:access_token).and_return("fake_token")

      stub_request(:get, "https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject/#{object_id}")
        .with(headers: { "Authorization" => "Bearer fake_token" })
        .to_return(
          status: 200,
          body: {
            id: object_id,
            state: "active",
            accountName: "Test Customer"
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = described_class.retrieve_object(
        object_id: object_id,
        service_account_path: service_account_path
      )

      expect(result["id"]).to eq(object_id)
      expect(result["state"]).to eq("active")
      expect(result["accountName"]).to eq("Test Customer")
    end
  end
end
