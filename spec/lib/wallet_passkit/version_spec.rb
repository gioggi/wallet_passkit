# frozen_string_literal: true

require "spec_helper"

RSpec.describe "WalletPasskit::VERSION" do
  it "is defined" do
    expect(WalletPasskit::VERSION).to be_truthy
  end

  it "is a string" do
    expect(WalletPasskit::VERSION).to be_a(String)
  end

  it "follows semantic versioning format" do
    expect(WalletPasskit::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end

  it "has a valid version number" do
    expect(WalletPasskit::VERSION).to eq("0.1.0")
  end
end
