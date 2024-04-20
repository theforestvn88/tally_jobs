class AnotherTallyJob < ApplicationJob
    include TallyJobs::TallyData

    data_for_all lambda { |params| -100 }
    data_for_each lambda { |params| params.map { |p| p.class } }
    data_for_each lambda { |params| params }

    def each_do(data_all, data_each_1, data_each_2)
    end
end
