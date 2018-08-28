# frozen_string_literal: true


describe Carver::Hooks do
  include Carver::Hooks

  describe '.define_specific_profilers' do
    subject { define_specific_profilers }

    before do
      Carver.configuration.specific_targets = %w(Api::V1::ExamplesController#index PagesController#index ExamplesJob)
      allow(Rails).to receive(:load).and_return(true)
      Carver.configuration.benchmark_enabled = true
    end

    let!(:random_controller) { class RandomController < ActionController::Base; end }
    let!(:examples_controller) do
      module Api
        module V1
          class ExamplesController < ActionController::Base
            def index
            end
          end
        end
      end
    end

    let!(:pages_controller) do
      class PagesController < ActionController::Base
        def index
        end
      end
    end

    let!(:examples_job) do
      class ExamplesJob < ActiveJob::Base
        def perform
        end
      end
    end

    it 'defines the memory profiler filters for the picked entities' do
      subject
      around_filters = Api::V1::ExamplesController._process_action_callbacks.select { |f| f.kind == :around }.map(&:filter)
      expect(around_filters).to include(:profile_controller_actions)
      around_filters = PagesController._process_action_callbacks.select { |f| f.kind == :around }.map(&:filter)
      expect(around_filters).to include(:profile_controller_actions)
      around_filters = ExamplesJob._perform_callbacks.select { |f| f.kind == :around }.map(&:filter)
      expect(around_filters).to_not be_empty
      around_filters = RandomController._process_action_callbacks.select { |f| f.kind == :around }.map(&:filter)
      expect(around_filters).to_not include(:profile_controller_actions)
    end
  end
end
