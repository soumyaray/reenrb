# frozen_string_literal: true

require_relative "spec_helper"
require "zip"

describe "Executing changes" do # rubocop:disable Metrics/BlockLength
  before do
    recreate_example_dir
    @old_glob = Dir.glob(EXAMPLE_ALL)
    @reen_mock_editor = Reenrb::Reen.new(options: { mock_editor: true })
  end

  after do
    remove_example_dirs
  end

  it "should know to make no changes" do
    tasks = @reen_mock_editor.execute(EXAMPLE_ALL) { nil }
    _(tasks.all? { |ch| ch.status == :executed }).must_equal true
    _(@old_glob == Dir.glob(EXAMPLE_ALL)).must_equal true
  end

  it "should execute renaming correctly" do
    tasks = @reen_mock_editor.execute(EXAMPLE_ALL) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Rename LICSENSE.txt -> LICENSE.md
      index = lines.index { |l| l.include? "LICENSE.txt" }
      lines[index] = lines[index].gsub("txt", "md")
      File.write(tmpfile_path, lines.join("\n"))
    end

    new_glob = Dir.glob(EXAMPLE_ALL)

    _(tasks.all? { |ch| ch.status == :executed }).must_equal true
    _(@old_glob == new_glob).must_equal false

    index = @old_glob.index { |l| l.include? "LICENSE.txt" }
    _(new_glob[index]).must_include "LICENSE.md"
  end

  it "should execute deletion correctly" do
    tasks = @reen_mock_editor.execute(EXAMPLE_ALL) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Delete bin/myexec
      index = lines.index { |l| l.include? "bin/myexec" }
      lines[index] = lines[index].prepend("- ")
      File.write(tmpfile_path, lines.join("\n"))
    end

    new_glob = Dir.glob(EXAMPLE_ALL)

    _(tasks.all? { |ch| ch.status == :executed }).must_equal true
    _(@old_glob == new_glob).must_equal false

    _(new_glob.size).must_equal @old_glob.size - 1
    _(new_glob.select { |l| l.include?("bin/myexec") }).must_equal []
  end

  it "should execute multiple requests correctly" do
    _(@old_glob.select { |l| l.include?(".yaml") }.size).must_equal 0

    tasks = @reen_mock_editor.execute(EXAMPLE_ALL) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Rename 3 code files
      lines = lines.map { |l| l.gsub(".json", ".yaml") }
      File.write(tmpfile_path, lines.join("\n"))
    end

    new_glob = Dir.glob(EXAMPLE_ALL)

    _(tasks.all? { |ch| ch.status == :executed }).must_equal true
    _(@old_glob == new_glob).must_equal false

    _(new_glob.select { |l| l.include?(".json") }.size).must_equal 0
    _(new_glob.select { |l| l.include?(".yaml") }.size).must_equal 3
  end
end
