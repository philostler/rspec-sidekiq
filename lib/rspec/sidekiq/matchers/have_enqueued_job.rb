# frozen_string_literal: true

module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_sidekiq_job(*expected_arguments)
        HaveEnqueuedJob.new expected_arguments
      end

      def have_enqueued_job(*expected_arguments)
        warn '[DEPRECATION] `have_enqueued_job` is deprecated.  Please use `have_enqueued_sidekiq_job` instead.'
        have_enqueued_sidekiq_job(*expected_arguments)
      end

      class JobOptionParser
        attr_reader :job

        def initialize(job)
          @job = job
        end

        def matches?(option, value)
          raise ArgumentError, "Option `#{option}` is not defined." unless %w[in at queue].include?(option.to_s)

          send("#{option}_evaluator", value)
        end

        private

        def at_evaluator(value)
          return false if job['at'].to_s.empty?

          value.to_time.to_s == Time.at(job['at']).to_s
        end

        def in_evaluator(value)
          return false if job['at'].to_s.empty?

          (Time.now + value).to_s == Time.at(job['at']).to_s
        end

        def queue_evaluator(value)
          value == job['queue']
        end
      end

      class JobMatcher
        attr_reader :jobs

        def initialize(klass)
          @jobs = unwrap_jobs(klass.jobs)
        end

        def present?(arguments, options)
          !!find_job(arguments, options)
        end

        private

        def matches?(job, arguments, options)
          arguments_matches?(job, arguments) &&
            options_matches?(job, options)
        end

        def arguments_matches?(job, arguments)
          arguments_got = job_arguments(job)
          contain_exactly?(arguments, arguments_got)
        end

        def options_matches?(job, options)
          options.all? do |option, value|
            parser = JobOptionParser.new(job)
            parser.matches?(option, value)
          end
        end

        def find_job(arguments, options)
          jobs.find { |job| matches?(job, arguments, options) }
        end

        def job_arguments(job)
          args = job['args']
          return args[0]['arguments'] if args.is_a?(Array) && args[0].is_a?(Hash) && args[0].key?('arguments')

          args
        end

        def unwrap_jobs(jobs)
          return jobs if jobs.is_a?(Array)

          jobs.values.flatten
        end

        def contain_exactly?(expected, got)
          exactly = RSpec::Matchers::BuiltIn::ContainExactly.new(expected)
          exactly.matches?(got)
        end
      end

      class HaveEnqueuedJob
        attr_reader :klass, :expected_arguments, :actual_arguments, :expected_options, :actual_options

        def initialize(expected_arguments)
          @expected_arguments = normalize_arguments(expected_arguments)
          @expected_options = {}
        end

        def matches?(klass)
          @klass = klass
          @actual_arguments = unwrapped_job_arguments(klass.jobs)
          @actual_options = unwrapped_job_options(klass.jobs)
          JobMatcher.new(klass).present?(expected_arguments, expected_options)
        end

        def at(timestamp)
          @expected_options['at'] = timestamp
          self
        end

        def in(interval)
          @expected_options['in'] = interval
          self
        end

        def to(queue)
          @expected_options['queue'] = queue

          self
        end

        def description
          "have an enqueued #{klass} job with arguments #{expected_arguments}"
        end

        def failure_message
          message = ["expected to have an enqueued #{klass} job"]
          message << "  arguments: #{expected_arguments}" if expected_arguments
          message << "  options: #{expected_options}" if expected_options.any?
          message << 'found'
          message << "  arguments: #{actual_arguments}" if expected_arguments
          message << "  options: #{actual_options}" if expected_options.any?
          message.join("\n")
        end

        def failure_message_when_negated
          message = ["expected not to have an enqueued #{klass} job"]
          message << "  arguments: #{expected_arguments}" if expected_arguments.any?
          message << "  options: #{expected_options}" if expected_options.any?
          message.join("\n")
        end

        private

        def unwrapped_job_options(jobs)
          jobs = jobs.values if jobs.is_a?(Hash)
          jobs.flatten.map do |job|
            { 'at' => job['at'], 'queue' => job['queue'] }
          end
        end

        def unwrapped_job_arguments(jobs)
          if jobs.is_a? Hash
            jobs.values.flatten.map do |job|
              map_arguments(job)
            end
          else
            map_arguments(jobs)
          end.map(&:flatten)
        end

        def map_arguments(job)
          args = job_arguments(job) || job
          if args.respond_to?(:any?) && args.any? { |e| e.is_a? Hash }
            args.map { |a| map_arguments(a) }
          else
            args
          end
        end

        def job_arguments(hash)
          hash['arguments'] || hash['args'] if hash.is_a? Hash
        end

        def normalize_arguments(args)
          if args.is_a?(Array)
            args.map { |x| normalize_arguments(x) }
          elsif args.is_a?(Hash)
            args.each_with_object({}) do |(key, value), hash|
              hash[key.to_s] = normalize_arguments(value)
            end
          elsif args.is_a?(Symbol)
            args.to_s
          else
            args
          end
        end
      end
    end
  end
end
