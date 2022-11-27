# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "reenrb"

require "minitest/autorun"
require "minitest/rg"
require "zip"

require_relative "fixture_helper"
