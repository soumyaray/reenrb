# frozen_string_literal: true

require "tempfile"

module Reenrb
  # Manages a temporary file with requested changes
  class ChangesFile
    def initialize(requested_list)
      @list_file = Tempfile.new("reenrb-")
      @list_file.write(requested_list.join("\n"))
      @list_file.close
    end

    def path
      @list_file.path
    end

    def allow_changes(&block)
      block.call(self)
      File.read(path).split("\n")
    end

    def blocking_edit(editor)
      `#{editor} #{@list_file.path}`
    end
  end
end
