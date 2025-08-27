# frozen_string_literal: true

require "spec_helper"

RSpec.describe WalletPasskit::Google::Auth do
  describe ".access_token" do
    let(:service_account_path) { "spec/fixtures/service_account.json" }
    let(:mock_credentials) { double("ServiceAccountCredentials") }
    let(:mock_token) { "fake_access_token_123" }

    before do
      # Create test service account file
      File.write(service_account_path, '{"type": "service_account"}')
    end

    after do
      File.delete(service_account_path) if File.exist?(service_account_path)
    end

    it "creates credentials and fetches access token" do
      allow(::Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(mock_credentials)
      allow(mock_credentials).to receive(:fetch_access_token!).and_return(nil)
      allow(mock_credentials).to receive(:access_token).and_return(mock_token)

      result = described_class.access_token(service_account_path: service_account_path)

      expect(result).to eq(mock_token)
      expect(::Google::Auth::ServiceAccountCredentials).to have_received(:make_creds).with(
        json_key_io: instance_of(File),
        scope: ["https://www.googleapis.com/auth/wallet_object.issuer"]
      )
      expect(mock_credentials).to have_received(:fetch_access_token!)
      expect(mock_credentials).to have_received(:access_token)
    end

    context "when service account file exists" do
      it "opens the file and reads credentials" do
        allow(::Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(mock_credentials)
        allow(mock_credentials).to receive(:fetch_access_token!).and_return(nil)
        allow(mock_credentials).to receive(:access_token).and_return(mock_token)

        described_class.access_token(service_account_path: service_account_path)

        expect(::Google::Auth::ServiceAccountCredentials).to have_received(:make_creds).with(
          json_key_io: instance_of(File),
          scope: ["https://www.googleapis.com/auth/wallet_object.issuer"]
        )
      end
    end

    context "when credentials are fetched successfully" do
      it "returns the access token" do
        allow(::Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(mock_credentials)
        allow(mock_credentials).to receive(:fetch_access_token!).and_return(nil)
        allow(mock_credentials).to receive(:access_token).and_return(mock_token)

        result = described_class.access_token(service_account_path: service_account_path)

        expect(result).to eq(mock_token)
      end
    end
  end
end
