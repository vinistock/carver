# frozen_string_literal: true

require 'benchmark'

module Carver
  class Profiler
    def self.profile_memory(path, action, parent)
      return yield unless Carver.configuration.enabled
      report = MemoryProfiler.report { yield }
      present_results(report, path, action, parent, :memory)
    end

    def self.benchmark(path, action, parent)
      return yield unless Carver.configuration.enabled
      report = Benchmark.measure { yield }
      present_results(report, path, action, parent, :benchmark)
    end

    def self.present_results(report, path, action, parent, type)
      presenter = Presenter.new(Result.new(report, type), path, action, parent)
      presenter.log if Carver.configuration.log_results
      presenter.add_to_results
    end
  end
end
