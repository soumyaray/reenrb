# frozen_string_literal: true

module Reenrb
  # Change to an orignal file
  class Change
    attr_reader :original, :requested, :change, :status

    module STATUS
      ACCEPTED = :accepted
      REJECTED = :rejected
      EXECUTED = :executed
      FAILED   = :failed
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
        CHANGE::NONE
      elsif requested.start_with? "-"
        CHANGE::DELETE
      else
        CHANGE::RENAME
      end
    end

    def consider
      if request_full_dir? && request_delete?
        @status = STATUS::REJECTED
        @reason = "Directories with files cannot be changed"
      else
        @status = STATUS::ACCEPTED
      end
    end

    def execute
      return(self) if executed_or_rejected?

      @status = STATUS::EXECUTED

      case @change
      when CHANGE::RENAME
        begin
          File.rename(@original, @requested)
        rescue Errno::ENOENT
          @status = STATUS::FAILED
          @reason = "No such target file or directory"
        end
      when CHANGE::DELETE
        File.delete(@original)
      end

      self
    end

    # Predicates

    def request_dir? = Dir.exist?(@original)

    def request_nothing? = @change == CHANGE::NONE

    def request_rename? = @change == CHANGE::RENAME

    def request_delete? = @change == CHANGE::DELETE

    def request_empty_dir? = Dir.empty?(@original)

    def accepted? = @status == STATUS::ACCEPTED

    def executed? = @status == STATUS::EXECUTED

    def rejected? = @status == STATUS::REJECTED

    def failed? = @status == STATUS::FAILED

    def request_full_dir? = request_dir? && !request_empty_dir?

    def executed_or_rejected? = %i[executed rejected].include?(@status)

    # Decoration

    def to_s
      file_desc =
        case @change
        when CHANGE::RENAME
          "#{@original} -> #{@requested}"
        else
          @original
        end

      reason_desc = rejected? || failed? ? " (failed: #{@reason})" : ""

      "#{CHANGES_DESC[@change]}: #{file_desc}#{reason_desc}"
    end
  end
end
