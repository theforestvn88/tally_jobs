# frozen_string_literal: true

require_relative "./counter_store/memory_counter_store"
require_relative "./counter_store/redis_counter_store"

module TallyJobs
    class Configs
        attr_accessor :interval, :logger, :redis

        def redis=(_redis)
            redis = _redis
        end

        def counter_store=(store)
            JobsCounter.store = \
                case store
                when :memory_counter_store
                    TallyJobs::CounterStore::MemoryCounterStore.new
                when Hash
                    case store[:store]
                    when :redis_counter_store
                        TallyJobs::CounterStore::RedisCounterStore.new(**store.except(:store))
                    else
                        store.delete(:store).to_s.classify.constantize.new(**store)
                    end
                else
                    store.to_s.classify.constantize.new
                end
        end
    end
end
