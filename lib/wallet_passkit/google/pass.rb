# frozen_string_literal: true

require "googleauth"
require "jwt"

module WalletPasskit
  module Google
    class Pass
      def initialize(company:, customer:, service_account_path:)
        @company = company.transform_keys(&:to_sym)
        @customer = customer.transform_keys(&:to_sym)
        @service_account_path = service_account_path
      end

      def save_url
        payload = {
          iss: issuer_id,
          aud: "google",
          typ: "savetowallet",
          payload: {
            loyaltyObjects: [build_loyalty_object]
          }
        }

        jwt = JWT.encode(payload, private_key, "RS256", kid: key_id)
        "https://pay.google.com/gp/v/save/#{jwt}"
      end

      private

      def issuer_id
        @company[:issuer_id]
      end

      def key_id
        JSON.parse(File.read(@service_account_path))["private_key_id"]
      end

      def private_key
        OpenSSL::PKey::RSA.new(
          JSON.parse(File.read(@service_account_path))["private_key"]
        )
      end

      def build_loyalty_object
        {
          id: "#{issuer_id}.#{@customer[:id]}",
          classId: "#{issuer_id}.#{@company[:class_id]}",
          state: "active",
          accountId: @customer[:id],
          accountName: "#{@customer[:first_name]} #{@customer[:last_name]}",
          loyaltyPoints: {
            label: "Punti",
            balance: {
              int: @customer[:points] || 0
            }
          }
        }
      end
    end
  end
end
