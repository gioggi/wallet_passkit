# frozen_string_literal: true

require "spec_helper"

RSpec.describe WalletPasskit::Error do
  it "inherits from StandardError" do
    expect(described_class).to be < StandardError
  end

  it "can be instantiated" do
    error = described_class.new("Test error message")
    expect(error.message).to eq("Test error message")
  end

  it "can be raised" do
    expect { raise described_class, "Test error" }.to raise_error(described_class, "Test error")
  end
end
