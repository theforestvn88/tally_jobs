# frozen_string_literal: true

require_relative "tally_jobs/version"
require_relative "tally_jobs/engine"
require_relative "tally_jobs/configs"
require_relative "tally_jobs/jobs_counter"
require_relative "tally_jobs/tally_data"

module TallyJobs
  class Error < StandardError; end

  mattr_accessor :runnable, default: true
  mattr_reader :configs, default: TallyJobs::Configs.new
  class << self
    def setup
      yield configs
      
      TallyJobs.start
    end
  end

  module_function
  
  # start a thread to flush in-memory enqueued jobs
  # each {interval} time
  MUTEX = Mutex.new
  def start
    MUTEX.synchronize do
      @tally_thread = nil if !@tally_thread&.alive?

      @tally_thread ||= Thread.new do
        TallyJobs.configs.logger&.info("[TallyJobs] started ...")
        while true
          break unless TallyJobs.runnable
          sleep(TallyJobs.configs.interval || 300)

          JobsCounter.collect_then_perform_later
        end
      end
    end
  end

  def flush
    TallyJobs.configs.logger&.info("[TallyJobs] flushing ...")
    JobsCounter.collect_then_perform_later
  end

  def stop
    flush

    TallyJobs.runnable = false
    if @tally_thread && @tally_thread.alive?
      @tally_thread.wakeup
      @tally_thread.join
    end
    TallyJobs.configs.logger&.info("[TallyJobs] stop ...")
  end

  def restart
    stop
    TallyJobs.runnable = true
    start
  end

  # force flush all in-memory enqueued jobs before exit
  at_exit do
    TallyJobs.stop
  end
end
