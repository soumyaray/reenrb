# frozen_string_literal: true

module Reen
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
      FORCE_DELETE = :force_delete
      RENAME = :rename
    end

    module OBJECT
      FILE = :file
      FOLDER = :folder
    end

    CHANGES_DESC = {
      CHANGE::NONE => "Nothing",
      CHANGE::DELETE => "Deleting",
      CHANGE::FORCE_DELETE => "Force deleting",
      CHANGE::RENAME => "Renaming"
    }.freeze

    def initialize(original, requested)
      @entry = original
      @original = @entry.path
      extract_request(requested)
      decide_object
      decide_change
      decide_status_reason
    end

    def extract_request(str)
      requested = str.match(/^\s*(?<op>--|-) +(?<name>.*)/) || str.match(/^(?<op>)(?<name>.*)/)

      @operator = requested[:op]
      @requested = requested[:name].strip
    end

    def decide_change
      @change =
        if @operator == "--"
          CHANGE::FORCE_DELETE
        elsif @operator == "-"
          CHANGE::DELETE
        elsif @original != @requested
          CHANGE::RENAME
        else
          CHANGE::NONE
        end
    end

    def decide_object
      @object = OBJECT::FILE if request_file?
      @object = OBJECT::FOLDER if request_dir?
    end

    def decide_status_reason
      if request_full_dir? && request_delete?
        @status = STATUS::REJECTED
        @reason = "Directories with files cannot be changed"
      else
        @status = STATUS::ACCEPTED
        @reason = ""
      end
    end

    def mark_executed
      @status = STATUS::EXECUTED
    end

    def mark_failed(reason)
      @status = STATUS::FAILED
      @reason = reason
    end

    # Predicates

    def request_dir? = @entry.dir?

    def request_file? = @entry.file?

    def request_nothing? = @change == CHANGE::NONE

    def request_rename? = @change == CHANGE::RENAME

    def request_delete? = @change == CHANGE::DELETE

    def request_empty_dir? = @entry.empty_dir?

    def accepted? = @status == STATUS::ACCEPTED

    def not_accepted? = !accepted?

    def executed? = @status == STATUS::EXECUTED

    def rejected? = @status == STATUS::REJECTED

    def failed? = @status == STATUS::FAILED

    def request_full_dir? = @entry.full_dir?

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
