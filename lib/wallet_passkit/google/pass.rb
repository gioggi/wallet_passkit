# frozen_string_literal: true

require "googleauth"
require "jwt"
require "net/http"
require "uri"
require "json"

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

      # Creates a loyalty object in Google Wallet using the API
      def create_loyalty_object
        loyalty_object_data = build_loyalty_object
        
        uri = URI("https://walletobjects.googleapis.com/walletobjects/v1/loyaltyObject")
        req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
        req["Authorization"] = "Bearer #{access_token}"
        req.body = loyalty_object_data.to_json

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        if res.is_a?(Net::HTTPSuccess)
          created_object = JSON.parse(res.body)
          puts "✅ Loyalty object created successfully!"
          puts "   ID: #{created_object['id']}"
          puts "   State: #{created_object['state']}"
          created_object
        else
          error_message = "Failed to create loyalty object: #{res.code} #{res.message}"
          if res.body
            error_data = JSON.parse(res.body) rescue nil
            if error_data && error_data['error']
              error_message += " - #{error_data['error']['message']}"
            end
          end
          raise WalletPasskit::Error, error_message
        end
      end

      # Creates loyalty object and returns the save URL
      def create_and_save_url
        create_loyalty_object
        save_url
      end

      private

      def access_token
        WalletPasskit::Google::Auth.access_token(service_account_path: @service_account_path)
      end

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
        object = {
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

        if @company[:background_color]
          object[:hexBackgroundColor] = @company[:background_color]
        end

        if @company[:font_color]
          object[:hexFontColor] = @company[:font_color]
        end

        image_modules = []
        if @company[:logo_uri]
          image_modules << {
            mainImage: {
              sourceUri: { uri: @company[:logo_uri] }
            }
          }
        end
        if @company[:hero_image_uri]
          image_modules << {
            mainImage: {
              sourceUri: { uri: @company[:hero_image_uri] }
            }
          }
        end
        object[:imageModulesData] = image_modules unless image_modules.empty?

        if @company[:locations].is_a?(Array)
          object[:locations] = @company[:locations].map do |loc|
            {
              latitude: loc[:latitude] || loc["latitude"],
              longitude: loc[:longitude] || loc["longitude"]
            }
          end
        end

        if @customer[:qr_value]
          object[:barcode] = {
            type: "QR_CODE",
            value: @customer[:qr_value]
          }
        elsif @customer[:barcode_value]
          object[:barcode] = {
            type: (@customer[:barcode_type] || "QR_CODE"),
            value: @customer[:barcode_value]
          }
        end

        object
      end
    end
  end
end
