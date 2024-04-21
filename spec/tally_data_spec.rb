# frozen_string_literal: true

RSpec.describe TallyJobs::TallyData do
    it "enqueue to tally" do
        TallyJobs::JOBS_QUEUE.clear

        ATallyJob.enqueue_to_tally(1)
        ATallyJob.enqueue_to_tally(2, "second")
        ATallyJob.enqueue_to_tally(3, [4,5,6])
        AnotherTallyJob.enqueue_to_tally(8)
        AnotherTallyJob.enqueue_to_tally(:x)

        expect(TallyJobs::JOBS_QUEUE.deq).to eq([ATallyJob, 1])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([ATallyJob, 2, "second"])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([ATallyJob, 3, [4,5,6]])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AnotherTallyJob, 8])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AnotherTallyJob, :x])
    end

    it "should perform with prepared data" do
        called_params = []

        allow_any_instance_of(ATallyJob).to receive(:each_do) do |job, *args|
            called_params << [job.class, *args]
        end

        allow_any_instance_of(AnotherTallyJob).to receive(:each_do) do |job, *args|
            called_params << [job.class, *args]
        end

        TallyJobs::JOBS_QUEUE.clear

        ATallyJob.new.perform([1, [2, 3], :x])
        AnotherTallyJob.new.perform([1, [2, 3], :x])

        expect(called_params).to eq([
            [ATallyJob, 100, "Integer", "1"], [ATallyJob, 100, "Array", "[2, 3]"], [ATallyJob, 100, "Symbol", "x"],
            [AnotherTallyJob, -100, Integer, 1], [AnotherTallyJob, -100, Array, [2, 3]], [AnotherTallyJob, -100, Symbol, :x]
        ])
    end

    it "should called with orderd data_for_each and should auto fill nil for shorter data" do
        called_params = []

        allow_any_instance_of(NotEqualDataJob).to receive(:each_do) do |job, *args|
            called_params << [job.class, *args]
        end
        
        TallyJobs::JOBS_QUEUE.clear
        NotEqualDataJob.new.perform([1,2,3])

        expect(called_params).to eq([
            [NotEqualDataJob, :not_equal, 1, 1, 1], 
            [NotEqualDataJob, :not_equal, nil, 2, 2],
            [NotEqualDataJob, :not_equal, nil, 3, nil]
        ])
    end

    it "self-handle job should not call each_do" do
        subject = SelfHandleJob.new
        allow(subject).to receive(:each_do)

        TallyJobs::JOBS_QUEUE.clear
        subject.perform([1,2,3])

        expect(subject).not_to have_received(:each_do)
    end
end
