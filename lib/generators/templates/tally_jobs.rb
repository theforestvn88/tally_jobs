# frozen_string_literal: true

TallyJobs.setup do |config|
    config.interval = 300 # seconds
    config.logger = Rails.logger
    # config.counter_store = YourCustomCounterStore
end
