# frozen_string_literal: true

require_relative "spec_helper"

describe "Changes requested" do # rubocop:disable Metrics/BlockLength
  before do
    FixtureHelper.recreate_example_dir
    @old_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)
    @reen_mock_editor = Reenrb::Reen.new(options: { mock_editor: true })
  end

  after do
    FixtureHelper.remove_example_dirs
  end

  it "should know to make no changes" do
    requests = @reen_mock_editor.request(@old_glob) { nil }

    _(requests.no_changes_requested?).must_equal true
  end

  it "should consider renaming details correctly" do
    requests = @reen_mock_editor.request(@old_glob) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Rename LICENSE.txt -> LICENSE.md
      index = lines.index { |l| l.include? "LICENSE.txt" }
      lines[index] = lines[index].gsub("txt", "md")
      File.write(tmpfile_path, lines.join("\n"))
    end

    _(requests.changes_requeseted?).must_equal true

    renames = requests.rename_requested.list.first
    _(renames.original.include?("LICENSE.txt")).must_equal true
    _(renames.requested.include?("LICENSE.md")).must_equal true
  end

  it "should consider deletion requests correctly" do
    requests = @reen_mock_editor.request(@old_glob) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Delete bin/myexec
      index = lines.index { |l| l.include? "bin/myexec" }
      lines[index] = lines[index].prepend("- ")
      File.write(tmpfile_path, lines.join("\n"))
    end

    _(requests.changes_requeseted?).must_equal true

    deletes = requests.delete_requested.list.first
    _(deletes.original.include?("bin/myexec")).must_equal true
  end

  it "should consider multiple renaming requests correctly" do
    requests = @reen_mock_editor.request(@old_glob) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Rename 3 code files
      lines = lines.map { |l| l.gsub(".json", ".yaml") }
      File.write(tmpfile_path, lines.join("\n"))
    end

    renamed = requests.rename_requested
    _(renamed.count).must_equal 3
  end
end
