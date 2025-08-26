# lib/wallet_passkit/google/pass_updater.rb
require "googleauth"
require "json"
require "net/http"
require "uri"

module WalletPasskit
  module Google
    class PassUpdater
      GOOGLE_API_URL = "https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject/".freeze

      def initialize(object_id:, service_account_path: nil)
        @object_id = object_id
        @service_account_path = service_account_path || ENV["GOOGLE_WALLET_SERVICE_ACCOUNT_JSON_PATH"]
      end

      def update_points(new_point_value:, label: "Punti disponibili")
        patch_body = {
          loyaltyPoints: {
            label: label,
            balance: {
              string: new_point_value.to_s
            }
          }
        }

        patch(patch_body)
      end

      def add_text_module(header:, body:)
        patch_body = {
          textModulesData: [
            {
              header: header,
              body: body
            }
          ]
        }

        patch(patch_body)
      end

      private

      def patch(body)
        uri = URI.parse("#{GOOGLE_API_URL}#{@object_id}")
        request = Net::HTTP::Patch.new(uri)
        request.content_type = "application/json"
        request.body = body.to_json
        request["Authorization"] = "Bearer #{access_token}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        unless response.is_a?(Net::HTTPSuccess)
          raise "Failed to update Google Wallet object: #{response.code} - #{response.body}"
        end

        JSON.parse(response.body)
      end

      def access_token
        credentials = ::Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(@service_account_path),
          scope: ["https://www.googleapis.com/auth/wallet_object.issuer"]
        )
        credentials.fetch_access_token!
        credentials.access_token
      end
    end
  end
end
