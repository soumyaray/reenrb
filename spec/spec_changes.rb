# frozen_string_literal: true

require_relative "spec_helper"

describe "Executing changes" do # rubocop:disable Metrics/BlockLength
  before do
    FixtureHelper.recreate_example_dir
    @old_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)
    @reen_mock_editor = Reenrb::Reen.new(editor: nil)
  end

  after do
    FixtureHelper.remove_example_dirs
  end

  it "HAPPY: should know to make no changes" do
    tasks = @reen_mock_editor.execute(@old_glob) { nil }

    new_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)

    _(tasks.all_executed?).must_equal true
    _(@old_glob).must_equal new_glob
  end

  it "HAPPY: should execute renaming correctly" do
    tasks = @reen_mock_editor.execute(@old_glob) do |file|
      # Rename LICENSE.txt -> LICENSE.md
      index = file.list.index { |l| l.include? "LICENSE.txt" }
      file.list[index] = file.list[index].gsub("txt", "md")
    end

    new_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)

    _(tasks.all_executed?).must_equal true
    _(@old_glob).wont_equal new_glob

    index = @old_glob.index { |l| l.include? "LICENSE.txt" }
    _(new_glob[index]).must_include "LICENSE.md"
  end

  it "HAPPY: should execute deletion correctly" do
    tasks = @reen_mock_editor.execute(@old_glob) do |file|
      # Delete bin/myexec
      index = file.list.index { |l| l.include? "bin/myexec" }
      file.list[index] = file.list[index].prepend("- ")
    end

    new_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)

    _(tasks.all_executed?).must_equal true
    _(@old_glob).wont_equal new_glob

    _(new_glob.size).must_equal @old_glob.size - 1
    _(new_glob.select { |l| l.include?("bin/myexec") }).must_equal []
  end

  it "HAPPY: should execute force deletion of non-empty folder correctly" do
    num_expect_affected = @old_glob.select { |l| l.include?("/bin") }.count

    tasks = @reen_mock_editor.execute(@old_glob) do |file|
      # Forcibly delete bin/ folder and its files and subfolders
      index = file.list.index { |l| l.end_with? "/bin" }
      file.list[index] = file.list[index].prepend("-- ")
    end

    new_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)

    _(tasks.all_executed?).must_equal true
    _(@old_glob).wont_equal new_glob

    _(new_glob.size).must_equal @old_glob.size - num_expect_affected
    _(new_glob.select { |l| l.include?("/bin") }).must_equal []
  end

  it "SAD: should not be able to delete non-empty folder" do
    num_expect_affected = @old_glob.select { |l| l.include?("/bin") }.count

    tasks = @reen_mock_editor.execute(@old_glob) do |file|
      # Try to delete bin/ folder and its files and subfolders
      index = file.list.index { |l| l.end_with? "/bin" }
      file.list[index] = file.list[index].prepend("- ")
    end

    new_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)

    _(num_expect_affected > 1).must_equal true
    _(tasks.all_executed?).must_equal false
    _(tasks.rejected.count).must_equal 1
    _(@old_glob).must_equal new_glob
  end

  it "HAPPY: should execute multiple requests correctly" do
    _(@old_glob.select { |l| l.include?(".yaml") }.size).must_equal 0

    tasks = @reen_mock_editor.execute(@old_glob) do |file|
      # Rename 3 code files
      file.list.map! { |l| l.gsub(".json", ".yaml") }
    end

    new_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)

    _(tasks.all_executed?).must_equal true
    _(@old_glob).wont_equal new_glob

    _(new_glob.select { |l| l.include?(".json") }.size).must_equal 0
    _(new_glob.select { |l| l.include?(".yaml") }.size).must_equal 3
  end
end
