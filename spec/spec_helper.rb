# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "reenrb"

require "minitest/autorun"
require "minitest/rg"
require "zip"

require_relative "fixture_helper"
