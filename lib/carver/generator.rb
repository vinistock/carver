# frozen_string_literal: true

require 'erb'

module Carver
  class Generator
    def initialize(results, output_path)
      @controller_results = sort(results.select { |item| item.include?('Controller') })
      @job_results = sort(results.select { |item| item.include?('Job') })
      @output_path = output_path
    end

    def create_html
      template = File.read("#{File.expand_path('..', __FILE__)}/templates/results.html.erb")
      html = ERB.new(template).result(binding)
      File.open(@output_path, 'w') { |f| f.write(html) }
    end

    private

    def sort(results)
      memory_results = {}
      benchmark_results = {}

      results.each do |key, value|
        memory = value.select { |a| a[:category] == :memory }
        benchmark = value.select { |a| a[:category] == :benchmark }
        memory_results[key] = memory unless memory.empty?
        benchmark_results[key] = benchmark unless benchmark.empty?
      end

      memory_results.each do |key, value|
        memory_results[key].replace(value.sort_by { |a| -a[:total_allocated_memsize] })
      end

      benchmark_results.each do |key, value|
        benchmark_results[key].replace(value.sort_by { |a| -a[:real] })
      end

      sorted_memory = memory_results.sort_by { |_, value| -value.first.try(:[], :total_allocated_memsize) }.to_h
      sorted_benchmark = benchmark_results.sort_by { |_, value| -value.first.try(:[], :real) }.to_h

      {
        memory: sorted_memory,
        benchmark: sorted_benchmark
      }
    end
  end
end
