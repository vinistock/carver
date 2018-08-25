# frozen_string_literal: true

require 'benchmark'

module Carver
  class Profiler
    def self.profile_memory(path, action, parent)
      return yield unless Carver.configuration.enabled

      report = MemoryProfiler.report do
        yield
      end

      presenter = Presenter.new(Result.new(report, :memory), path, action, parent)
      presenter.log if Carver.configuration.log_results
      presenter.add_to_results
    end

    def self.benchmark(path, action, parent)
      return yield unless Carver.configuration.enabled

      report = Benchmark.measure do
        yield
      end

      presenter = Presenter.new(Result.new(report, :benchmark), path, action, parent)
      presenter.log if Carver.configuration.log_results
      presenter.add_to_results
    end
  end
end
