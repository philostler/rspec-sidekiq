require 'rspec/core'

if defined? Sidekiq::Batch
  module RSpec
    module Sidekiq
      class NullObject
        def method_missing(*args, &block)
          self
        end
      end

      class NullBatch < NullObject
        attr_accessor :description
        attr_reader :bid

        def initialize(bid = nil)
          @bid = bid || SecureRandom.hex(8)
          @callbacks = []
        end

        def status
          NullStatus.new(@bid, @callbacks)
        end

        def on(*args)
          @callbacks << args
        end

        def jobs(*)
          yield
        end
      end

      class NullStatus < NullObject
        attr_reader :bid

        def initialize(bid = SecureRandom.hex(8), callbacks = [])
          @bid = bid
          @callbacks = callbacks
        end

        def failures
          0
        end

        def join
          ::Sidekiq::Worker.drain_all

          @callbacks.each do |event, callback, options|
            if event != :success || failures == 0
              case callback
              when Class
                callback.new.send("on_#{event}", self, options)
              when String
                klass, meth = callback.split('#')
                klass.constantize.new.send(meth, self, options)
              else
                raise ArgumentError, 'Unsupported callback notation'
              end
            end
          end
        end

        def total
          ::Sidekiq::Worker.jobs.size
        end
      end
    end
  end

  # :nocov:
  RSpec.configure do |config|
    config.before(:each) do |example|
      next if example.metadata[:stub_batches] == false

      if mocked_with.to_sym == :mocha
        Sidekiq::Batch.stubs(:new) { RSpec::Sidekiq::NullBatch.new }
      elsif mocked_with.to_sym == :rr
        stub(Sidekiq::Batch).new { RSpec::Sidekiq::NullBatch.new }
        stub(Sidekiq::Batch::Status).new { RSpec::Sidekiq::NullBatch.new }
      else
        allow(Sidekiq::Batch).to receive(:new)  { RSpec::Sidekiq::NullBatch.new }
        allow(Sidekiq::Batch::Status).to receive(:new)  { RSpec::Sidekiq::NullStatus.new }
      end
    end
  end

  ## Helpers ----------------------------------------------
  def mocked_with_mocha?
    Sidekiq::Batch.respond_to? :stubs
  end

  def mocked_with
    mock_framework = RSpec.configuration.mock_framework
    return mock_framework.framework_name if mock_framework.respond_to? :framework_name
    puts('WARNING: Could not detect mocking framework')
    :rspec
  end
  # :nocov:
end
