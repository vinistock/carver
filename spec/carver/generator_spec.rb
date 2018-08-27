# frozen_string_literal: true
describe Carver::Generator do
  let(:output_file) { './profiling/results.html' }
  let(:results) { {
      'Api::V1::ExamplesController#index' => [
          { category: :memory, total_allocated_memsize: 2.10000, total_retained_memsize: 0.15000 },
          { category: :benchmark, real: 3.5, total: 5.2 },
          { category: :memory, total_allocated_memsize: 2.21500, total_retained_memsize: 0.14500 },
          { category: :benchmark, real: 3.2, total: 5.6 }
      ],
      'Api::V1::ExercisesController#index' => [
          { category: :memory, total_allocated_memsize: 3.30000, total_retained_memsize: 0.15000 },
          { category: :memory, total_allocated_memsize: 2.50000, total_retained_memsize: 0.14500 }
      ],
      'ExamplesJob#perform' => [
          { category: :memory, total_allocated_memsize: 0.57000, total_retained_memsize: 0.00800 }
      ] } }

  describe '.initialize' do
    subject { described_class.new(results, output_file) }

    it 'orders results' do
      expect(subject.instance_variable_get(:@controller_results)[:memory].keys).to eq(%w(Api::V1::ExercisesController#index Api::V1::ExamplesController#index))

      subject.instance_variable_get(:@controller_results)[:memory].each do |_, value|
        expect(value.first[:total_allocated_memsize]).to be > value.second[:total_allocated_memsize]
      end
    end
  end

  describe '#create_html' do
    subject { described_class.new(results, output_file).create_html }

    it 'creates html from results' do
      expect(File).to receive(:open).with(output_file, 'w')
      subject
    end
  end
end
