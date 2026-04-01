# frozen_string_literal: true

module Reen
  # Renames pattern of files with given editor
  # Examples:
  #   Reen::Reen.new(editor: "code -w").call("spec/fixtures/example/*")
  #   Reen::Reen.new(editor: nil).call("spec/fixtures/example/*") { ... }
  class Reen
    DEL_ERROR = "Do not remove any file/folder names (no changes made)"

    attr_reader :changes

    def initialize(editor: "emacs", options: {})
      @editor = editor
      @options = options
    end

    def request(original_list, &block)
      @entry_list = PathEntryList.new(original_list)
      changed_list = ChangesFile.new(@entry_list).allow_changes(@editor, &block)

      raise(Error, DEL_ERROR) if changed_list.size != @entry_list.count

      @changes = detect_changes(@entry_list, changed_list)
    end

    def execute(original_list, &block)
      @changes ||= request(original_list, &block)
      @changes = @changes.execute_all
    end

    private

    def detect_changes(entry_list, changed_list)
      changed_by_number = PathEntryList.from_numbered(changed_list)
      entries = entry_list.to_a

      changes = changed_by_number.map do |number, revised|
        Change.new(entries[number - 1], revised)
      end

      Changes.new(changes)
    end
  end
end
