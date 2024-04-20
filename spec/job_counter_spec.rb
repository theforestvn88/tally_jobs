# frozen_string_literal: true

RSpec.describe TallyJobs::JobsCounter do
    class Job1
        def self.perform_later(params_list)
        end
    end
    
    class Job2
        def self.perform_later(params_list)
        end
    end

    let(:queue) { Thread::Queue.new }

    before do
        queue.enq [Job1, 1]
        queue.enq [Job2, "test1", Time.now.beginning_of_day]
        queue.enq [Job1, 2]
        queue.enq [Job1, 3]
        queue.enq [Job2, "test2", Time.now.end_of_day]
    end

    it "grouping jobs from jobs-queue" do
        expect(TallyJobs::JobsCounter.collect_then_perform_later(queue)).to eq({
            Job1 => [1, 2, 3],
            Job2 => [["test1", Time.now.beginning_of_day], ["test2", Time.now.end_of_day]]
        })
    end

    it "perform_later jobs after grouping from queue" do
        allow(Job1).to receive(:perform_later)
        allow(Job2).to receive(:perform_later)

        TallyJobs::JobsCounter.collect_then_perform_later(queue)

        expect(Job1).to have_received(:perform_later).with([1,2,3])
        expect(Job2).to have_received(:perform_later).with([["test1", Time.now.beginning_of_day], ["test2", Time.now.end_of_day]])
    end
end
