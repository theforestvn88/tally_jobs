# frozen_string_literal: true

module TallyJobs::CounterStore
    class Base
        def enqueue(job_clazz, *params)
        end

        def dequeue(n = 1)
        end

        def empty?
        end

        def clear
        end
    end
end
