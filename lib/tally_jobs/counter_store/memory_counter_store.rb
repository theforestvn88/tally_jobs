# frozen_string_literal: true

require_relative "../counter_store.rb"

module TallyJobs::CounterStore
    class MemoryCounterStore < Base
        # in-memory job queue
        JOBS_QUEUE = Thread::Queue.new
        
        def enqueue(job_clazz, *params)
            JOBS_QUEUE.enq([job_clazz, *params])
        end

        def dequeue(n = 1)
            JOBS_QUEUE.deq
        end

        delegate :empty?, :clear, to: "TallyJobs::CounterStore::MemoryCounterStore::JOBS_QUEUE"
    end
end
