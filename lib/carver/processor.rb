module Carver
  class Processor
    def call
      { data: 'result goes here' }
    end

    private

    def files_for(type)
      Dir["./**/*.#{type}*"].reject { |dir| dir.include?('tmp') || dir.include?('spec') || dir.include?('json') }
    end
  end
end
