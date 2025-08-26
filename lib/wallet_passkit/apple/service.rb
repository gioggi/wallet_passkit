# frozen_string_literal: true

require "openssl"
require "json"
require "digest/sha1"
require "zip"

module WalletPasskit
  module Apple
    class Service
      def self.build_pass_payload(description:, pass_type_identifier:, serial_number:, logo_text:, primary_fields: [], secondary_fields: [], auxiliary_fields: [], back_fields: [], team_identifier: nil, organization_name: nil, pass_type: :storeCard, background_color: nil, label_color: nil, foreground_color: nil)
        team_identifier ||= WalletPasskit.config.apple_team_identifier
        organization_name ||= WalletPasskit.config.apple_organization_name

        base = {
          formatVersion: 1,
          description: description,
          organizationName: organization_name,
          teamIdentifier: team_identifier,
          passTypeIdentifier: pass_type_identifier,
          serialNumber: serial_number,
          logoText: logo_text
        }

        section_key = pass_type.to_sym == :storeCard ? :storeCard : :generic
        section_payload = {}
        section_payload[:primaryFields] = primary_fields if primary_fields && !primary_fields.empty?
        section_payload[:secondaryFields] = secondary_fields if secondary_fields && !secondary_fields.empty?
        section_payload[:auxiliaryFields] = auxiliary_fields if auxiliary_fields && !auxiliary_fields.empty?
        section_payload[:backFields] = back_fields if back_fields && !back_fields.empty?

        base[section_key] = section_payload unless section_payload.empty?

        base[:backgroundColor] = background_color if background_color
        base[:labelColor] = label_color if label_color
        base[:foregroundColor] = foreground_color if foreground_color

        base
      end

      def self.generate_pkpass(pass_payload:, assets: {})
        p12_path = WalletPasskit.config.apple_pass_certificate_p12_path
        p12_password = WalletPasskit.config.apple_pass_certificate_password
        wwdr_path = WalletPasskit.config.apple_wwdr_certificate_path

        raise WalletPasskit::Error, "Missing Apple certificate configuration" unless p12_path && p12_password && wwdr_path

        files = { "pass.json" => JSON.pretty_generate(pass_payload) }
        files.merge!(assets)

        manifest = {}
        files.each do |name, content|
          manifest[name] = Digest::SHA1.hexdigest(content)
        end
        manifest_json = JSON.generate(manifest)

        signature_der = WalletPasskit::Apple::Signer.sign(
          data: manifest_json,
          p12_path: p12_path,
          p12_password: p12_password,
          wwdr_path: wwdr_path
        )

        io = StringIO.new
        Zip::OutputStream.write_buffer(io) do |zip|
          files.each do |name, content|
            zip.put_next_entry(name)
            zip.write(content)
          end

          zip.put_next_entry("manifest.json")
          zip.write(manifest_json)

          zip.put_next_entry("signature")
          zip.write(signature_der)
        end
        io.rewind
        io.read
      end
    end
  end
end