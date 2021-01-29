require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::BeExpiredIn do
  let(:subject) { RSpec::Sidekiq::Matchers::BeExpiredIn.new 1 }
  let(:worker) { create_worker expires_in: 1 }

  describe '#be_expired_in' do
    it 'returns instance' do
      expect(be_expired_in 1).to be_a described_class
    end
  end

  describe 'expected usage' do
    it 'matches' do
      expect(worker).to be_expired_in 1
    end

    context 'with negated' do
      it 'matches' do
        expect(worker).to_not be_expired_in 2
      end
    end
  end

  describe '#failure_message' do
    it 'returns message' do
      subject.matches? worker
      expect(subject.failure_message).to eq "expected to expire in #{worker.sidekiq_options['expires_in']} but expired in #{subject.instance_variable_get(:@expected_argument)}"
    end
  end

  describe '#matches?' do
    context 'when expected equals actual' do
      it 'returns true' do
        expect(subject.matches? worker).to be true
      end
    end
    context 'when expected is not equal to actual' do
      it 'returns false' do
        expect(described_class.new(2).matches? worker). to be false
      end
    end
  end

  describe '#failure_message_when_negated' do
    it 'returns message' do
      subject.matches? worker
      expect(subject.failure_message_when_negated).to eq "expected to not expire in #{subject.instance_variable_get(:@expected_argument)}"
    end
  end

  describe '#description' do
    it 'returns message' do
      expect(subject.description).to eq "to expire in #{subject.instance_variable_get(:@expected_argument)}"
    end
  end
end
