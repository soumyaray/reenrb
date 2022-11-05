# frozen_string_literal: true

module Reenrb
  # Change to an orignal file
  class Change
    attr_reader :original, :requested, :change, :status

    CHANGES = {
      none: "Nothing",
      delete: "Deleted",
      rename: "Renamed"
    }.freeze

    def initialize(original, requested)
      @original = original
      @requested = requested
      @change = compare
      @status = consider
    end

    def compare
      if original == requested
        :none
      elsif requested.start_with? "-"
        :delete
      else
        :rename
      end
    end

    def consider
      if File.directory? @original
        @status = :rejected
        @reason = "Directories cannot be changed"
      else
        @status = :accepted
      end
    end

    def execute
      return(self) if [:executed, :rejected].include? @status

      case @change
      when :rename
        File.rename(@original, @requested)
      when :delete
        File.delete(@original)
      end

      @status = :executed
      self
    end

    def to_s
      file_desc =
        case @change
        when :rename
          "#{@original} -> #{@requested}"
        else
          @original
        end
      "#{CHANGES[@change]}: #{file_desc}"
    end
  end
end
