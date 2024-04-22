# frozen_string_literal: true

require_relative "../counter_store.rb"

module TallyJobs::CounterStore
    class RedisCounterStore < Base
        attr_reader :redis

        def initialize(redis:)
            @redis = redis
        end

        def enqueue(job_clazz, *params)
            @redis.rpush(KEY, Marshal.dump([job_clazz, *params]))
        end

        def dequeue(n = 1)
            Marshal.load(@redis.lpop(KEY))
        end

        def empty?
            @redis.llen(KEY).zero?
        end

        def clear
            @redis.del(KEY)
        end

        private
            
            KEY = "tally-jobs-queue".freeze
    end
end
