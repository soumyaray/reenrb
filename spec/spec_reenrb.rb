# frozen_string_literal: true

require_relative "spec_helper"

describe "Gem setup" do
  it "should have a version number" do
    _(::Reenrb::VERSION).wont_be_nil
  end
end
