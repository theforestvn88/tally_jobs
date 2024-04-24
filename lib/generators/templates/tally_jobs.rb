# frozen_string_literal: true

TallyJobs.setup do |config|
    config.interval = 120 # seconds
    config.logger = Rails.logger
    # config.counter_store = :memory_counter_store
    config.counter_store = { store: :redis_counter_store, redis: Redis.new(host: "localhost") } if Rails.env.production?
end
