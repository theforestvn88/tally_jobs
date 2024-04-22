# frozen_string_literal: true

RSpec.describe TallyJobs::JobsCounter do
    before do
        TallyJobs::JobsCounter.store.clear
        TallyJobs::JobsCounter.store.enqueue ATallyJob, 1
        TallyJobs::JobsCounter.store.enqueue AnotherTallyJob, "test1", Time.now.beginning_of_day
        TallyJobs::JobsCounter.store.enqueue ATallyJob, 2
        TallyJobs::JobsCounter.store.enqueue ATallyJob, 3
        TallyJobs::JobsCounter.store.enqueue AnotherTallyJob, "test2", Time.now.end_of_day
    end

    it "grouping jobs from jobs-queue" do
        expect(TallyJobs::JobsCounter.collect_then_perform_later).to eq({
            ATallyJob => [1, 2, 3],
            AnotherTallyJob => [["test1", Time.now.beginning_of_day], ["test2", Time.now.end_of_day]]
        })
    end

    it "perform_later jobs after grouping from queue" do
        allow(ATallyJob).to receive(:perform_later)
        allow(AnotherTallyJob).to receive(:perform_later)

        TallyJobs::JobsCounter.collect_then_perform_later

        expect(ATallyJob).to have_received(:perform_later).with([1,2,3])
        expect(AnotherTallyJob).to have_received(:perform_later).with([["test1", Time.now.beginning_of_day], ["test2", Time.now.end_of_day]])
    end
end
