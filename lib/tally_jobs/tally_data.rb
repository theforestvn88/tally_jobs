# frozen_string_literal: true

module TallyJobs
    module TallyData
        def self.included(base)
            base.extend ClassMethods
            base.class_eval do
                cattr_accessor :_batch_size

                def self.batch_size(size)
                    self._batch_size = size
                end
            end
        end

        module ClassMethods
            def enqueue_to_tally(*params)
                TallyJobs::JobsCounter.store.enqueue(self, *params)
            end
        end
    end
end
