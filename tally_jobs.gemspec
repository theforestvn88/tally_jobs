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

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "railties"

  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-rails'
end
