# frozen_string_literal: true

require "spec_helper"

RSpec.describe WalletPasskit::Apple::Signer do
  describe ".sign" do
    let(:data) { "test data to sign" }
    let(:p12_path) { "spec/fixtures/test_cert.p12" }
    let(:p12_password) { "password123" }
    let(:wwdr_path) { "spec/fixtures/test_wwdr.pem" }

    before do
      # Create test certificate files
      File.write(p12_path, "fake p12 data")
      File.write(wwdr_path, "fake wwdr data")
    end

    after do
      File.delete(p12_path) if File.exist?(p12_path)
      File.delete(wwdr_path) if File.exist?(wwdr_path)
    end

    context "when certificate files exist" do
      it "attempts to sign data with certificates" do
        # Mock OpenSSL classes to avoid actual certificate operations
        mock_p12 = double("PKCS12")
        mock_key = double("Key")
        mock_cert = double("Certificate")
        mock_wwdr = double("WWDR")
        mock_store = double("Store")
        mock_pkcs7 = double("PKCS7")

        allow(OpenSSL::PKCS12).to receive(:new).and_return(mock_p12)
        allow(mock_p12).to receive(:key).and_return(mock_key)
        allow(mock_p12).to receive(:certificate).and_return(mock_cert)
        allow(OpenSSL::X509::Certificate).to receive(:new).and_return(mock_wwdr)
        allow(OpenSSL::X509::Store).to receive(:new).and_return(mock_store)
        allow(mock_store).to receive(:add_cert).and_return(true)
        allow(OpenSSL::PKCS7).to receive(:sign).and_return(mock_pkcs7)
        allow(mock_pkcs7).to receive(:to_der).and_return("signed_data")

        result = described_class.sign(
          data: data,
          p12_path: p12_path,
          p12_password: p12_password,
          wwdr_path: wwdr_path
        )

        expect(result).to eq("signed_data")
      end
    end

    context "when wwdr certificate addition fails" do
      it "continues execution gracefully" do
        mock_p12 = double("PKCS12")
        mock_key = double("Key")
        mock_cert = double("Certificate")
        mock_wwdr = double("WWDR")
        mock_store = double("Store")
        mock_pkcs7 = double("PKCS7")

        allow(OpenSSL::PKCS12).to receive(:new).and_return(mock_p12)
        allow(mock_p12).to receive(:key).and_return(mock_key)
        allow(mock_p12).to receive(:certificate).and_return(mock_cert)
        allow(OpenSSL::X509::Certificate).to receive(:new).and_return(mock_wwdr)
        allow(OpenSSL::X509::Store).to receive(:new).and_return(mock_store)
        allow(mock_store).to receive(:add_cert).and_raise(StandardError.new("Certificate error"))
        allow(OpenSSL::PKCS7).to receive(:sign).and_return(mock_pkcs7)
        allow(mock_pkcs7).to receive(:to_der).and_return("signed_data")

        result = described_class.sign(
          data: data,
          p12_path: p12_path,
          p12_password: p12_password,
          wwdr_path: wwdr_path
        )

        expect(result).to eq("signed_data")
      end
    end
  end
end
