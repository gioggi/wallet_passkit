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

      # Recupera un oggetto loyalty specifico dal Google Wallet
      def retrieve_object
        uri = URI("https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject/#{@object_id}")
        req = Net::HTTP::Get.new(uri)
        req["Authorization"] = "Bearer #{access_token}"

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        raise WalletPasskit::Error, "Errore API: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
        JSON.parse(res.body)
      end

      # Metodo pubblico per recuperare l'oggetto
      def get_object
        retrieve_object
      end

      # Metodi per ottenere informazioni specifiche dell'oggetto
      def get_points
        object = get_object
        object.dig('loyaltyPoints', 'balance', 'int') || 0
      end

      def get_state
        object = get_object
        object['state']
      end

      def get_account_name
        object = get_object
        object['accountName']
      end

      def get_account_id
        object = get_object
        object['accountId']
      end

      def get_creation_time
        object = get_object
        object['createTime']
      end

      def get_update_time
        object = get_object
        object['updateTime']
      end

      # Metodo di classe per recuperare un oggetto senza creare un'istanza
      def self.retrieve_object(object_id:, service_account_path:)
        new(object_id: object_id, service_account_path: service_account_path).get_object
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
