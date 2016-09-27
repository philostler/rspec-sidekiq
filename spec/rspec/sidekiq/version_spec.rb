require 'spec_helper'

RSpec.describe RSpec::Sidekiq::VERSION do
  it { is_expected.to eq('2.2.1') }
end
