# frozen_string_literal: true
require 'bundler/setup'
require 'byebug'
require 'simplecov'
require 'rails/all'
require 'carver'

SimpleCov.start
Rails.logger = STDOUT

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Simple mocks for the profiler results
class MemoryProfilerResults
  def total_allocated_memsize
    21000
  end
  def total_retained_memsize
    1500
  end
end

class BenchmarkResults
  def real
    3.5
  end
  def total
    5.2
  end
end
