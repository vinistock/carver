# frozen_string_literal: true

module Carver
  module Hooks
    def define_specific_profilers
      Carver.configuration.specific_targets.each do |target|
        klass, action = target.split('#')

        if klass.downcase.include?('controller')
          controller_path = klass.downcase.split('::').join('/')
          Rails.send(:load, "#{Rails.root}/app/controllers/#{controller_path}.rb")
          define_around_action_for(klass, action.split(','))
        else
          Rails.send(:load, "#{Rails.root}/app/jobs/#{klass}.rb")
          define_around_perform_for(klass)
        end
      end
    end

    def define_around_action
      Rails.send(:load, "#{Rails.root}/app/controllers/application_controller.rb")
      return if ApplicationController.instance_methods(false).include?(:profile_controller_actions)
      define_around_action_for('ApplicationController', [])
    rescue LoadError, NameError
      raise 'ApplicationController not defined'
    end

    def define_around_perform
      Rails.send(:load, "#{Rails.root}/app/jobs/application_job.rb")
      define_around_perform_for('ApplicationJob')
    rescue LoadError, NameError
      raise 'ApplicationJob not defined'
    end

    def define_around_action_for(controller, actions)
      controller.constantize.class_eval do
        options = actions.empty? ? {} : { only: actions }
        around_action :profile_controller_actions, options

        def profile_controller_actions
          if Carver.configuration.memory_enabled && Carver.configuration.benchmark_enabled
            Carver::Profiler.benchmark(controller_path, action_name, 'ApplicationController') do
              Carver::Profiler.profile_memory(controller_path, action_name, 'ApplicationController') do
                yield
              end
            end
          elsif Carver.configuration.memory_enabled
            Carver::Profiler.profile_memory(controller_path, action_name, 'ApplicationController') do
              yield
            end
          elsif Carver.configuration.benchmark_enabled
            Carver::Profiler.benchmark(controller_path, action_name, 'ApplicationController') do
              yield
            end
          end
        end
      end
    end

    def define_around_perform_for(job_class)
      job_class.constantize.class_eval do
        around_perform do |job|
          if Carver.configuration.benchmark_enabled && Carver.configuration.memory_enabled
            Carver::Profiler.profile_memory(job.name, 'perform', 'ApplicationJob') do
              Carver::Profiler.benchmark(job.name, 'perform', 'ApplicationJob') do
                yield
              end
            end
          elsif Carver.configuration.benchmark_enabled
            Carver::Profiler.benchmark(job.name, 'perform', 'ApplicationJob') do
              yield
            end
          elsif Carver.configuration.memory_enabled
            Carver::Profiler.profile_memory(job.name, 'perform', 'ApplicationJob') do
              yield
            end
          end
        end
      end
    end
  end
end
