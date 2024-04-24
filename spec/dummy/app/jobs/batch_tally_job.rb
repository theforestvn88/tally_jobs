class BatchTallyJob < ApplicationJob
    include TallyJobs::TallyData
    batch_size 10
end
