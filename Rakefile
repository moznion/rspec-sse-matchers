# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard]

namespace :rbs do
  task gen: %i[] do
    sh "rbs-inline --output --opt-out lib"
  end
end
