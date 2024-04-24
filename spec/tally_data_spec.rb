# frozen_string_literal: true

RSpec.describe TallyJobs::TallyData do
    it "enqueue to tally" do
        TallyJobs::JobsCounter.store.clear

        ATallyJob.enqueue_to_tally(1)
        ATallyJob.enqueue_to_tally(2, "second")
        ATallyJob.enqueue_to_tally(3, [4,5,6])
        AnotherTallyJob.enqueue_to_tally(8)
        AnotherTallyJob.enqueue_to_tally(:x)

        expect(TallyJobs::JobsCounter.store.dequeue).to eq([ATallyJob, 1])
        expect(TallyJobs::JobsCounter.store.dequeue).to eq([ATallyJob, 2, "second"])
        expect(TallyJobs::JobsCounter.store.dequeue).to eq([ATallyJob, 3, [4,5,6]])
        expect(TallyJobs::JobsCounter.store.dequeue).to eq([AnotherTallyJob, 8])
        expect(TallyJobs::JobsCounter.store.dequeue).to eq([AnotherTallyJob, :x])
    end

    it "batch tally job should perform in-batch" do
        called_params = []
        allow(BatchTallyJob).to receive(:perform_later) do |args|
            called_params << args
        end

        TallyJobs::JobsCounter.store.clear

        (1..15).each { |i| BatchTallyJob.enqueue_to_tally(i) }

        TallyJobs::JobsCounter.collect_then_perform_later
        
        expect(called_params).to eq([
            (1..10).to_a,
            (11..15).to_a
        ])
    end

    it "enqueue variant configured jobs to tally" do
        allow(ATallyJob).to receive(:perform_later)

        TallyJobs::JobsCounter.store.clear
        ATallyJob.set(wait_until: Date.tomorrow.noon).enqueue_to_tally(1)
        ATallyJob.set(wait_until: Date.tomorrow.noon).enqueue_to_tally(2)
        ATallyJob.set(wait_until: Date.tomorrow.noon).enqueue_to_tally(3)

        configured_job = ATallyJob.set(wait_until: Date.tomorrow.noon)
        allow(configured_job).to receive(:perform_later)
        allow(ATallyJob).to receive(:set).and_return(configured_job)

        TallyJobs.flush

        expect(ATallyJob).to have_received(:set).with(wait_until: Date.tomorrow.noon).once
        expect(configured_job).to have_received(:perform_later).with([1,2,3])
    end

    it "enqueue variant configured batch jobs to tally" do
        allow(BatchTallyJob).to receive(:perform_later)

        TallyJobs::JobsCounter.store.clear
        (1..15).each { |i| BatchTallyJob.set(wait_until: Date.tomorrow.noon).enqueue_to_tally(i) }

        configured_job = BatchTallyJob.set(wait_until: Date.tomorrow.noon)
        called_params = []
        allow(configured_job).to receive(:perform_later) do |args|
            called_params << args
        end
        allow(BatchTallyJob).to receive(:set).and_return(configured_job)

        TallyJobs.flush

        expect(BatchTallyJob).to have_received(:set).with(wait_until: Date.tomorrow.noon).once
        expect(called_params).to eq([
            (1..10).to_a,
            (11..15).to_a
        ])
    end
end
