# frozen_string_literal: true

RSpec.describe TallyJobs::JobsCounter do
    let(:queue) { Thread::Queue.new }

    before do
        queue.enq [ATallyJob, 1]
        queue.enq [AnotherTallyJob, "test1", Time.now.beginning_of_day]
        queue.enq [ATallyJob, 2]
        queue.enq [ATallyJob, 3]
        queue.enq [AnotherTallyJob, "test2", Time.now.end_of_day]
    end

    it "grouping jobs from jobs-queue" do
        expect(TallyJobs::JobsCounter.collect_then_perform_later(queue)).to eq({
            ATallyJob => [1, 2, 3],
            AnotherTallyJob => [["test1", Time.now.beginning_of_day], ["test2", Time.now.end_of_day]]
        })
    end

    it "perform_later jobs after grouping from queue" do
        allow(ATallyJob).to receive(:perform_later)
        allow(AnotherTallyJob).to receive(:perform_later)

        TallyJobs::JobsCounter.collect_then_perform_later(queue)

        expect(ATallyJob).to have_received(:perform_later).with([1,2,3])
        expect(AnotherTallyJob).to have_received(:perform_later).with([["test1", Time.now.beginning_of_day], ["test2", Time.now.end_of_day]])
    end
end
