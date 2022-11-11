# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:spec) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList["spec/**/spec_*.rb"]
end

task :respec do
  sh "rerun -c --ignore 'spec/fixtures/*' rake spec"
end

namespace :example do
  task :helper do
    require_relative "spec/fixture_helper"
  end

  desc "Recreates the example fixture folder"
  task :recreate => :helper do
    FixtureHelper.recreate_example_dir
    puts "Example fixture recreated"
  end

  desc "Deletes the example fixture folder"
  task :remove => :helper do
    FixtureHelper.remove_example_dirs
    puts "Example fixture removed"
  end
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]
