# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch
  primary_coverage :branch
end

require "rspec/sse/matchers"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Allow focused specs with 'fit', 'fdescribe', 'fcontext'
  config.filter_run_when_matching :focus

  # Run specs in random order
  config.order = :random
  Kernel.srand config.seed
end

# Mock response class for testing
class MockResponse
  attr_reader :body

  def initialize(body)
    @body = body
  end
end
