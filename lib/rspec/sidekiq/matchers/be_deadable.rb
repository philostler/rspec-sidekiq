module RSpec
  module Sidekiq
    module Matchers
      def be_deadable
        BeDeadable.new
      end

      class BeDeadable
        def current_state
          @dead ? 'dead' : 'not dead'
        end

        def description
          "be #{current_state} in queue"
        end

        def failure_message
          "expected #{@klass} to be \"#{current_state}\" but got \"#{@actual}\""
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          @dead = @klass.get_sidekiq_options['dead'] || false
        end

        def failure_message_when_negated
          "expected #{@klass} to be \"#{current_state}\" but it does"
        end
      end
    end
  end
end