# frozen_string_literal: true

describe Carver::Result do
  describe '#to_hash' do
    subject { described_class.new(report, type).to_hash }

    context 'when type is memory' do
      let(:type) { :memory }
      let(:report) { MemoryProfilerResults.new }

      it 'returns memory metrics as hash' do
        expect(subject).to eq({ category: :memory, total_allocated_memsize: 0.02003, total_retained_memsize: 0.00143 })
      end
    end

    context 'when type is benchmark' do
      let(:type) { :benchmark }
      let(:report) { BenchmarkResults.new }

      it 'returns benchmark metrics as hash' do
        expect(subject).to eq({ category: :benchmark, real: 3.5, total: 5.2 })
      end
    end

    context 'when type is not supported' do
      let(:type) { :whatever }
      let(:report) { BenchmarkResults.new }
      it { expect { subject }.to raise_error(ArgumentError, 'Unsupported result type') }
    end
  end

  describe '#to_log' do
    subject { described_class.new(report, type).to_log }

    context 'when type is memory' do
      let(:type) { :memory }
      let(:report) { MemoryProfilerResults.new }

      it 'returns memory metrics as log entry' do
        expect(subject).to eq('category=memory total_allocated_memsize=0.02003 total_retained_memsize=0.00143')
      end
    end

    context 'when type is benchmark' do
      let(:type) { :benchmark }
      let(:report) { BenchmarkResults.new }

      it 'returns benchmark metrics as log entry' do
        expect(subject).to eq('category=benchmark real=3.5 total=5.2')
      end
    end

    context 'when type is not supported' do
      let(:type) { :whatever }
      let(:report) { BenchmarkResults.new }
      it { expect { subject }.to raise_error(ArgumentError, 'Unsupported result type') }
    end
  end
end
