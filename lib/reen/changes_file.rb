# frozen_string_literal: true

require "tempfile"

module Reen
  # Manages a temporary file with requested changes
  class ChangesFile
    INSTRUCTIONS = <<~COMMENTS
      # Edit the names of any files/folders to rename or move them
      # - Put a dash followed by a space to delete a file or empty folder: - filename
      # - Put double dash followed by a space to force delete: -- filename
      # - Do not change or remove the [NN] number prefixes
      # - You may reorder lines freely; numbers track the original files

    COMMENTS

    attr_accessor :list

    def initialize(entry_list)
      @entry_list = entry_list
      @list_file = Tempfile.new("reen-")
      @list_file.write(INSTRUCTIONS)
      @list_file.write(@entry_list.to_numbered.join("\n"))
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
