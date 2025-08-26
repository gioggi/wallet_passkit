# frozen_string_literal: true

require "openssl"

module WalletPasskit
  module Apple
    class Signer
      def self.sign(data:, p12_path:, p12_password:, wwdr_path:)
        p12 = OpenSSL::PKCS12.new(File.binread(p12_path), p12_password)
        key = p12.key
        cert = p12.certificate
        wwdr = OpenSSL::X509::Certificate.new(File.read(wwdr_path))

        store = OpenSSL::X509::Store.new
        store.add_cert(wwdr) rescue nil

        flags = OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED
        pkcs7 = OpenSSL::PKCS7.sign(cert, key, data, [wwdr], flags)
        pkcs7.to_der
      end
    end
  end
end