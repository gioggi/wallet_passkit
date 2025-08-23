# frozen_string_literal: true

module WalletPasskit
  module Apple
    # Generator creates a .pkpass archive from a pass.json payload and assets, and signs it
    class Generator
      REQUIRED_ASSETS = %w[icon.png].freeze

      class SignError < WalletPasskit::Error; end
      class AssetError < WalletPasskit::Error; end

      # pass_payload: Hash for pass.json
      # assets: Hash{String=>String|IO|Pathname|Array(Integer)|Binary} filename => content
      #          (provide icon.png at minimum; icon@2x.png recommended)
      # options: :p12_path, :p12_password, :wwdr_path override global config
      def self.generate_pkpass(pass_payload:, assets:, options: {})
        validate_assets!(assets)

        manifest_entries = {}
        files = {}

        # Prepare pass.json
        pass_json = JSON.pretty_generate(pass_payload)
        files["pass.json"] = pass_json
        manifest_entries["pass.json"] = sha1(pass_json)

        # Prepare assets
        assets.each do |name, content|
          bin = to_binary(content)
          files[name] = bin
          manifest_entries[name] = sha1(bin)
        end

        manifest_json = JSON.generate(manifest_entries)
        signature_der = sign_manifest(manifest_json, options)

        # Build zip (pkpass)
        buffer = Zip::OutputStream.write_buffer do |out|
          files.each do |name, content|
            out.put_next_entry(name)
            out.write(content)
          end
          out.put_next_entry("manifest.json")
          out.write(manifest_json)
          out.put_next_entry("signature")
          out.write(signature_der)
        end
        buffer.rewind
        buffer.sysread
      end

      def self.validate_assets!(assets)
        missing = REQUIRED_ASSETS - assets.keys
        return if missing.empty?
        raise AssetError, "Missing required asset(s): #{missing.join(', ')}"
      end

      def self.sha1(content)
        Digest::SHA1.hexdigest(content)
      end

      def self.to_binary(content)
        case content
        when String
          content.b
        when IO, StringIO
          content.rewind
          content.read
        when Pathname
          File.binread(content.to_s)
        else
          if content.respond_to?(:to_path)
            File.binread(content.to_path)
          else
            raise AssetError, "Unsupported asset content type: #{content.class}"
          end
        end
      end

      def self.sign_manifest(manifest_json, options)
        p12_path   = options[:p12_path]   || WalletPasskit.config.apple_pass_certificate_p12_path
        p12_pass   = options[:p12_password] || WalletPasskit.config.apple_pass_certificate_password
        wwdr_path  = options[:wwdr_path]  || WalletPasskit.config.apple_wwdr_certificate_path

        raise SignError, "Apple pass certificate (.p12) path not configured" unless p12_path && File.exist?(p12_path)
        raise SignError, "Apple WWDR certificate path not configured" unless wwdr_path && File.exist?(wwdr_path)

        p12 = OpenSSL::PKCS12.new(File.binread(p12_path), p12_pass)
        sign_cert = p12.certificate
        sign_key  = p12.key
        wwdr_cert = OpenSSL::X509::Certificate.new(File.read(wwdr_path))

        signed = OpenSSL::PKCS7.sign(sign_cert, sign_key, manifest_json, [wwdr_cert], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED)
        # PKCS7 DER format required by Apple
        signed.to_der
      rescue OpenSSL::PKCS12::PKCS12Error => e
        raise SignError, "Invalid pass certificate or password: #{e.message}"
      end
    end
  end
end
