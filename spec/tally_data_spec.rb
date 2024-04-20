# frozen_string_literal: true

RSpec.describe TallyJobs::TallyData do
    class AJob
        include TallyJobs::TallyData

        data_for_all lambda { |params| 100 }
        data_for_each lambda { |params| params.map { |p| p.class.name } }
        data_for_each lambda { |params| params.map { |p| p.to_s } }

        def each_do(data_all, data_each_1, data_each_2)
        end

        def self.perform_later(args)
        end
    end

    it "enqueue to tally" do
        AJob.enqueue_to_tally(1)
        AJob.enqueue_to_tally(2, "second")
        AJob.enqueue_to_tally(3, [4,5,6])

        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AJob, [1]])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AJob, [2, "second"]])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AJob, [3, [4,5,6]]])
    end

    it "should perform with prepared data" do
        called_params = []
        allow_any_instance_of(AJob).to receive(:each_do) do |_, *args|
            called_params << args
        end

        job = AJob.new
        job.perform([1, [2, 3], :x])

        expect(called_params).to eq([[100, "Integer", "1"], [100, "Array", "[2, 3]"], [100, "Symbol", "x"]])
    end
end
