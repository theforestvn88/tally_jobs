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

    class AnotherJob
        include TallyJobs::TallyData

        data_for_all lambda { |params| -100 }
        data_for_each lambda { |params| params.map { |p| p.class } }
        data_for_each lambda { |params| params.map { |p| p } }

        def each_do(data_all, data_each_1, data_each_2)
        end

        def self.perform_later(args)
        end
    end

    it "enqueue to tally" do
        TallyJobs::JOBS_QUEUE.clear

        AJob.enqueue_to_tally(1)
        AJob.enqueue_to_tally(2, "second")
        AJob.enqueue_to_tally(3, [4,5,6])
        AnotherJob.enqueue_to_tally(8)
        AnotherJob.enqueue_to_tally(:x)

        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AJob, 1])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AJob, 2, "second"])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AJob, 3, [4,5,6]])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AnotherJob, 8])
        expect(TallyJobs::JOBS_QUEUE.deq).to eq([AnotherJob, :x])
    end

    it "should perform with prepared data" do
        called_params = []

        allow_any_instance_of(AJob).to receive(:each_do) do |job, *args|
            called_params << [job.class, *args]
        end

        allow_any_instance_of(AnotherJob).to receive(:each_do) do |job, *args|
            called_params << [job.class, *args]
        end

        TallyJobs::JOBS_QUEUE.clear

        AJob.new.perform([1, [2, 3], :x])
        AnotherJob.new.perform([1, [2, 3], :x])

        expect(called_params).to eq([
            [AJob, 100, "Integer", "1"], [AJob, 100, "Array", "[2, 3]"], [AJob, 100, "Symbol", "x"],
            [AnotherJob, -100, Integer, 1], [AnotherJob, -100, Array, [2, 3]], [AnotherJob, -100, Symbol, :x]
        ])
    end
end
