# frozen_string_literal: true

require_relative "lib/reen/version"

Gem::Specification.new do |spec|
  spec.name = "reen"
  spec.version = Reen::VERSION
  spec.authors = ["Soumya Ray"]
  spec.email = ["soumya.ray@gmail.com"]

  spec.summary = "Renames or deletes a pattern of files using your favorite editor"
  spec.description = "Renames or deletes a pattern of files using your favorite editor"
  spec.homepage = "https://github.com/soumyaray/reen"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables << "reen"
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
