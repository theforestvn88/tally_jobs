# frozen_string_literal: true

require_relative "tally_jobs/version"
require_relative "tally_jobs/configs"
require_relative "tally_jobs/jobs_counter"
require_relative "tally_jobs/tally_data"

module TallyJobs
  class Error < StandardError; end

  mattr_reader :configs, :default => TallyJobs::Configs.new
  class << self
    def setup
      yield configs
      
      TallyJobs.start
    end
  end

  module_function

  # in-memory job queue
  JOBS_QUEUE = Thread::Queue.new
  def enqueue(job_clazz, *params)
    JOBS_QUEUE.enq([job_clazz, params])
  end
  
  # start a thread to flush in-memory enqueued jobs
  # each {interval} time
  MUTEX = Mutex.new
  def start
    MUTEX.synchronize do
      @tally_thread ||= Thread.new do
        p "start tally-jobs ..."
        while true
          sleep(TallyJobs.configs.interval || 300)

          JobsCounter.collect_then_perform_later(JOBS_QUEUE)
        end
      end
    end
  end

  # force flush all in-memory enqueued jobs before exit
  at_exit do
    JobsCounter.collect_then_perform_later(JOBS_QUEUE)
  end
end
