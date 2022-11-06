# frozen_string_literal: true

module Reenrb
  # Change to an orignal file
  class Changes
    attr_reader :list

    def initialize(changes_list)
      @list = changes_list
    end

    def execute!
      @list.map(&:execute)
      self
    end

    # Queries

    def rename_requested
      Changes.new(@list.select { |c| c.change == :rename })
    end

    def delete_requested
      Changes.new(@list.select { |c| c.change == :delete })
    end

    def change_requested
      Changes.new(@list.reject { |c| c.change == :none })
    end

    def rejected
      Changes.new(@list.select { |c| c.status == :rejected })
    end

    def accepted
      Changes.new(@list.select { |c| c.status == :accepted })
    end

    def executed
      Changes.new(@list.select { |c| c.status == :executed })
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
      list.map(&:change).all? :none
    end

    def changes_requested?
      !no_changes_requested?
    end

    def all_executed?
      @list.all?(&:executed?)
    end
  end
end
