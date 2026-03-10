# frozen_string_literal: true

require_relative "spec_helper"

describe "Change dash-operator parsing" do # rubocop:disable Metrics/BlockLength
  before do
    FixtureHelper.recreate_example_dir
    @file_path = Dir.glob(FixtureHelper::EXAMPLE_ALL).find { |f| File.file?(f) }
    @entry = Reenrb::PathEntry.new(@file_path)
  end

  after do
    FixtureHelper.remove_example_dirs
  end

  it "should treat '- filename' (dash space) as delete" do
    change = Reenrb::Change.new(@entry, "- #{@file_path}")

    _(change.change).must_equal :delete
  end

  it "should treat '-filename' (no space) as rename to -filename" do
    change = Reenrb::Change.new(@entry, "-#{@file_path}")

    _(change.change).must_equal :rename
    _(change.requested).must_equal "-#{@file_path}"
  end

  it "should treat '-- filename' (double dash space) as force delete" do
    change = Reenrb::Change.new(@entry, "-- #{@file_path}")

    _(change.change).must_equal :force_delete
  end

  it "should treat '--filename' (no space) as rename to --filename" do
    change = Reenrb::Change.new(@entry, "--#{@file_path}")

    _(change.change).must_equal :rename
    _(change.requested).must_equal "--#{@file_path}"
  end
end
