# frozen_string_literal: true

require_relative "spec_helper"

describe "Changes requested" do # rubocop:disable Metrics/BlockLength
  before do
    @reen_mock_editor = Reenrb::Reen.new(options: { mock_editor: true })
  end

  it "should know to make no changes" do
    changed = @reen_mock_editor.call(EXAMPLES_ALL) { nil }

    _(changed.all? { |ch| ch.change == :none }).must_equal true
  end

  it "should recognize a renaming details correctly" do
    changed = @reen_mock_editor.call(EXAMPLES_ALL) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Rename LICSENSE.txt -> LICENSE.md
      index = lines.index { |l| l.include? "LICENSE.txt" }
      lines[index] = lines[index].gsub("txt", "md")
      File.write(tmpfile_path, lines.join("\n"))
    end

    _(changed.all? { |ch| ch.change == :none }).must_equal false

    renamed = changed.select { |ch| ch.change == :rename }.first
    _(renamed.original.include?("LICENSE.txt")).must_equal true
    _(renamed.revised.include?("LICENSE.md")).must_equal true
  end

  it "should recognize a deletion" do
    changed = @reen_mock_editor.call(EXAMPLES_ALL) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Delete bin/myexec
      index = lines.index { |l| l.include? "bin/myexec" }
      lines[index] = lines[index].prepend("- ")
      File.write(tmpfile_path, lines.join("\n"))
    end

    _(changed.all? { |ch| ch.change == :none }).must_equal false

    renamed = changed.select { |ch| ch.change == :delete }.first
    _(renamed.original.include?("bin/myexec")).must_equal true
  end

  it "should recognize a renaming details correctly" do
    changed = @reen_mock_editor.call(EXAMPLES_ALL) do |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")

      # Rename 3 code files
      lines = lines.map { |l| l.gsub(".json", ".yaml") }
      File.write(tmpfile_path, lines.join("\n"))
    end

    renamed = changed.select { |ch| ch.change == :rename }
    _(renamed.size).must_equal 3
  end
end
