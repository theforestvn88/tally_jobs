class NotEqualDataJob < ApplicationJob
    include TallyJobs::TallyData

    data_for_all lambda { |params| :not_equal }
    data_for_each lambda { |params| params[0..-3] }
    data_for_each lambda { |params| params }
    data_for_each lambda { |params| params[0..-2] }

    def each_do(data_all, data_each_1, data_each_2, data_each_3)
    end
end
