# frozen_string_literal: true

module TallyJobs
    class JobsCounter
        def self.collect_then_perform_later(queue)
            groups = Hash.new { |h, k| h[k] = [] }
            until queue.empty?
                job_clazz, *params = queue.deq
                groups[job_clazz] << (params.size == 1 ? params[0] : params)
            end

            groups.each do |job_clazz, params_list|
                job_clazz.perform_later(params_list)
            end
        end
    end
end
