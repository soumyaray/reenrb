# frozen_string_literal: true

require_relative "spec_helper"

describe "Reen::ReenCLI" do # rubocop:disable Metrics/BlockLength
  before do
    FixtureHelper.recreate_example_dir
  end

  after do
    FixtureHelper.remove_example_dirs
  end

  # Helper: build a shell-safe editor command that performs a gsub on the temp file
  def editor_gsub(from, to)
    %(ruby -e "f=ARGV[0]; File.write(f, File.read(f).gsub('#{from}','#{to}'))")
  end

  # Helper: build an editor that inserts a delete prefix ("- ") before a filename
  def editor_delete(filename)
    %(ruby -e "f=ARGV[0]; File.write(f, File.read(f).gsub('] #{filename}', '] - #{filename}'))")
  end

  # Helper: capture stdout from a block
  def capture_stdout
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end

  describe "option parsing" do # rubocop:disable Metrics/BlockLength
    it "should accept --editor flag" do
      cli = Reen::ReenCLI.new(["--editor", "cat", "spec/fixtures/example/README.md"])
      _(cli.options.editor).must_equal "cat"
    end

    it "should accept -e flag" do
      cli = Reen::ReenCLI.new(["-e", "cat", "spec/fixtures/example/README.md"])
      _(cli.options.editor).must_equal "cat"
    end

    it "should accept --review flag" do
      cli = Reen::ReenCLI.new(["--editor", "cat", "-r", "spec/fixtures/example/README.md"])
      _(cli.options.review).must_equal true
    end

    it "should exit on invalid option" do
      assert_raises(SystemExit) do
        capture_stdout { Reen::ReenCLI.new(["--invalid"]) }
      end
    end

    it "should exit when no editor is available" do
      original_visual = ENV.fetch("VISUAL", nil)
      original_editor = ENV.fetch("EDITOR", nil)
      ENV["VISUAL"] = nil
      ENV["EDITOR"] = nil
      assert_raises(SystemExit) do
        capture_stdout { Reen::ReenCLI.new(["somefile"]) }
      end
    ensure
      ENV["VISUAL"] = original_visual
      ENV["EDITOR"] = original_editor
    end
  end

  describe "renaming via CLI" do
    it "should rename a file and report changes" do
      target = "spec/fixtures/example/LICENSE.txt"
      editor = editor_gsub("LICENSE.txt", "LICENSE.md")

      cli = Reen::ReenCLI.new(["--editor", editor, target])
      output = capture_stdout { cli.call }

      _(output).must_include "Renaming"
      _(output).must_include "LICENSE.md"
      _(File.exist?("spec/fixtures/example/LICENSE.md")).must_equal true
      _(File.exist?(target)).must_equal false
    end
  end

  describe "no changes via CLI" do
    it "should report nothing changed when editor makes no edits" do
      target = "spec/fixtures/example/README.md"

      cli = Reen::ReenCLI.new(["--editor", "true", target])
      output = capture_stdout { cli.call }

      _(output).must_include "Nothing changed"
      _(File.exist?(target)).must_equal true
    end
  end

  describe "deletion via CLI" do
    it "should delete a file and report changes" do
      target = "spec/fixtures/example/SETUP.txt"
      editor = editor_delete(target)

      cli = Reen::ReenCLI.new(["--editor", editor, target])
      output = capture_stdout { cli.call }

      _(output).must_include "Deleting"
      _(File.exist?(target)).must_equal false
    end
  end

  describe "review mode" do
    it "should prompt for confirmation and proceed on yes" do
      target = "spec/fixtures/example/LICENSE.txt"
      editor = editor_gsub("LICENSE.txt", "LICENSE.md")

      cli = Reen::ReenCLI.new(["--editor", editor, "-r", target])

      # Stub stdin to answer "y"
      old_stdin = $stdin
      $stdin = StringIO.new("y\n")
      output = capture_stdout { cli.call }
      $stdin = old_stdin

      _(output).must_include "Renaming"
      _(output).must_include "Changes made"
      _(File.exist?("spec/fixtures/example/LICENSE.md")).must_equal true
    end

    it "should exit on review rejection" do
      target = "spec/fixtures/example/LICENSE.txt"
      editor = editor_gsub("LICENSE.txt", "LICENSE.md")

      cli = Reen::ReenCLI.new(["--editor", editor, "-r", target])

      old_stdin = $stdin
      $stdin = StringIO.new("n\n")
      assert_raises(SystemExit) do
        capture_stdout { cli.call }
      end
      $stdin = old_stdin

      # File should NOT have been renamed
      _(File.exist?(target)).must_equal true
    end
  end

  describe "multiple files" do
    it "should rename multiple files" do
      targets = Dir.glob("spec/fixtures/example/tests/fixtures/*.json")
      editor = editor_gsub(".json", ".yaml")

      cli = Reen::ReenCLI.new(["--editor", editor, *targets])
      output = capture_stdout { cli.call }

      _(output).must_include "Renaming"
      yaml_files = Dir.glob("spec/fixtures/example/tests/fixtures/*.yaml")
      json_files = Dir.glob("spec/fixtures/example/tests/fixtures/*.json")
      _(yaml_files.size).must_equal 3
      _(json_files.size).must_equal 0
    end
  end
end
