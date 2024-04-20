# frozen_string_literal: true

require 'rails/generators/base'

module TallyJobs
    module Generators
        class InstallGenerator < Rails::Generators::Base
            source_root File.expand_path("../../templates", __FILE__)

            def copy_initializer
                copy_file "tally_jobs.rb", "config/initializers/tally_jobs.rb"
            end
        end
    end
end
