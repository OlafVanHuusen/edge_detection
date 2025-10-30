# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new

# RuboCop task for CI - only autocorrectable offenses
RuboCop::RakeTask.new('rubocop:autocorrect_only') do |task|
  task.options = ['--display-only-correctable']
end

task default: %i[spec rubocop]
task ci: %i[spec rubocop:autocorrect_only]
