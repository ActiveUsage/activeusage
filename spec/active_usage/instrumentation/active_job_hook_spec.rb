# frozen_string_literal: true

require "active_job"

ActiveJob::Base.queue_adapter = :inline
ActiveJob::Base.logger = Logger.new(IO::NULL)

class TestJob < ActiveJob::Base
  include ActiveUsage::Instrumentation::ActiveJobHooks

  def perform; end
end

RSpec.describe ActiveUsage::Instrumentation::ActiveJobHooks do
  let(:store) { instance_double(ActiveUsage::Store, flush!: nil) }

  before do
    allow(ActiveUsage).to receive(:record)
    allow(ActiveUsage).to receive(:store).and_return(store)
  end

  describe "around_perform" do
    it "records a job event after perform" do
      TestJob.perform_now

      expect(ActiveUsage).to have_received(:record).with(hash_including(type: :job))
    end

    it "records the job class name" do
      TestJob.perform_now

      expect(ActiveUsage).to have_received(:record).with(hash_including(name: "TestJob"))
    end

    it "records the queue name" do
      TestJob.perform_now

      expect(ActiveUsage).to have_received(:record).with(hash_including(tags: hash_including(queue: "default")))
    end

    it "records retry_count from executions" do
      TestJob.perform_now

      expect(ActiveUsage).to have_received(:record).with(hash_including(retry_count: 0))
    end

    it "records retry_count as 0 when job does not respond to executions" do
      job = TestJob.new
      allow(job).to receive(:respond_to?).with(:executions).and_return(false)
      allow(job).to receive(:respond_to?).and_call_original

      job.perform_now

      expect(ActiveUsage).to have_received(:record).with(hash_including(retry_count: 0))
    end

    it "records sql_queries" do
      TestJob.perform_now

      expect(ActiveUsage).to have_received(:record).with(hash_including(sql_queries: []))
    end

    it "flushes the store after recording" do
      TestJob.perform_now

      expect(ActiveUsage.store).to have_received(:flush!)
    end
  end
end
