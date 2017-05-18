require_relative 'chopper'

module Carver
  class Processor
    def call(input)
      { data: Carver::Chopper.new(input).chop }
    end
  end
end
