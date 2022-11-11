# frozen_string_literal: true

require "tempfile"

module Reenrb
  # Manages a temporary file with requested changes
  class ChangesFile
    INSTRUCTIONS = <<~COMMENTS
      # Edit the names of any files/folders to rename or move them
      # - Put a preceeding dash to delete a file or empty folder

    COMMENTS

    def initialize(requested_list)
      @list_file = Tempfile.new("reenrb-")
      @list_file.write(INSTRUCTIONS)
      @list_file.write(requested_list.join("\n"))
      @list_file.close
    end

    def path
      @list_file.path
    end

    def allow_changes(&block)
      block.call(self)
      lines = File.read(path).split("\n").map(&:strip)
      lines.reject { |line| line.start_with?("#") || line.empty? }
    end

    def await_editor(editor)
      `#{editor} #{@list_file.path}`
    end
  end
end
