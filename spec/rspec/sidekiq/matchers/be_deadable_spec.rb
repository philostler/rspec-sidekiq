require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::BeDeadable do
  let(:subject) { RSpec::Sidekiq::Matchers::BeDeadable.new }
  let(:dead_worker) { create_worker(dead: true) }
  let(:survivor_worker) { create_worker }

  describe '#be_deadable' do
    it 'returns instance' do
      expect(be_deadable).to be_a described_class
    end
  end

  describe 'expected usage' do
    it 'matches' do
      expect(dead_worker).to be_deadable
    end
    context 'with negated' do
      it 'matches' do
        expect(survivor_worker).not_to be_deadable
      end
    end
  end

  describe '#failure_message' do
    it 'returns message' do
      subject.matches? dead_worker
      expect(subject.failure_message).to eq "expected #{self.dead_worker} to be \"#{subject.current_state}\" but got \"#{subject.instance_variable_get(:@actual)}\""
    end
  end

  describe '#matches?' do
    context 'when expected equals actual' do
      it 'returns true' do
        expect(subject.matches? dead_worker).to be true
      end
    end
    context 'when expected is not equal to actual' do
      it 'returns false' do
        expect(subject.matches? survivor_worker). to be false
      end
    end
  end

  describe '#failure_message_when_negated' do
    it 'returns message' do
      subject.matches? dead_worker
      expect(subject.failure_message_when_negated).to eq "expected #{subject.instance_variable_get(:@klass)} to be \"#{subject.current_state}\" but it does"
    end
  end

  describe '#description' do
    it 'returns message' do
      expect(subject.description).to eq "be #{subject.current_state} in queue"
    end
  end
end
