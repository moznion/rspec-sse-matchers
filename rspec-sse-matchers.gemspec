# frozen_string_literal: true

require_relative "lib/rspec/sse/matchers/version"

Gem::Specification.new do |spec|
  spec.name = "rspec-sse-matchers"
  spec.version = RSpec::SSE::Matchers::VERSION
  spec.authors = ["moznion"]
  spec.email = ["moznion@mail.moznion.net"]

  spec.summary = "RSpec matchers for Server-Sent Events (SSE)"
  spec.description = "A collection of RSpec matchers for testing Server-Sent Events (SSE) responses"
  spec.homepage = "https://github.com/moznion/rspec-sse-matchers"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/moznion/rspec-sse-matchers"
  spec.metadata["changelog_uri"] = "https://github.com/moznion/rspec-sse-matchers/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "event_stream_parser", "~> 1.0.0"
end
