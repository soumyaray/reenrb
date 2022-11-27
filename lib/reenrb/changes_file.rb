# frozen_string_literal: true

require "tempfile"

module Reenrb
  # Manages a temporary file with requested changes
  class ChangesFile
    INSTRUCTIONS = <<~COMMENTS
      # Edit the names of any files/folders to rename or move them
      # - Put a preceeding dash to delete a file or empty folder

    COMMENTS

    attr_accessor :list

    def initialize(requested_list)
      @list_file = Tempfile.new("reenrb-")
      @list_file.write(INSTRUCTIONS)
      @list_file.write(requested_list.join("\n"))
      @list_file.close
    end

    def allow_changes(editor, &block)
      await_editor(editor) if editor
      @list = File.read(path).split("\n").map(&:strip)
                  .reject { |line| line.start_with?("#") || line.empty? }

      block&.call(self)
      @list
    end

    private

    def path
      @list_file.path
    end

    def await_editor(editor)
      system("#{editor} #{@list_file.path}")
    end
  end
end
