module RSpec
  module Sidekiq
    module Matchers
      def be_delayed(*expected_arguments)
        BeDelayed.new(*expected_arguments)
      end

      class BeDelayed
        def initialize(*expected_arguments)
          @expected_arguments = expected_arguments
        end

        def description
          description = 'be delayed'
          description += " for #{@expected_interval} seconds" if @expected_interval
          description += " until #{@expected_time}" if @expected_time
          description += " with arguments #{@expected_arguments}" unless @expected_arguments.empty?
          description
        end

        def failure_message
          "expected #{@expected_method_receiver}.#{@expected_method.name} to " + description
        end

        def for(interval)
          @expected_interval = interval
          self
        end

        def matches?(expected_method)
          @expected_method = expected_method
          @expected_method_receiver = @expected_method.is_a?(UnboundMethod) ? @expected_method.owner : @expected_method.receiver

          find_job @expected_method, @expected_arguments do |job|
            if @expected_interval
              created_enqueued_at = job['enqueued_at'] || job['created_at']
              return job['at'].to_i == created_enqueued_at.to_i + @expected_interval
            elsif @expected_time
              return job['at'].to_i == @expected_time.to_i
            else
              return true
            end
          end

          false
        end

        def failure_message_when_negated
          "expected #{@expected_method_receiver}.#{@expected_method.name} to not " + description
        end

        def until(time)
          @expected_time = time
          self
        end

        private

        def find_job(method, arguments, &block)
          job = (::Sidekiq::Extensions::DelayedClass.jobs + ::Sidekiq::Extensions::DelayedModel.jobs + ::Sidekiq::Extensions::DelayedMailer.jobs).find do |job|
            yaml = YAML.load(job['args'].first)
            matcher = ::RSpec::Mocks::ArgumentListMatcher.new(*@expected_arguments)
            @expected_method_receiver == yaml[0] && @expected_method.name == yaml[1] && matcher.args_match?(*yaml[2])
          end

          yield job if block && job
        end
      end
    end
  end
end
