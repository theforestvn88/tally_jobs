# frozen_string_literal: true

module TallyJobs
    class Configs
        attr_accessor :interval, :logger

        def counter_store=(store)
            JobsCounter.store = store.to_s.classify.constantize
        end
    end
end
