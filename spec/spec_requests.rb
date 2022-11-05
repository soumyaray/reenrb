# frozen_string_literal: true

require_relative "spec_helper"

describe "Changes requested" do # rubocop:disable Metrics/BlockLength
  before do
    recreate_example_dir
    @old_glob = Dir.glob(EXAMPLE_ALL)
    @reen_mock_editor = Reenrb::Reen.new(options: { mock_editor: true })
  end

  after do
    remove_example_dirs
  end

  it "should know to make no changes" do
    requests = @reen_mock_editor.request(@old_glob) { nil }

    _(requests.all? { |ch| ch.change == :none }).must_equal true
  end

  it "should consider renaming details correctly" do
    requests = @reen_mock_editor.request(@old_glob) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Rename LICSENSE.txt -> LICENSE.md
      index = lines.index { |l| l.include? "LICENSE.txt" }
      lines[index] = lines[index].gsub("txt", "md")
      File.write(tmpfile_path, lines.join("\n"))
    end

    _(requests.all? { |ch| ch.change == :none }).must_equal false

    renames = requests.select { |ch| ch.change == :rename }.first
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

    _(requests.all? { |ch| ch.change == :none }).must_equal false

    deletes = requests.select { |ch| ch.change == :delete }.first
    _(deletes.original.include?("bin/myexec")).must_equal true
  end

  it "should consider multiple renaming requests correctly" do
    requests = @reen_mock_editor.request(@old_glob) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Rename 3 code files
      lines = lines.map { |l| l.gsub(".json", ".yaml") }
      File.write(tmpfile_path, lines.join("\n"))
    end

    renamed = requests.select { |ch| ch.change == :rename }
    _(renamed.size).must_equal 3
  end
end
