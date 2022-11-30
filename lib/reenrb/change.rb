# frozen_string_literal: true

require_relative "actions/delete"
require_relative "actions/force_delete"
require_relative "actions/rename"
require_relative "actions/nothing"

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
      FORCE_DELETE = :force_delete
      RENAME = :rename
    end

    module OBJECT
      FILE = :file
      FOLDER = :folder
    end

    ACTION_HANDLER = {
      CHANGE::NONE => Actions::DoNothing,
      CHANGE::DELETE => Actions::FileDelete,
      CHANGE::FORCE_DELETE => Actions::FileForceDelete,
      CHANGE::RENAME => Actions::FileRename
    }.freeze

    CHANGES_DESC = {
      CHANGE::NONE => "Nothing",
      CHANGE::DELETE => "Deleting",
      CHANGE::FORCE_DELETE => "Force deleting",
      CHANGE::RENAME => "Renaming"
    }.freeze

    def initialize(original, requested)
      @original = original
      extract_request(requested)
      decide_object
      decide_change
      decide_status_reason
    end

    def extract_request(str)
      op_chars = "[-]"
      obj_chars = "."
      requested = str.match(/^(?<op>#{op_chars}*)(?<name>#{obj_chars}*)/)

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

    def execute
      return(self) if not_accepted?

      @status = STATUS::EXECUTED
      error = ACTION_HANDLER[@change].new(@original, @requested).call

      if error
        @status = STATUS::FAILED
        @reason = error
      end

      self
    end

    # Predicates

    def request_dir? = Dir.exist?(@original)

    def request_file? = File.file?(@original)

    def request_nothing? = @change == CHANGE::NONE

    def request_rename? = @change == CHANGE::RENAME

    def request_delete? = @change == CHANGE::DELETE

    def request_empty_dir? = Dir.empty?(@original)

    def accepted? = @status == STATUS::ACCEPTED

    def not_accepted? = !accepted?

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
