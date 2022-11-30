# frozen_string_literal: true

module Reenrb
  module Actions
    # Deletes a file
    class ForceDelete
      def initialize(old_name, new_name)
        @old_name = old_name
        @new_name = new_name
      end

      def call
        FileUtils.rm_rf(@old_name)
        nil
      rescue Errno::ENOENT
        "Could not force delete"
      end
    end
  end
end
