# frozen_string_literal: true

require_relative "change"

module Reenrb
  # Change to an orignal file
  class Changes
    attr_reader :list

    def initialize(changes_list)
      @list = changes_list
    end

    def execute_all
      @list.map(&:execute)
      self
    end

    # Queries

    def rename_requested
      Changes.new(@list.select(&:request_rename?))
    end

    def delete_requested
      Changes.new(@list.select(&:request_delete?))
    end

    def change_requested
      Changes.new(@list.reject(&:request_nothing?))
    end

    def rejected
      Changes.new(@list.select(&:rejected?))
    end

    def accepted
      Changes.new(@list.select(&:accepted?))
    end

    def executed
      Changes.new(@list.select(&:executed?))
    end

    def failed
      Changes.new(@list.select(&:failed?))
    end

    def any?
      !@list.empty?
    end

    def count
      @list.size
    end

    # Decoration

    def summarize
      return "Nothing changed" if @list.empty?

      @list.map(&:to_s).join("\n")
    end

    # Predicates

    def no_changes_requested?
      list.map(&:change).all? Change::CHANGE::NONE
    end

    def changes_requested?
      !no_changes_requested?
    end

    def all_executed?
      @list.all?(&:executed?)
    end
  end
end
