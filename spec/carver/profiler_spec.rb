# frozen_string_literal: true

describe Carver::Profiler do
  class ExamplesController < ActionController::Base
    def index
      something = 5 + 2*10
      something**2
    end
  end

  before { Carver.configuration.enabled = true }

  describe '.profile_memory' do
    subject { described_class.profile_memory(path, action, parent) { ExamplesController.new.index } }
    let(:path) { 'api/v1/examples' }
    let(:action) { 'index' }
    let(:parent) { 'ApplicationController' }

    it 'profiles method and logs results' do
      Carver.configuration.log_results = true
      expect(Rails.logger).to receive(:info).with(/\[Carver\] source=Api::V1::ExamplesController#index type=controller category=memory total_allocated_memsize=.* total_retained_memsize=.*/)
      subject
    end

    it 'adds results to current report if enabled' do
      Carver.configuration.log_results = false
      Carver.clear_results
      subject
      expect(Carver.current_results['Api::V1::ExamplesController#index'].first).to have_key(:total_allocated_memsize)
      expect(Carver.current_results['Api::V1::ExamplesController#index'].first).to have_key(:total_retained_memsize)
    end

    it 'simply yields block if disabled' do
      Carver.stop
      expect(Carver::Presenter).to_not receive(:new)
      expect(MemoryProfiler).to_not receive(:report)
      expect(subject).to eq((5 + 2*10)**2)
    end
  end

  describe '.benchmark' do
    subject { described_class.benchmark(path, action, parent) { ExamplesController.new.index } }
    let(:path) { 'api/v1/examples' }
    let(:action) { 'index' }
    let(:parent) { 'ApplicationController' }

    it 'profiles method and logs results' do
      Carver.configuration.log_results = true
      expect(Rails.logger).to receive(:info).with(/\[Carver\] source=Api::V1::ExamplesController#index type=controller category=benchmark real=.* total=.*/)
      subject
    end

    it 'adds results to current report if enabled' do
      Carver.configuration.log_results = false
      Carver.clear_results
      subject
      expect(Carver.current_results['Api::V1::ExamplesController#index'].first).to have_key(:real)
      expect(Carver.current_results['Api::V1::ExamplesController#index'].first).to have_key(:total)
    end
  end
end
