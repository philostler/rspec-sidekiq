require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::BeUnique do
  shared_context 'a unique worker' do
    before do
      stub_const(module_constant, true)
    end
    before(:each) { subject.matches? @worker }

    describe 'expected usage' do
      it 'matches' do
        expect(@worker).to be_unique
      end

      describe '#failure_message' do
        it 'returns message' do
          expect(subject.failure_message).to eq "expected #{@worker} to be unique in the queue"
        end
      end
    end

    describe '#matches?' do
      context 'when condition matches' do
        it 'returns true' do
          expect(subject.matches? @worker).to be true
        end
      end

      context 'when condition does not match' do
        it 'returns false' do
          expect(subject.matches? create_worker unique: false).to be false
        end
      end

      describe '#failure_message_when_negated' do
        it 'returns message' do
          expect(subject.failure_message_when_negated).to eq "expected #{@worker} to not be unique in the queue"
        end
      end
    end

    describe '#description' do
      it 'returns description' do
        expect(subject.description).to eq 'be unique in the queue'
      end
    end
  end

  context 'a sidekiq-enterprise scheduled worker' do
    let(:interval) { 3.hours }
    let(:module_constant) { "Sidekiq::Enterprise" }
    before { @worker = create_worker unique_for: interval }
    include_context 'a unique worker'
  end

  context '.until' do
    let(:module_constant) { "Sidekiq::Enterprise" }
    let(:expiration) { :success }
    let(:interval) { 3.hours }
    let(:sidekiq_options) { { unique_for: interval, unique_until: expiration } }
    let(:worker) do
      options = sidekiq_options
      Class.new do
        include ::Sidekiq::Worker
        sidekiq_options options
        def perform; end
      end
    end

    before { stub_const(module_constant, true) }

    subject do
      stub_const('MuhWorker', worker)
      MuhWorker
    end

    it { should be_unique.for(interval).until(:success) }

    context 'errors' do
      subject { expect(super()).to be_unique.until(:started) }

      context 'when there is a mismatch' do
        it do
          expect { subject }.to raise_error RSpec::Expectations::ExpectationNotMetError,
            'expected MuhWorker to be unique until started, but its unique_until was success'
        end
      end

      context 'when not specified' do
        let(:expiration) { nil }

        it do
          expect { subject }.to raise_error RSpec::Expectations::ExpectationNotMetError,
            'expected MuhWorker to be unique until started, but its unique_until was not specified'
        end
      end

      context 'when unique_until is not supported' do
        let(:module_constant) { "SidekiqUniqueJobs" }
        let(:sidekiq_options) { { unique: interval } }

        it { expect { subject }.to raise_error 'until is not supported for SidekiqUniqueJobs' }
      end
    end
  end

  context 'a sidekiq-unique-jobs scheduled worker' do
    let(:module_constant) { "SidekiqUniqueJobs" }
    before { @worker = create_worker unique: :all }
    include_context 'a unique worker'
  end

  context 'a sidekiq-unique-jobs regular worker' do
    let(:module_constant) { "SidekiqUniqueJobs" }
    before { @worker = create_worker unique: true }
    include_context 'a unique worker'
  end

  describe '#be_unique' do
    before do
      stub_const("SidekiqUniqueJobs", true)
    end

    it 'returns instance' do
      expect(be_unique).to be_kind_of RSpec::Sidekiq::Matchers::BeUnique::Base
    end
  end

  describe '#failure_message_when_negated' do
    before do
      stub_const("SidekiqUniqueJobs", true)
    end

    it 'returns message' do
      expect(subject.failure_message_when_negated).to eq "expected #{@worker} to not be unique in the queue"
    end
  end

  describe '#unique_key' do
    context "with Sidekiq Enterprise" do
      before do
        stub_const("Sidekiq::Enterprise", true)
      end

      it "returns the correct key" do
        expect(subject.unique_key).to eq('unique_for')
      end
    end

    context "with sidekiq-unique-jobs" do
      before do
        stub_const("SidekiqUniqueJobs", true)
      end

      it "returns the correct key" do
        expect(subject.unique_key).to eq('unique')
      end
    end

    context "without a uniquing solution" do
      it "raises an exception" do
        expect{subject.unique_key}.to raise_error RuntimeError, 'No support found for Sidekiq unique jobs'
      end
    end
  end
end
