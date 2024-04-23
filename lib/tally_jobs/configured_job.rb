# frozen_string_literal: true

module TallyJobs
    module ConfiguredJob
        def enqueue_to_tally(*params)
            TallyJobs::JobsCounter.store.enqueue(
                [self.instance_variable_get(:@job_class), self.instance_variable_get(:@options)], 
                *params
            )
        end
    end
end

# to support enqueue_to_tally preconfigured jobs
require 'active_job'
::ActiveJob::ConfiguredJob.include TallyJobs::ConfiguredJob