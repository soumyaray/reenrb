# frozen_string_literal: true

module Reenrb
  # Change to an orignal file
  class Change
    attr_reader :original, :requested, :change, :status

    module STATUS
      ACCEPTED = :accepted
      REJECTED = :rejected
      EXECUTED = :executed
    end

    module CHANGE
      NONE = :none
      DELETE = :delete
      RENAME = :rename
    end

    CHANGES_DESC = {
      none: "Nothing",
      delete: "Deleting",
      rename: "Renaming"
    }.freeze

    def initialize(original, requested)
      @original = original
      @requested = requested
      @change = compare
      consider
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
      if request_full_directory? && request_delete?
        @status = STATUS::REJECTED
        @reason = "Directories with files cannot be changed"
      else
        @status = STATUS::ACCEPTED
      end
    end

    def execute
      return(self) if executed_or_rejected?

      case @change
      when :rename
        File.rename(@original, @requested)
      when :delete
        File.delete(@original)
      end

      @status = STATUS::EXECUTED
      self
    end

    # Predicates

    def request_directory?
      Dir.exist? @original
    end

    def request_delete?
      @change == CHANGE::DELETE
    end

    def request_empty_directory?
      Dir.empty? @original
    end

    def executed?
      @status == STATUS::EXECUTED
    end

    def request_full_directory?
      request_directory? && !request_empty_directory?
    end

    def executed_or_rejected?
      %i[executed rejected].include? @status
    end

    # Decoration

    def to_s
      file_desc =
        case @change
        when :rename
          "#{@original} -> #{@requested}"
        else
          @original
        end

      reason_desc = @status == STATUS::REJECTED ? " (failed: #{@reason})" : ""

      "#{CHANGES_DESC[@change]}: #{file_desc}#{reason_desc}"
    end
  end
end
