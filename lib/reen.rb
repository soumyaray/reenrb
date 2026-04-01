# frozen_string_literal: true

require_relative "reen/version"
require_relative "reen/domain/path_entry"
require_relative "reen/domain/path_entry_list"
require_relative "reen/domain/change"
require_relative "reen/domain/changes"
require_relative "reen/infrastructure/changes_file"
require_relative "reen/services/reen"

module Reen
  class Error < StandardError; end
end
