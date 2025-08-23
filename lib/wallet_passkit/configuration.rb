# frozen_string_literal: true

module WalletPasskit
  # Global configuration container
  class Configuration
    # Apple Wallet certs configuration
    attr_accessor :apple_pass_certificate_p12_path, :apple_pass_certificate_password,
                  :apple_wwdr_certificate_path, :apple_team_identifier, :apple_organization_name

    # Google Wallet configuration (service account credentials JSON path or hash)
    attr_accessor :google_service_account_credentials, :google_issuer_id, :google_class_prefix

    def initialize
      @apple_pass_certificate_p12_path = nil
      @apple_pass_certificate_password = nil
      @apple_wwdr_certificate_path     = nil
      @apple_team_identifier           = nil
      @apple_organization_name         = nil

      @google_service_account_credentials = nil # path or parsed hash
      @google_issuer_id = nil
      @google_class_prefix = nil
    end
  end
end
