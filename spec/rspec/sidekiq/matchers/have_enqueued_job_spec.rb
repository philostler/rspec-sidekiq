# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::HaveEnqueuedJob do
  let(:tomorrow) { DateTime.now + 1 }
  let(:interval) { 3.minutes }
  let(:argument_subject) { RSpec::Sidekiq::Matchers::HaveEnqueuedJob.new worker_args }
  let(:matcher_subject) { RSpec::Sidekiq::Matchers::HaveEnqueuedJob.new [be_a(String), be_a(Fixnum), true, be_a(Hash)] }
  let(:worker) { create_worker }
  let(:worker_args) { ['string', 1, true, { key: 'value', bar: :foo, nested: [{ hash: true }] }] }
  let(:active_job) { create_active_job :mailers }
  let(:resource) { TestResource.new }

  before(:each) do
    worker.perform_async *worker_args
    active_job.perform_later 'someResource'
    active_job.perform_later(resource)
    TestActionMailer.testmail.deliver_later
    TestActionMailer.testmail(resource).deliver_later
  end

  describe 'expected usage' do
    context 'Sidekiq' do
      it 'matches' do
        expect(worker).to have_enqueued_sidekiq_job *worker_args
      end

      it 'matches on the global Worker queue' do
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job *worker_args
      end

      context 'perform_in' do
        let(:worker_args_in) { worker_args + ['in'] }

        before(:each) do
          worker.perform_in 3.minutes, *worker_args_in
        end

        it 'matches on an scheduled job with #perform_in' do
          expect(worker).to have_enqueued_sidekiq_job(*worker_args_in).in(interval)
        end
      end

      context 'perform_at' do
        let(:worker_args_at) { worker_args + ['at'] }

        before(:each) do
          worker.perform_at tomorrow, *worker_args_at
        end

        it 'matches on an scheduled job with #perform_at' do
          expect(worker).to have_enqueued_sidekiq_job(*worker_args_at).at(tomorrow)
        end
      end

      context 'setting queue at enqueue time' do
        before(:each) do
          worker.set(queue: queue).perform_async *worker_args
        end

        let(:queue) { :queue }

        it 'matches on an scheduled job' do
          expect(worker).to have_enqueued_sidekiq_job(*worker_args).to(queue)
        end
      end
    end

    context 'ActiveJob' do
      it 'matches on an enqueued ActiveJob' do
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job 'someResource'
      end

      it 'matches on an enqueued ActiveJob by global_id' do
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job('_aj_globalid' => resource.to_global_id.uri.to_s)
      end
    end

    context 'ActionMailer' do
      it 'matches on ActionMailer Job' do
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job(
          'TestActionMailer',
          'testmail',
          'deliver_now'
        )
      end

      it 'matches on ActionMailer with a resource Job' do
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job(
          'TestActionMailer',
          'testmail',
          'deliver_now',
          { '_aj_globalid' => resource.to_global_id.uri.to_s }
        )
      end
    end
  end

  describe '#have_enqueued_sidekiq_job' do
    it 'returns instance' do
      expect(have_enqueued_sidekiq_job).to be_a RSpec::Sidekiq::Matchers::HaveEnqueuedJob
    end
  end

  describe '#have_enqueued_job' do
    it 'returns instance' do
      expect(have_enqueued_job).to be_a RSpec::Sidekiq::Matchers::HaveEnqueuedJob
    end

    it 'provides deprecation warning' do
      expect { have_enqueued_job }.to output(/[DEPRECATION]/).to_stderr
    end

    it 'matches the same way have_enqueued_sidekiq_job does' do
      expect(worker).to have_enqueued_job *worker_args
    end
  end

  describe '#description' do
    it 'returns description' do
      argument_subject.matches? worker
      expect(argument_subject.description).to eq %(have an enqueued #{worker} job with arguments [\"string\", 1, true, {\"key\"=>\"value\", \"bar\"=>\"foo\", \"nested\"=>[{\"hash\"=>true}]}])
    end
  end

  describe '#failure_message' do
    it 'returns message' do
      argument_subject.matches? worker
      expect(argument_subject.failure_message).to eq <<-eos.gsub(/^ {6}/, '').strip
      expected to have an enqueued #{worker} job
        arguments: [\"string\", 1, true, {\"key\"=>\"value\", \"bar\"=>\"foo\", \"nested\"=>[{\"hash\"=>true}]}]
      found
        arguments: [[\"string\", 1, true, {\"key\"=>\"value\", \"bar\"=>\"foo\", \"nested\"=>[{\"hash\"=>true}]}]]
      eos
    end
  end

  describe '#failure_message_when_negated' do
    it 'returns message' do
      argument_subject.matches? worker
      expect(argument_subject.failure_message_when_negated).to eq <<-eos.gsub(/^ {6}/, '').strip
      expected not to have an enqueued #{worker} job
        arguments: [\"string\", 1, true, {\"key\"=>\"value\", \"bar\"=>\"foo\", \"nested\"=>[{\"hash\"=>true}]}]
      eos
    end
  end

  describe '#matches?' do
    context 'when condition matches' do
      context 'when expected are arguments' do
        it 'returns true' do
          worker.perform_async *worker_args
          expect(argument_subject.matches?(worker)).to be true
        end
      end

      context 'when expected are matchers' do
        it 'returns true' do
          worker.perform_async *worker_args
          expect(matcher_subject.matches?(worker)).to be true
        end
      end

      context 'when job is scheduled' do
        context 'with #perform_at' do
          before(:each) do
            worker.perform_at(tomorrow, *worker_args)
          end

          context 'and timestamp matches' do
            it 'returns true' do
              expect(matcher_subject.at(tomorrow).matches?(worker)).to be true
            end
          end

          context 'and timestamp does not match' do
            it 'returns false' do
              expect(matcher_subject.at(tomorrow + 1).matches?(worker)).to be false
            end
          end
        end

        context 'with #perform_in' do
          before(:each) do
            worker.perform_in(interval, *worker_args)
          end

          context 'and interval matches' do
            it 'returns true' do
              expect(matcher_subject.in(interval).matches?(worker)).to be true
            end
          end

          context 'and interval does not match' do
            it 'returns false' do
              expect(matcher_subject.in(interval + 1.minute).matches?(worker)).to be false
            end
          end
        end

        context 'setting queue at enqueue time' do
          before(:each) do
            worker.set(queue: queue).perform_async(*worker_args)
          end

          let(:queue) { :queue }
          let(:another) { :another }

          context 'and queue matches' do
            it 'returns true' do
              expect(matcher_subject.to(queue).matches?(worker)).to be true
            end
          end

          context 'and queue does not match' do
            it 'returns false' do
              expect(matcher_subject.to(another).matches?(worker)).to be true
            end
          end
        end
      end
    end

    context 'when condition does not match' do
      before(:each) { Sidekiq::Worker.clear_all }

      context 'when expected are arguments' do
        it 'returns false' do
          expect(argument_subject.matches?(worker)).to be false
        end
      end

      context 'when expected are matchers' do
        it 'returns false' do
          expect(matcher_subject.matches?(worker)).to be false
        end
      end

      context 'when job is scheduled' do
        context 'with #perform_at' do
          before(:each) do
            allow(matcher_subject).to receive(:options).and_return(at: tomorrow + 1)
          end

          it 'returns false' do
            expect(matcher_subject.at(tomorrow).matches?(worker)).to be false
          end
        end

        context 'with #perform_in' do
          before(:each) do
            allow(matcher_subject).to receive(:options).and_return(in: interval + 1)
          end

          it 'returns false' do
            expect(matcher_subject.in(interval).matches?(worker)).to be false
          end
        end
      end
    end
  end
end
