# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "reenrb"

require "minitest/autorun"
require "minitest/rg"

SPEC_DIR = "spec/fixtures"
EXAMPLE_DIR = File.join(SPEC_DIR, "example")
EXAMPLE_ZIP = File.join(SPEC_DIR, "example.zip")
EXAMPLE_MV_DIR = File.join(SPEC_DIR, "example_old")

EXAMPLE_ALL = File.join(SPEC_DIR, "example/**/*")

def recreate_example_dir
  FileUtils.rm_rf(EXAMPLE_MV_DIR)
  FileUtils.mv(EXAMPLE_DIR, EXAMPLE_MV_DIR) if Dir.exist? EXAMPLE_DIR

  extract_zip(EXAMPLE_ZIP, SPEC_DIR)
  # Zip::File.open(EXAMPLE_ZIP) do |zipfile|
  #   zipfile.each do |entry|
  #     next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/ or !entry.file?

  #     unless File.exist?(entry.name)
  #       FileUtils::mkdir_p("spec/fixtures/" + File.dirname(entry.name))
  #       zipfile.extract(entry, "spec/fixtures/" + entry.name)
  #     end
  #   end
  # end

  FileUtils.rm_rf(EXAMPLE_MV_DIR)
end

# modified from https://stackoverflow.com/a/29653504/1725028
def extract_zip(zip_filename, base_dir)
  Zip::File.open(zip_filename) do |zipfile|
    zipfile.each do |entry|
      next if unwanted_file(entry)

      unless File.exist?(entry.name)
        FileUtils.mkdir_p(File.join(base_dir, File.dirname(entry.name)))
        zipfile.extract(entry, File.join(base_dir, entry.name))
      end
    end
  end
end

def unwanted_file(file)
  file.name =~ /__MACOSX/ || file.name =~ /\.DS_Store/ || !file.file?
end

def remove_example_dirs
  FileUtils.rm_rf(EXAMPLE_MV_DIR)
  FileUtils.rm_rf(EXAMPLE_DIR)
end
