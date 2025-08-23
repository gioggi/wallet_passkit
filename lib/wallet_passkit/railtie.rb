# frozen_string_literal: true

begin
  require 'rails'
rescue LoadError
end

module WalletPasskit
  if defined?(Rails)
    class Railtie < ::Rails::Railtie
      # Allow configuration via Rails.application.config.wallet_passkit
      config.wallet_passkit = ActiveSupport::OrderedOptions.new

      initializer 'wallet_passkit.configure' do |app|
        cfg = app.config.wallet_passkit
        WalletPasskit.configure do |c|
          c.apple_pass_certificate_p12_path = cfg.apple_pass_certificate_p12_path if cfg.key?(:apple_pass_certificate_p12_path)
          c.apple_pass_certificate_password = cfg.apple_pass_certificate_password if cfg.key?(:apple_pass_certificate_password)
          c.apple_wwdr_certificate_path     = cfg.apple_wwdr_certificate_path if cfg.key?(:apple_wwdr_certificate_path)
          c.apple_team_identifier           = cfg.apple_team_identifier if cfg.key?(:apple_team_identifier)
          c.apple_organization_name         = cfg.apple_organization_name if cfg.key?(:apple_organization_name)

          c.google_service_account_credentials = cfg.google_service_account_credentials if cfg.key?(:google_service_account_credentials)
          c.google_issuer_id   = cfg.google_issuer_id if cfg.key?(:google_issuer_id)
          c.google_class_prefix = cfg.google_class_prefix if cfg.key?(:google_class_prefix)
        end
      end
    end
  end
end
