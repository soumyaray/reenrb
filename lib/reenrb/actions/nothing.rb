# frozen_string_literal: true

module Reenrb
  module Actions
    # Does nothing to items
    class DoNothing
      def initialize(old_name, new_name)
        @old_name = old_name
        @new_name = new_name
      end

      def call
        nil
      end
    end
  end
end
