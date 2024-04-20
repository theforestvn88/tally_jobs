# frozen_string_literal: true

module TallyJobs
    module TallyData
        def self.included(base)
            base.extend ClassMethods
            base.class_eval do
                cattr_reader :data_for_all_tasks, default: []
                cattr_reader :data_for_each_tasks, default: []

                def self.data_for_all(block)
                    self.data_for_all_tasks << block
                end
            
                def self.data_for_each(block)
                    self.data_for_each_tasks << block
                end
            end
        end

        module ClassMethods
            def enqueue_to_tally(*params)
                TallyJobs.enqueue(self, *params)
            end
        end

        def each_do(*data)
        end
    
        def perform(*args)
            data_for_all = data_for_all_tasks.map { |q| q.call(*args) }
            datas = data_for_each_tasks.map { |q| q.call(*args) }.inject(&:zip)
            datas.each { |data| each_do(*data_for_all, *data) }
        end
    end
end
