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
                batch_size = nil

                if job_clazz.is_a? Array
                    job_clazz, options = *job_clazz
                    batch_size = job_clazz._batch_size
                    job_clazz = job_clazz.set(**options)
                else
                    batch_size = job_clazz._batch_size
                end

                next if job_clazz.nil?

                if batch_size.nil?
                    job_clazz.perform_later(params_list)
                else
                    params_list.each_slice(batch_size).each do |slice_params|
                        job_clazz.perform_later(slice_params)
                    end
                end
            end
        end
    end
end
