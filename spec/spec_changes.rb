# frozen_string_literal: true

require_relative "spec_helper"

describe "Executing changes" do # rubocop:disable Metrics/BlockLength
  before do
    FixtureHelper.recreate_example_dir
    @old_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)
    @reen_mock_editor = Reen::Reen.new(editor: nil)
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
      # Delete bin/myexec — insert "- " after the [NN] prefix
      index = file.list.index { |l| l.include? "bin/myexec" }
      file.list[index] = file.list[index].sub("] ", "] - ")
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
      # Forcibly delete bin/ folder — insert "-- " after the [NN] prefix
      index = file.list.index { |l| l.end_with? "/bin" }
      file.list[index] = file.list[index].sub("] ", "] -- ")
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
      # Try to delete bin/ folder — insert "- " after the [NN] prefix
      index = file.list.index { |l| l.end_with? "/bin" }
      file.list[index] = file.list[index].sub("] ", "] - ")
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

  it "HAPPY: should rename child file before parent folder when reordered" do
    tasks = @reen_mock_editor.execute(@old_glob) do |file|
      # Rename a file inside tests/ and rename the tests/ folder itself
      file.list.each_with_index do |line, i|
        if line.include?("tests/helper.code")
          file.list[i] = line.gsub("tests/helper.code", "tests/helper.rb")
        elsif line.end_with?("/tests")
          file.list[i] = line.gsub("/tests", "/specs")
        end
      end

      # Move the child file line before the parent folder line
      folder_idx = file.list.index { |l| l.end_with?("/specs") }
      child_idx = file.list.index { |l| l.include?("helper.rb") }
      child_line = file.list.delete_at(child_idx)
      file.list.insert(folder_idx, child_line)
    end

    new_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)

    _(tasks.failed.count).must_equal 0
    _(new_glob.any? { |l| l.include?("specs/helper.rb") }).must_equal true
    _(new_glob.any? { |l| l.end_with?("/specs") }).must_equal true
  end

  it "SAD: should fail child rename when parent folder renamed first in default order" do
    tasks = @reen_mock_editor.execute(@old_glob) do |file|
      # Rename a file inside tests/ and rename the tests/ folder itself
      # Keep default order (folder before file) — no reordering
      file.list.each_with_index do |line, i|
        if line.include?("tests/helper.code")
          file.list[i] = line.gsub("tests/helper.code", "tests/helper.rb")
        elsif line.end_with?("/tests")
          file.list[i] = line.gsub("/tests", "/specs")
        end
      end
    end

    # Without reordering, folder renames first, breaking the child path
    _(tasks.failed.count).must_equal 1
    _(tasks.failed.list.first.original).must_include "tests/helper.code"
  end
end
