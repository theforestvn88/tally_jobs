# frozen_string_literal: true

RSpec.describe "Counter Thread" do
    let(:called_params) { [] }

    before do
        TallyJobs.stop
        TallyJobs.configs.interval = 1 # seconds
        TallyJobs::JobsCounter.store.clear
        
        allow(ATallyJob).to receive(:perform_later) do |args|
            called_params << args
        end
    end

    it "should collect jobs when the counter thread started" do
        TallyJobs.restart
            ATallyJob.enqueue_to_tally(3)
            ATallyJob.enqueue_to_tally(4)
            ATallyJob.enqueue_to_tally(5)
            sleep 2
        TallyJobs.stop

        expect(called_params).to eq([[3, 4, 5]])
        called_params.clear

        ATallyJob.enqueue_to_tally(6)
        ATallyJob.enqueue_to_tally(7)
        ATallyJob.enqueue_to_tally(8)
        sleep 2

        expect(called_params).to eq([])

        TallyJobs.restart
            sleep 1
        TallyJobs.stop

        expect(called_params).to eq([[6,7,8]])
    end
end
