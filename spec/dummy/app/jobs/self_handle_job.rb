class SelfHandleJob < ApplicationJob
    include TallyJobs::TallyData

    def perform(*args)
    end
end
