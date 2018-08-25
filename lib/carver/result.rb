# frozen_string_literal: true

module Carver
  class Result
    AVAILABLE_RESULT_TYPES = %i[benchmark memory].freeze
    BYTES_TO_MB_CONSTANT = 1024**2

    def initialize(report, type)
      raise ArgumentError, 'Unsupported result type' unless AVAILABLE_RESULT_TYPES.include?(type)
      @report = report
      @type = type
    end

    def to_hash
      send("#{@type}_to_hash")
    end

    def to_log
      to_hash.map { |k, v| "#{k}=#{v}" }.join(' ')
    end

    private

    def memory_to_hash
      {
        category: :memory,
        total_allocated_memsize: (@report.total_allocated_memsize.to_f / BYTES_TO_MB_CONSTANT).round(5),
        total_retained_memsize: (@report.total_retained_memsize.to_f / BYTES_TO_MB_CONSTANT).round(5)
      }
    end

    def benchmark_to_hash
      {
        category: :benchmark,
        real: @report.real.round(5),
        total: @report.total.round(5)
      }
    end
  end
end
