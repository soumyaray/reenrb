# frozen_string_literal: true

require_relative "path_entry"

module Reen
  # Collection of PathEntry objects, constructed from an array of path strings
  class PathEntryList
    include Enumerable

    def initialize(path_strings)
      @entries = path_strings.map { |p| PathEntry.new(p) }
    end

    def each(&block)
      @entries.each(&block)
    end

    def paths
      @entries.map(&:path)
    end

    def to_numbered
      width = @entries.size.to_s.length
      @entries.each_with_index.map do |entry, i|
        num = format("%0#{width}d", i + 1)
        "[#{num}] #{entry.path}"
      end
    end

    # Parses "[NN] path" lines into { number => path } hash.
    # Preserves line order (Ruby hash insertion order), so callers get editor order.
    # Silently skips lines that don't match the [NN] pattern.
    def self.from_numbered(lines)
      lines.each_with_object({}) do |line, hash|
        match = line.match(/^\[(\d+)\] (.*)/)
        next unless match

        hash[match[1].to_i] = match[2]
      end
    end
  end
end
