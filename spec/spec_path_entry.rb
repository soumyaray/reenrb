# frozen_string_literal: true

require_relative "spec_helper"

describe "PathEntry" do # rubocop:disable Metrics/BlockLength
  before do
    FixtureHelper.recreate_example_dir
  end

  after do
    FixtureHelper.remove_example_dirs
  end

  it "should wrap a file path and report it is a file" do
    file_path = Dir.glob(FixtureHelper::EXAMPLE_ALL).find { |f| File.file?(f) }
    entry = Reen::PathEntry.new(file_path)

    _(entry.path).must_equal file_path
    _(entry.file?).must_equal true
    _(entry.dir?).must_equal false
  end

  it "should wrap a directory path and report it is a directory" do
    dir_path = Dir.glob(FixtureHelper::EXAMPLE_ALL).find { |f| File.directory?(f) }
    entry = Reen::PathEntry.new(dir_path)

    _(entry.path).must_equal dir_path
    _(entry.dir?).must_equal true
    _(entry.file?).must_equal false
  end

  it "should detect an empty directory" do
    empty_dir = File.join(FixtureHelper::EXAMPLE_DIR, "empty_test_dir")
    FileUtils.mkdir_p(empty_dir)
    entry = Reen::PathEntry.new(empty_dir)

    _(entry.dir?).must_equal true
    _(entry.empty_dir?).must_equal true
    _(entry.full_dir?).must_equal false
  end

  it "should detect a non-empty directory" do
    full_dir = Dir.glob(FixtureHelper::EXAMPLE_ALL).find do |f|
      File.directory?(f) && !Dir.empty?(f)
    end
    entry = Reen::PathEntry.new(full_dir)

    _(entry.dir?).must_equal true
    _(entry.empty_dir?).must_equal false
    _(entry.full_dir?).must_equal true
  end
end

describe "PathEntryList" do # rubocop:disable Metrics/BlockLength
  before do
    FixtureHelper.recreate_example_dir
    @file_list = Dir.glob(FixtureHelper::EXAMPLE_ALL)
  end

  after do
    FixtureHelper.remove_example_dirs
  end

  it "should construct from array of strings and iterate as PathEntry objects" do
    list = Reen::PathEntryList.new(@file_list)

    list.each do |entry|
      _(entry).must_be_kind_of Reen::PathEntry
    end

    _(list.count).must_equal @file_list.size
  end

  it "should return array of path strings via #paths" do
    list = Reen::PathEntryList.new(@file_list)

    _(list.paths).must_equal @file_list
  end

  it "should serialize to numbered lines with auto-sized width" do
    list = Reen::PathEntryList.new(@file_list)
    numbered = list.to_numbered

    # Width should be based on list size (e.g., 2 digits for 10-99 items)
    width = @file_list.size.to_s.length
    @file_list.each_with_index do |path, i|
      num = format("%0#{width}d", i + 1)
      _(numbered[i]).must_equal "[#{num}] #{path}"
    end
  end

  it "should parse numbered lines back to number-keyed entries" do
    list = Reen::PathEntryList.new(@file_list)
    numbered = list.to_numbered

    parsed = Reen::PathEntryList.from_numbered(numbered)

    # parsed should be a hash of { number => path_string }
    @file_list.each_with_index do |path, i|
      _(parsed[i + 1]).must_equal path
    end
  end

  it "should parse reordered numbered lines correctly" do
    list = Reen::PathEntryList.new(@file_list)
    numbered = list.to_numbered

    # Reverse the order
    reordered = numbered.reverse
    parsed = Reen::PathEntryList.from_numbered(reordered)

    # Numbers still map to original paths regardless of line order
    @file_list.each_with_index do |path, i|
      _(parsed[i + 1]).must_equal path
    end
  end
end
