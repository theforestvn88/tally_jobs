# frozen_string_literal: true

require_relative "lib/tally_jobs/version"

Gem::Specification.new do |spec|
  spec.name = "tally_jobs"
  spec.version = TallyJobs::VERSION
  spec.authors = ["theforestvn88"]
  spec.email = ["theforestvn88@gmail.com"]

  spec.summary = "Collect all same jobs in an interval time then execute them only one time"
  spec.description = "Collect all same jobs in an interval time then execute them only one time"
  spec.homepage = "https://github.com/theforestvn88/tally_jobs.git"
  spec.required_ruby_version = ">= 1.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/theforestvn88/tally_jobs.git"
  spec.metadata["changelog_uri"] = "https://github.com/theforestvn88/tally_jobs.git"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-rails'
end
