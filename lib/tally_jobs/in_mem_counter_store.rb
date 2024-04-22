# frozen_string_literal: true

module TallyJobs
    class InMemCounterStore
        # in-memory job queue
        JOBS_QUEUE = Thread::Queue.new
        
        class << self
            def enqueue(job_clazz, *params)
                JOBS_QUEUE.enq([job_clazz, *params])
            end

            def dequeue
                JOBS_QUEUE.deq
            end

            delegate :empty?, :clear, to: "TallyJobs::InMemCounterStore::JOBS_QUEUE"
        end
    end
end
