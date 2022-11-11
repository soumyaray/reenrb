# frozen_string_literal: true

module Reenrb
  # Renames pattern of files with given editor
  # Examples:
  #   Reenrb::Reen.new(editor: "code -w").call("spec/fixtures/example/*")
  #   Reenrb::Reen.new(editor: nil).call("spec/fixtures/example/*") { ... }
  class Reen
    DEL_ERROR = "Do not remove any file/folder names (no changes made)"

    attr_reader :changes

    def initialize(editor: "emacs", options: {})
      @editor = editor
      @options = options
    end

    def request(original_list, &block)
      changed_list = ChangesFile.new(original_list).allow_changes(@editor, &block)

      raise(Error, DEL_ERROR) if changed_list.size != original_list.size

      @changes = compare_lists(original_list, changed_list)
                 .then { |change_array| Changes.new(change_array) }
    end

    def execute(original_list, &block)
      @changes ||= request(original_list, &block)
      @changes = @changes.execute_all
    end

    private

    def compare_lists(original_list, changed_list)
      original_list.zip(changed_list).map do |original, revised|
        Change.new(original, revised)
      end
    end
  end
end
