# frozen_string_literal: true

module Reenrb
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
