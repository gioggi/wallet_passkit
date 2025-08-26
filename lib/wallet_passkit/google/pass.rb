require "googleauth"
require "jwt"
require "json"

module WalletPasskit
  module Google
    class Pass
      GOOGLE_WALLET_URL = "https://pay.google.com/gp/v/save/".freeze

      def initialize(customer_id:, class_id:, issuer_id:, points:, name:, qr_value:, company:, service_account_path: nil)
        @customer_id = customer_id
        @class_id = class_id
        @issuer_id = issuer_id
        @points = points
        @name = name
        @qr_value = qr_value
        @company = company
        @service_account_path = service_account_path || ENV["GOOGLE_WALLET_SERVICE_ACCOUNT_JSON_PATH"]
      end

      def save_url
        jwt = build_jwt
        "#{GOOGLE_WALLET_URL}#{jwt}"
      end

      private

      def build_jwt
        credentials = ::Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(@service_account_path),
          scope: ["https://www.googleapis.com/auth/wallet_object.issuer"]
        )
        credentials.fetch_access_token!

        object_id = "#{@issuer_id}.company#{@company[:id]}_customer#{@customer_id}"

        payload = {
          iss: credentials.client_email,
          aud: "google",
          origins: [@company[:origin] || "https://keristo.cloud"], # da configurare
          typ: "savetowallet",
          payload: {
            loyaltyObjects: [
              {
                id: object_id,
                classId: "#{@issuer_id}.#{@class_id}",
                state: "active",
                accountId: @customer_id.to_s,
                accountName: @name,

                barcode: {
                  type: "qrCode",
                  value: @qr_value,
                  alternateText: "ID Cliente"
                },

                loyaltyPoints: {
                  label: "Punti disponibili",
                  balance: {
                    string: @points.to_s
                  }
                },

                textModulesData: [
                  {
                    header: "Benvenuto!",
                    body: "Hai #{@points} punti da #{@company[:name]}."
                  }
                ],

                locations: [
                  {
                    latitude: @company[:latitude],
                    longitude: @company[:longitude]
                  }
                ],

                logo: {
                  source_uri: {
                    uri: @company[:logo_url]
                  },
                  content_description: @company[:name]
                },

                heroImage: {
                  source_uri: {
                    uri: @company[:hero_image_url]
                  },
                  content_description: "Promozione"
                },

                hexBackgroundColor: @company[:background_color] || "#ffffff"
              }
            ]
          }
        }

        JWT.encode(payload, credentials.signing_key, "RS256")
      end
    end
  end
end

