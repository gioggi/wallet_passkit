# frozen_string_literal: true

require "googleauth"

module WalletPasskit
  module Google
    module Auth
      def self.access_token(service_account_path:)
        credentials = ::Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(service_account_path),
          scope: ["https://www.googleapis.com/auth/wallet_object.issuer"]
        )
        credentials.fetch_access_token!
        credentials.access_token
      end
    end
  end
end
