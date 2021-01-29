require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::BeRetryable do
  let(:specific_subject) { RSpec::Sidekiq::Matchers::BeRetryable.new 2 }
  let(:specific_worker) { create_worker retry: 2 }
  let(:default_subject) { RSpec::Sidekiq::Matchers::BeRetryable.new true }
  let(:default_worker) { create_worker retry: true }
  let(:negative_subject) { RSpec::Sidekiq::Matchers::BeRetryable.new false }
  let(:negative_worker) { create_worker retry: false }
  before(:each) do
    specific_subject.matches? specific_worker
    default_subject.matches? default_worker
    negative_subject.matches? negative_worker
  end

  describe 'expected usage' do
    it 'matches' do
      expect(default_worker).to be_retryable true
    end
  end

  describe '#be_retryable' do
    it 'returns instance' do
      expect(be_retryable true).to be_a described_class
    end
  end

  describe '#description' do
    context 'when expected is a number' do
      it 'returns description' do
        expect(specific_subject.description).to eq 'retry 2 times'
      end
    end

    context 'when expected is true' do
      it 'returns description' do
        expect(default_subject.description).to eq 'retry the default number of times'
      end
    end

    context 'when expected is false' do
      it 'returns description' do
        expect(negative_subject.description).to eq 'not retry'
      end
    end
  end

  describe '#failure_message' do
    context 'when expected is a number' do
      it 'returns message' do
        expect(specific_subject.failure_message).to eq "expected #{specific_worker} to retry 2 times but got 2"
      end
    end

    context 'when expected is true' do
      it 'returns message' do
        expect(default_subject.failure_message).to eq "expected #{default_worker} to retry the default number of times but got true"
      end
    end

    context 'when expected is false' do
      it 'returns message' do
        expect(negative_subject.failure_message).to eq "expected #{negative_worker} to not retry but got false"
      end
    end
  end

  describe '#matches?' do
    context 'when condition matches' do
      context 'when expected is a number' do
        it 'returns true' do
          expect(specific_subject.matches? specific_worker).to be true
        end
      end

      context 'when expected is true' do
        it 'returns true' do
          expect(default_subject.matches? default_worker).to be true
        end
      end

      context 'when expected is false' do
        it 'returns true' do
          expect(negative_subject.matches? negative_worker).to be true
        end
      end
    end

    context 'when condition does not match' do
      context 'when expected is a number' do
        it 'returns false' do
          expect(specific_subject.matches? default_worker).to be false
        end
      end

      context 'when expected is true' do
        it 'returns false' do
          expect(default_subject.matches? negative_worker).to be false
        end
      end

      context 'when expected is false' do
        it 'returns false' do
          expect(negative_subject.matches? specific_worker).to be false
        end
      end
    end
  end

  describe '#failure_message_when_negated' do
    context 'when expected is a number' do
      it 'returns message' do
        expect(specific_subject.failure_message_when_negated).to eq "expected #{specific_worker} to not retry 2 times"
      end
    end

    context 'when expected is true' do
      it 'returns message' do
        expect(default_subject.failure_message_when_negated).to eq "expected #{default_worker} to not retry the default number of times"
      end
    end

    context 'when expected is false' do
      it 'returns message' do
        expect(negative_subject.failure_message_when_negated).to eq "expected #{negative_worker} to retry"
      end
    end
  end
end
