# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:spec) do |t|
  t.libs << "tspecest"
  t.libs << "lib"
  t.test_files = FileList["spec/**/spec_*.rb"]
end

task :respec do
  sh "rerun -c --ignore 'spec/fixtures/*' rake spec"
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]
