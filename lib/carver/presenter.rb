# frozen_string_literal: true

module Carver
  class Presenter
    def initialize(result, path, action, parent)
      @result = result
      @path = path
      @action = action
      @parent = parent
    end

    def log
      Rails.logger.info("[Carver] source=#{entry_info[:name]} type=#{entry_info[:type]} #{@result.to_log}")
    end

    def add_to_results
      Carver.add_to_results(entry_info[:name], @result.to_hash)
    end

    private

    def controller?
      @parent.downcase.include?('controller')
    end

    def entry_info
      @entry ||= entry
    end

    def entry
      if controller?
        { name: "#{@path.split('/').map(&:titleize).join('::').delete(' ')}Controller##{@action}", type: 'controller' }.freeze
      else
        { name: "#{@path}##{@action}", type: 'job' }.freeze
      end
    end
  end
end
