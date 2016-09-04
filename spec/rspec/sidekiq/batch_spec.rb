require 'spec_helper'

RSpec.describe 'Batch' do
  module Sidekiq
    module Batch
      class Status
      end
    end
  end

  load File.expand_path(File.join(File.dirname(__FILE__), '../../../lib/rspec/sidekiq/batch.rb'))

  describe 'NullStatus', stub_batches: true do
    describe '#total' do
      it 'returns 0 when no jobs' do
        null_status = Sidekiq::Batch.new.status
        expect(null_status.total).to eq(0)
      end

      it 'returns 1 when 1 job' do
        batch = Sidekiq::Batch.new

        batch.jobs do
          TestWorker.perform_async('5')
        end

        null_status = batch.status

        expect(null_status.total).to eq(1)
      end
    end

    describe '#bid' do
      it 'returns a bid' do
        null_status = Sidekiq::Batch.new
        expect(null_status.bid).to_not be_nil
      end
    end
  end
end
