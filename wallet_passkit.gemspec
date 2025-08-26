# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "wallet_passkit"
  spec.version       = File.read(File.expand_path("lib/wallet_passkit/version.rb", __dir__)).match(/VERSION\s*=\s*"([^"]+)"/)[1] rescue "0.1.0"
  spec.authors       = ["Gioggi"]
  spec.email         = ["info@giovanniesposito.it"]

  spec.summary       = "Generate Apple Wallet .pkpass and integrate with Rails; scaffold for Google Wallet"
  spec.description   = "A modern, lightweight Ruby gem for generating Apple Wallet passes (.pkpass) with OpenSSL signing, easy Rails integration services, and a minimal Google Wallet Save link generator."
  spec.homepage      = "https://example.com/wallet_passkit"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE*"].uniq
  spec.require_paths = ["lib"]

  spec.platform      = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 2.7"

  spec.add_runtime_dependency "rubyzip", "~> 2.3"
  spec.add_runtime_dependency "jwt", "~> 2.7"
  spec.add_runtime_dependency "googleauth", ">= 0.16.0"


  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rspec", ">= 3.12"
  spec.add_development_dependency "webmock", ">= 3.0"
end
