# frozen_string_literal: true

RSpec.describe TallyJobs::CounterStore::RedisCounterStore do
    let(:redis) { Redis.new(host: "localhost") }
    let(:key) { TallyJobs::CounterStore::RedisCounterStore::KEY }
    subject { TallyJobs::CounterStore::RedisCounterStore.new(redis: redis) }

    it "enqueue data serialize" do
        redis.del(key)
        subject.enqueue(ATallyJob, 1)
        expect(Marshal.load(redis.lpop(key))).to eq([ATallyJob, 1])
    end

    it "dequeue data desericalize" do
        redis.del(key)
        subject.enqueue(ATallyJob, 2)
        expect(subject.dequeue).to eq([ATallyJob, 2])
    end

    it "support empty?" do
        redis.del(key)

        subject.enqueue(ATallyJob, 3)
        subject.enqueue(ATallyJob, 4)

        expect(subject.empty?).to be_falsy

        subject.dequeue
        expect(subject.empty?).to be_falsy

        subject.dequeue
        expect(subject.empty?).to be_truthy
    end
end
