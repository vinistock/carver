# frozen_string_literal: true

require 'memory_profiler'
require 'carver/version'
require 'carver/profiler'
require 'carver/configuration'
require 'carver/presenter'
require 'carver/generator'
require 'carver/hooks'
require 'carver/result'

module Carver
  extend Hooks

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.current_results
    @current_results ||= {}
  end

  def self.add_to_results(key, results)
    if current_results[key].nil?
      current_results[key] = [results]
    else
      current_results[key] << results
    end
  end

  def self.clear_results
    @current_results = {}
  end

  def self.start
    configuration.enabled = true
  end

  def self.stop
    configuration.enabled = false
  end

  ActiveSupport.on_load(:after_initialize, yield: true) do
    if configuration.specific_targets.nil?
      Carver.define_around_action if Carver.configuration.targets.include?('controllers')
      Carver.define_around_perform if Carver.configuration.targets.include?('jobs')
    else
      Carver.define_specific_profilers
    end
  end

  at_exit do
    if configuration.output_file && !current_results.empty?
      dir_struct = configuration.output_file.split('/')
      dir = dir_struct[0...dir_struct.size - 1].join('/')
      Dir.mkdir(dir) unless File.directory?(dir)
      File.open(configuration.output_file, 'w') { |f| f.write(current_results.to_json) }
      Generator.new(current_results, "#{dir}/results.html").create_html if configuration.generate_html
    end
  end
end
