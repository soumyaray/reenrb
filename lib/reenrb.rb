# frozen_string_literal: true

require_relative "reenrb/version"

module Reenrb
  class Error < StandardError; end

  # Renames pattern of files with given editor
  class Reen
    DEL_ERROR = "Do not delete any file/folder names"

    attr_reader :changes

    def initialize(editor: "emacs", options: {})
      @editor = editor
      @options = options
    end

    def open_editor(file_path)
      `#{@editor} #{file_path}`
    end

    def call(pattern) # rubocop:disable Metrics/AbcSize
      requested_list = Dir.glob(pattern)
      list_file = Tempfile.new("#{self.class.name}-")
      list_file.write(requested_list.join("\n"))
      list_file.close
      tmpfile_path = list_file.path

      @options[:mock_editor] ? yield(tmpfile_path) : open_editor(tmpfile_path)

      revised_list = File.read(tmpfile_path).split("\n")

      raise(Error, DEL_ERROR) if revised_list.size != requested_list.size

      changes(requested_list, revised_list).tap do
        list_file.unlink
      end
    end

    def changes(requested_list, revised_list)
      requested_list.zip(revised_list).map do |original, revised|
        Change.new(original, revised)
      end
    end
  end

  # Change to an orignal file
  class Change
    attr_reader :original, :revised, :change

    CHANGES = {
      none: "Nothing",
      delete: "Deleted",
      rename: "Renamed"
    }.freeze

    def initialize(original, revised)
      @original = original
      @revised = revised
      @change =
        if original == revised
          :none
        elsif revised.start_with? "-"
          :delete
        else
          :rename
        end
    end

    def to_s
      file_desc =
        case @change
        when :rename
          "#{@original} -> #{@revised}"
        else
          @original
        end
      "#{CHANGES[@change]}: #{file_desc}"
    end
  end
end
