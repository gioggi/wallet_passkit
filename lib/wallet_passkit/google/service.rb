# frozen_string_literal: true

require 'jwt'
require 'json'

module WalletPasskit
  module Google
    # Minimal Google Wallet service to build a Save to Google Wallet JWT link.
    # For full object insertion via REST, additional client code is needed; this is a minimal viable scaffold.
    class Service
      GOOGLE_AUDIENCE = 'google'.freeze
      GOOGLE_ISSUER   = 'https://pay.google.com/gp/v/save/'.freeze

      # Build a signed JWT for Save to Google Wallet button
      # credentials: path to service account JSON or a parsed hash (default from global config)
      # payload: a hash containing "iss", "aud", "typ", and "payload" (classes/objects) per Google Wallet spec
      # Returns the Save URL to be used in buttons/links
      def self.build_save_url(payload:, credentials: nil)
        sa = load_credentials(credentials)
        now = Time.now.to_i
        claims = {
          iss: sa[:client_email],
          aud: GOOGLE_AUDIENCE,
          iat: now,
          exp: now + 3600,
          typ: 'savetowallet',
          payload: payload
        }
        key = OpenSSL::PKey::RSA.new(sa[:private_key])
        token = JWT.encode(claims, key, 'RS256')
        GOOGLE_ISSUER + token
      end

      def self.load_credentials(credentials)
        creds = credentials || WalletPasskit.config.google_service_account_credentials
        case creds
        when String
          json = File.read(creds)
          data = JSON.parse(json)
          { client_email: data['client_email'], private_key: data['private_key'] }
        when Hash
          { client_email: creds[:client_email] || creds['client_email'], private_key: creds[:private_key] || creds['private_key'] }
        else
          raise ArgumentError, 'Google service account credentials are required (path to JSON file or hash)'
        end
      end
    end
  end
end
