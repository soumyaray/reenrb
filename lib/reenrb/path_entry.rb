# frozen_string_literal: true

module Reenrb
  # Wraps a file path and answers filesystem queries
  class PathEntry
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def file? = File.file?(@path)

    def dir? = Dir.exist?(@path)

    def empty_dir? = dir? && Dir.empty?(@path)

    def full_dir? = dir? && !Dir.empty?(@path)
  end
end
