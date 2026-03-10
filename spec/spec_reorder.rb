# frozen_string_literal: true

require_relative "spec_helper"

describe "Number-based matching with reordering" do # rubocop:disable Metrics/BlockLength
  before do
    FixtureHelper.recreate_example_dir
    @old_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)
    @reen_mock_editor = Reenrb::Reen.new(editor: nil)
  end

  after do
    FixtureHelper.remove_example_dirs
  end

  it "should match reordered entries to originals by number" do
    requests = @reen_mock_editor.request(@old_glob) do |file|
      # Reverse the order of lines — numbers should still match correctly
      file.list.reverse!
    end

    # Despite reordering, no actual changes were made to filenames
    _(requests.no_changes_requested?).must_equal true
  end

  it "should correctly apply rename on reordered entry" do
    requests = @reen_mock_editor.request(@old_glob) do |file|
      # Find LICENSE.txt line, rename it, then shuffle lines
      index = file.list.index { |l| l.include?("LICENSE.txt") }
      file.list[index] = file.list[index].gsub("txt", "md")

      # Move the renamed line to the end
      moved = file.list.delete_at(index)
      file.list.push(moved)
    end

    _(requests.changes_requested?).must_equal true
    renames = requests.rename_requested.list.first
    _(renames.original).must_include "LICENSE.txt"
    _(renames.requested).must_include "LICENSE.md"
  end

  it "should correctly apply delete on reordered entry" do
    tasks = @reen_mock_editor.execute(@old_glob) do |file|
      # Shuffle the list randomly
      file.list.shuffle!

      # Delete bin/myexec
      index = file.list.index { |l| l.include?("bin/myexec") }
      file.list[index] = file.list[index].sub("] ", "] - ")
    end

    new_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)
    _(tasks.all_executed?).must_equal true
    _(new_glob.select { |l| l.include?("bin/myexec") }).must_equal []
  end

  it "should execute multiple changes on shuffled list" do
    tasks = @reen_mock_editor.execute(@old_glob) do |file|
      # Shuffle the list
      file.list.shuffle!

      # Rename all .json to .yaml
      file.list.map! { |l| l.gsub(".json", ".yaml") }
    end

    new_glob = Dir.glob(FixtureHelper::EXAMPLE_ALL)
    _(tasks.all_executed?).must_equal true
    _(new_glob.select { |l| l.include?(".json") }.size).must_equal 0
    _(new_glob.select { |l| l.include?(".yaml") }.size).must_equal 3
  end

  it "should raise error when lines are removed" do
    assert_raises(Reenrb::Error) do
      @reen_mock_editor.request(@old_glob) do |file|
        file.list.pop
      end
    end
  end
end
