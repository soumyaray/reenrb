# frozen_string_literal: true

require_relative "reenrb/version"
require_relative "changes_file"
require_relative "change"

module Reenrb
  class Error < StandardError; end

  # Renames pattern of files with given editor
  # Example:
  #   Reenrb::Reen.new(editor: "code -w").call("spec/fixtures/example/*")
  class Reen
    DEL_ERROR = "Do not delete any file/folder names"

    attr_reader :changes

    def initialize(editor: "emacs", options: {})
      @editor = editor
      @options = options
    end

    def request(pattern = "*", &block)
      original_list = Dir.glob(pattern)
      changed_list = ChangesFile.new(original_list).allow_changes do |file|
        @options[:mock_editor] ? yield(file.path) : file.blocking_edit(@editor)
      end

      raise(Error, DEL_ERROR) if changed_list.size != original_list.size

      @changes = compare_lists(original_list, changed_list)
    end

    def execute(pattern = nil, &block)
      @changes ||= request(pattern, &block)
      @changes = @changes.map(&:execute)
    end

    private

    def compare_lists(original_list, changed_list)
      original_list.zip(changed_list).map do |original, revised|
        Change.new(original, revised)
      end
    end
  end
end
