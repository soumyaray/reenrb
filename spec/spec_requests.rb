# frozen_string_literal: true

require_relative "spec_helper"

describe "Changes requested" do # rubocop:disable Metrics/BlockLength
  before do
    FixtureHelper.recreate_example_dir
    @old_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)
    @reen_mock_editor = Reenrb::Reen.new(editor: nil)
  end

  after do
    FixtureHelper.remove_example_dirs
  end

  it "should know to make no changes" do
    requests = @reen_mock_editor.request(@old_glob)

    _(requests.no_changes_requested?).must_equal true
  end

  it "should consider renaming details correctly" do
    requests = @reen_mock_editor.request(@old_glob) do |file|
      # Rename LICENSE.txt -> LICENSE.md
      index = file.list.index { |l| l.include? "LICENSE.txt" }
      file.list[index] = file.list[index].gsub("txt", "md")
    end

    _(requests.changes_requested?).must_equal true

    renames = requests.rename_requested.list.first
    _(renames.original.include?("LICENSE.txt")).must_equal true
    _(renames.requested.include?("LICENSE.md")).must_equal true
  end

  it "should consider deletion requests correctly" do
    requests = @reen_mock_editor.request(@old_glob) do |file|
      # Delete bin/myexec
      index = file.list.index { |l| l.include? "bin/myexec" }
      file.list[index] = file.list[index].prepend("- ")
    end

    _(requests.changes_requested?).must_equal true

    deletes = requests.delete_requested.list.first
    _(deletes.original.include?("bin/myexec")).must_equal true
  end

  it "should consider multiple renaming requests correctly" do
    requests = @reen_mock_editor.request(@old_glob) do |file|
      # Rename 3 code files
      file.list.map! { |l| l.gsub(".json", ".yaml") }
    end

    renamed = requests.rename_requested
    _(renamed.count).must_equal 3
  end
end
