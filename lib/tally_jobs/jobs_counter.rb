# frozen_string_literal: true

require_relative "./counter_store/memory_counter_store"

module TallyJobs
    class JobsCounter
        cattr_accessor :store, default: TallyJobs::CounterStore::MemoryCounterStore.new

        def self.collect_then_perform_later
            groups = Hash.new { |h, k| h[k] = [] }
            until store.empty?
                job_clazz, *params = store.dequeue
                groups[job_clazz] << (params.size == 1 ? params[0] : params)
            end

            groups.each do |job_clazz, params_list|
                job_clazz.perform_later(params_list)
            end
        end
    end
end
