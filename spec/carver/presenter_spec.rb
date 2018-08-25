# frozen_string_literal: true
describe Carver::Presenter do
  let(:path) { 'api/v1/examples' }
  let(:action) { 'index' }
  let(:parent) { 'ApplicationController' }
  let!(:results) { Carver::Result.new(MemoryProfilerResults.new, :memory) }

  describe '#log' do
    subject { described_class.new(results, path, action, parent).log }

    context 'when profiled entity is a controller' do
      it 'logs profiling results' do
        expect(Rails.logger).to receive(:info).with('[Carver] source=Api::V1::ExamplesController#index type=controller category=memory total_allocated_memsize=0.02003 total_retained_memsize=0.00143')
        subject
      end

      context 'when benchmarking' do
        let!(:results) { Carver::Result.new(BenchmarkResults.new, :benchmark) }

        it 'logs profiling results' do
          expect(Rails.logger).to receive(:info).with('[Carver] source=Api::V1::ExamplesController#index type=controller category=benchmark real=3.5 total=5.2')
          subject
        end
      end
    end

    context 'when profiled entity is a job' do
      let(:path) { 'ExampleJob' }
      let(:action) { 'perform' }
      let(:parent) { 'ApplicationJob' }

      it 'logs profiling results' do
        expect(Rails.logger).to receive(:info).with('[Carver] source=ExampleJob#perform type=job category=memory total_allocated_memsize=0.02003 total_retained_memsize=0.00143')
        subject
      end

      context 'when benchmarking' do
        let!(:results) { Carver::Result.new(BenchmarkResults.new, :benchmark) }

        it 'logs profiling results' do
          expect(Rails.logger).to receive(:info).with('[Carver] source=ExampleJob#perform type=job category=benchmark real=3.5 total=5.2')
          subject
        end
      end
    end
  end

  describe '#add_to_results' do
    subject { described_class.new(results, path, action, parent).add_to_results }

    it 'adds results to report' do
      Carver.clear_results
      expect(Carver.current_results).to eq({})
      subject
      expect(Carver.current_results).to eq({ 'Api::V1::ExamplesController#index' => [{ category: :memory, total_allocated_memsize: 0.02003, total_retained_memsize: 0.00143 }] })
    end

    context 'when benchmarking' do
      let!(:results) { Carver::Result.new(BenchmarkResults.new, :benchmark) }

      it 'adds benchmarking results' do
        Carver.clear_results
        expect(Carver.current_results).to eq({})
        subject
        expect(Carver.current_results).to eq({ 'Api::V1::ExamplesController#index' => [{ category: :benchmark, real: 3.5, total: 5.2 }] })
      end
    end
  end
end
