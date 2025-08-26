# wallet_passkit

A modern Ruby gem to generate Apple Wallet passes (.pkpass) and integrate easily into Rails projects. Also includes Google Wallet helpers (Save link, object updates).

[![CI](https://github.com/gioggi/wallet_passkit/actions/workflows/test.yml/badge.svg)](https://github.com/gioggi/wallet_passkit/actions/workflows/test.yml)

Status: initial implementation for Apple + Google (Save link + updater).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wallet_passkit', path: '.' # or gem 'wallet_passkit', version: '0.1.0'
```

And then execute:

```bash
bundle install
```

## Configuration

Global configuration in plain Ruby:

```ruby
require 'wallet_passkit'

WalletPasskit.configure do |c|
  c.apple_pass_certificate_p12_path = "/path/to/pass_certificate.p12"
  c.apple_pass_certificate_password = ENV["APPLE_PASS_P12_PASSWORD"]
  c.apple_wwdr_certificate_path     = "/path/to/AppleWWDRCAG3.pem" # download from Apple
  c.apple_team_identifier           = "TEAMID1234"
  c.apple_organization_name         = "My Org"

  # Google Wallet (optional for Save link / updater)
  c.google_service_account_credentials = "/path/to/service_account.json"
  c.google_issuer_id   = "issuer-id" # optional
  c.google_class_prefix = "com.example" # optional
end
```

Rails (config/initializers/wallet_passkit.rb):

```ruby
Rails.application.config.wallet_passkit.apple_pass_certificate_p12_path = Rails.root.join('config', 'certs', 'pass_cert.p12').to_s
Rails.application.config.wallet_passkit.apple_pass_certificate_password = ENV['APPLE_PASS_P12_PASSWORD']
Rails.application.config.wallet_passkit.apple_wwdr_certificate_path     = Rails.root.join('config', 'certs', 'AppleWWDRCAG3.pem').to_s
Rails.application.config.wallet_passkit.apple_team_identifier           = ENV['APPLE_TEAM_ID']
Rails.application.config.wallet_passkit.apple_organization_name         = 'My Org'

Rails.application.config.wallet_passkit.google_service_account_credentials = Rails.root.join('config', 'google', 'service_account.json').to_s
```

## Apple Wallet: Generate a .pkpass

At minimum you need:
- A pass type ID certificate (.p12) and password
- Apple WWDR certificate (PEM)
- A `pass.json` payload
- Required images (icon.png; icon@2x.png recommended)

Example in Rails controller action:

```ruby
payload = WalletPasskit::Apple::Service.build_pass_payload(
  description: 'Loyalty Card',
  pass_type_identifier: 'pass.com.example.loyalty',
  serial_number: 'ABC123',
  logo_text: 'My Store',
  primary_fields: [ { key: 'points', label: 'Points', value: '100' } ],
  background_color: 'rgb(255,0,0)',
  foreground_color: 'rgb(255,255,255)'
)

assets = {
  'icon.png' => File.binread(Rails.root.join('app/assets/images/pass/icon.png')),
  'icon@2x.png' => File.binread(Rails.root.join('app/assets/images/pass/icon@2x.png')),
  # add logo.png, strip.png, background.png as needed
}

pkpass_binary = WalletPasskit::Apple::Service.generate_pkpass(pass_payload: payload, assets: assets)

send_data pkpass_binary, filename: 'loyalty.pkpass', type: 'application/vnd.apple.pkpass'
```

If you prefer to fully control pass.json, just pass your own hash to `generate_pkpass`.

## Google Wallet: Build a Save link (+ customization)

See detailed docs in `lib/wallet_passkit/google/README.md`.

Minimal example:

```ruby
company = {
  issuer_id: ENV['GOOGLE_ISSUER_ID'],
  class_id: 'loyalty-class-id',
  background_color: '#FF0000',
  font_color: '#FFFFFF',
  logo_uri: 'https://example.com/logo.png',
  hero_image_uri: 'https://example.com/hero.png',
  locations: [ { latitude: 45.4642, longitude: 9.1900 } ]
}

customer = {
  id: 'customer-123',
  first_name: 'Mario',
  last_name: 'Rossi',
  points: 120,
  qr_value: 'UUID-1234'
}

url = WalletPasskit::Google::Pass.new(
  company: company,
  customer: customer,
  service_account_path: Rails.application.config.wallet_passkit.google_service_account_credentials
).save_url
```

Updating points later via REST:

```ruby
WalletPasskit::Google::PassUpdater.new(
  object_id: "#{company[:issuer_id]}.#{customer[:id]}",
  service_account_path: Rails.application.config.wallet_passkit.google_service_account_credentials
).update_points(new_point_value: 150)
```

### Google docs
- Developer guide: https://developers.google.com/wallet
- Wallet Objects API reference: https://developers.google.com/wallet/retail/loyalty-cards

## Development

- Run tests: `bundle exec rspec`
- Lint: pending

## Notes & Limitations

- Apple requires asset files to be included and a correctly signed manifest. This gem signs with PKCS#7 (DER) using your pass certificate and Apple WWDR intermediate.
- You must handle obtaining and managing certificates/keys securely.
- For Google Wallet, this gem builds a Save link JWT and provides a minimal updater; for full class/object management, extend accordingly.

## License

MIT
