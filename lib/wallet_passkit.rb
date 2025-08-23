# frozen_string_literal: true

require "openssl"
require "json"
require "digest/sha1"
require "zip"

require_relative "wallet_passkit/version"
require_relative "wallet_passkit/configuration"
require_relative "wallet_passkit/apple/generator"
require_relative "wallet_passkit/apple/service"
require_relative "wallet_passkit/google/service"
require_relative "wallet_passkit/railtie"

module WalletPasskit
  class Error < StandardError; end

  def self.configure
    yield(config)
  end

  def self.config
    @config ||= Configuration.new
  end
end
