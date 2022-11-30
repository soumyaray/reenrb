# frozen_string_literal: true

module Reenrb
  module Actions
    # Deletes a file
    class Delete
      def initialize(old_name, new_name)
        @old_name = old_name
        @new_name = new_name
      end

      def call
        File.delete(@old_name)
        nil
      rescue Errno::ENOENT
        "Could not delete"
      end
    end
  end
end
