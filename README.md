# TallyJobs

Collect all params of the same jobs within an interval time then enqueue that job only one time.

## Installation

```ruby
gem "tally_jobs"

$ bundle install
$ rails g tally_jobs:install
```

## Usage

Assume that you have a job like this
```ruby
class ReportSpamCommentJob < ApplicationJob
    queue_as :default

    def perform(comment_id)
        comment = Comment.find(comment_id)
        Report.report_spam_comment(comment) if SpamDetective.check_spam(comment)
    end
end

class CommentController < ApplicationController
    # ...
    def create
        # ...
        ReportSpamCommentJob.perform_later(comment.id)
        # ...
    end

    def update
        # ...
        ReportSpamCommentJob.perform_later(comment.id)
        # ...
    end
    # ...
end
```

In a peak time, a lot of comments are created and so a lot of jobs are enqueued. 
If we gather all comment ids within a small interval time then enqueue only one job for them, so what we need is just one read query to fetch all comments, and one write query to report all spam comments.

`tally_jobs` gem help you to do that:

```ruby
class CommentController < ApplicationController
    # ...
    def create
        # ...
        ReportSpamCommentJob.enqueue_to_tally(comment.id)
        # ...
    end
    # ...
end

class ReportSpamCommentJob < ApplicationJob
    queue_as :default

    include TallyJobs::TallyData

    def perform(*comment_ids)
        comments = Comment.where(id: comment_ids) # one read query
        if spams = SpamDetective.check_spams(comments)
            Report.report_spam_comments(spams) # one write query
        end
    end
end
```

The basic idea: 

- you call `YouJob#enqueue_to_tally` to enqueue your job to a jobs-queue (in development, it is a `Thread::Queue`, in production it is `Redis List`).

- `tally_jobs` will start a counter thread which, every interval time, will pop enqueued jobs, collect params list group by ActiveJob/ConfiguredJob class, then enqueue each job with its params collection.


## Notes

- `ActiveJob::ConfiguredJob` is counted separately from `ActiveJob`, `ActiveJob::ConfiguredJob` is counted on a pair [job class, configured options].
```ruby
    ReportSpamCommentJob.enqueue_to_tally(1)
    ReportSpamCommentJob.enqueue_to_tally(2)
    ReportSpamCommentJob.set(wait_until: Date.tomorrow.noon).enqueue_to_tally(3)
    ReportSpamCommentJob.set(wait_until: Date.tomorrow.noon).enqueue_to_tally(4)
    # => enqueue 2 tally job
    #
    # one for ReportSpamCommentJob
    # with [1,2]
    #
    # and one for [@job_class=ReportSpamCommentJob,
    #              @options={:wait_until=>Thu, 25 Apr 2024 12:00:00.000000000 UTC +00:00}]
    # with [3,4]
    #
```

- support perform in-batch

```ruby
class ReportSpamCommentJob < ApplicationJob
    queue_as :default

    include TallyJobs::TallyData

    batch_size 100

    def perform(one_hundred_comment_ids)
    end
end
```

- call `TallyJobs#stop` to stop counter thread, call `TallyJobs#restart` to restart counter thread
- in tests, just stop counter thread before all test cases, if you want to test job enqueued, you could start/flush/stop counter thread on each test case:
    
    ```ruby
    expect {
        TallyJobs.restart
            
        ReportSpamCommentJob.enqueue_to_tally(3)
        ReportSpamCommentJob.enqueue_to_tally(4)
        ReportSpamCommentJob.enqueue_to_tally(5)
        TallyJobs.flush # force collect and enqueue jobs
        # expect ...
        
        TallyJobs.stop # this is also call flush
    }.to have_enqueued_job(ReportSpamCommentJob).with([3,4,5])
    ```

## Todo

- handling back pressure
- support multiple tally jobs queues base on ActiveJob `queue_as`, set `interval-time` for each queue base on it's priority (higher priority, smaller interval time)
- support ActionMailer ???


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tally_jobs.
