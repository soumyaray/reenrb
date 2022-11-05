# frozen_string_literal: true

require_relative "spec_helper"

describe "Changes requested" do
  before do
    @reen_mock_editor = Reenrb::Reen.new(options: { mock_editor: true })
  end

  it "should know to make no changes" do
    changed = @reen_mock_editor.call("*") { nil }

    _(changed.all? { |ch| ch.change == :none }).must_equal true
  end

  it "should know to make no changes" do
    changed = @reen_mock_editor.call("*") { |tmpfile_path|
      lines = File.read(tmpfile_path).split("\n")
      lines[3] = "renamed_file"
      File.write(tmpfile_path, lines.join("\n"))
    }

    _(changed.all? { |ch| ch.change == :none }).must_equal false
    _(changed[3].change).must_equal :rename
  end
end
