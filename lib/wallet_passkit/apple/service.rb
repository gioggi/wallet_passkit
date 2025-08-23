# frozen_string_literal: true

module WalletPasskit
  module Apple
    # High-level service to build and return a .pkpass payload
    class Service
      # Example minimal pass payload builder for a generic pass (storeCard type)
      def self.build_pass_payload(
        description:,
        organization_name: WalletPasskit.config.apple_organization_name,
        pass_type_identifier:,
        serial_number:,
        team_identifier: WalletPasskit.config.apple_team_identifier,
        logo_text: nil,
        foreground_color: "#FFFFFF",
        background_color: "#000000",
        label_color: "#FFFFFF",
        primary_fields: [],
        secondary_fields: [],
        auxiliary_fields: [],
        back_fields: []
      )
        {
          description: description,
          formatVersion: 1,
          organizationName: organization_name,
          passTypeIdentifier: pass_type_identifier,
          serialNumber: serial_number,
          teamIdentifier: team_identifier,
          logoText: logo_text,
          foregroundColor: foreground_color,
          backgroundColor: background_color,
          labelColor: label_color,
          storeCard: {
            primaryFields: primary_fields,
            secondaryFields: secondary_fields,
            auxiliaryFields: auxiliary_fields,
            backFields: back_fields
          }
        }.compact
      end

      # Generates a .pkpass binary
      # assets: hash of filename => binary/path (must include icon.png)
      # options: certificate overrides
      def self.generate_pkpass(pass_payload:, assets:, options: {})
        Generator.generate_pkpass(pass_payload: pass_payload, assets: assets, options: options)
      end
    end
  end
end
