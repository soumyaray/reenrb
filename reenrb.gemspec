# frozen_string_literal: true

require_relative "lib/reenrb/version"

Gem::Specification.new do |spec|
  spec.name = "reenrb"
  spec.version = Reenrb::VERSION
  spec.authors = ["Soumya Ray"]
  spec.email = ["soumya.ray@gmail.com"]

  spec.summary = "Renames or deletes a pattern of files using your favorite editor"
  spec.description = "Renames or deletes a pattern of files using your favorite editor"
  spec.homepage = "https://github.com/soumyaray/reenrb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables << "reen"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rubyzip", "~> 2.3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-rg", "~> 5.0"
  spec.add_development_dependency "rerun", "~> 0.13"
  spec.add_development_dependency "rubocop", "~> 1.21"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
