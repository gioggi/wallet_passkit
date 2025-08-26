# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module WalletPasskit
  module Google
    class PassUpdater
      def initialize(object_id:, service_account_path:)
        @object_id = object_id
        @service_account_path = service_account_path
      end

      def update_points(new_point_value:)
        patch({ loyaltyPoints: { balance: { int: new_point_value }}})
      end

      private

      def patch(data)
        uri = URI("https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject/#{@object_id}")
        req = Net::HTTP::Patch.new(uri, "Content-Type" => "application/json")
        req["Authorization"] = "Bearer #{access_token}"
        req.body = data.to_json

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        raise WalletPasskit::Error, "Errore API: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
        JSON.parse(res.body)
      end

      def access_token
        WalletPasskit::Google::Auth.access_token(service_account_path: @service_account_path)
      end
    end
  end
end
