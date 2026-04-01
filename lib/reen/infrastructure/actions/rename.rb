# frozen_string_literal: true

module Reen
  module Actions
    # Renames files
    class Rename
      def initialize(old_name, new_name)
        @old_name = old_name
        @new_name = new_name
      end

      def call
        File.rename(@old_name, @new_name)
        nil
      rescue Errno::ENOENT
        "No such target file or directory"
      end
    end
  end
end
