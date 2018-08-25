# frozen_string_literal: true
describe Carver::Configuration do
  describe '.initialize' do
    subject { described_class.new }
    before { allow(Rails.env).to receive(:test?).and_return(true) }

    it 'sets default configuration values' do
      expect(subject.instance_variable_get(:@targets)).to eq(%w(controllers jobs))
      expect(subject.instance_variable_get(:@log_results)).to be_falsey
      expect(subject.instance_variable_get(:@output_file)).to eq('./profiling/results.json')
      expect(subject.instance_variable_get(:@enabled)).to be_truthy
      expect(subject.instance_variable_get(:@generate_html)).to be_truthy
      expect(subject.instance_variable_get(:@specific_targets)).to be_nil
      expect(subject.instance_variable_get(:@benchmark_enabled)).to be_falsey
      expect(subject.instance_variable_get(:@memory_enabled)).to be_truthy
    end
  end

  describe '#targets' do
    subject { described_class.new }

    it 'returns targets or empty array' do
      expect(subject.targets).to eq(%w(controllers jobs))
      subject.targets = nil
      expect(subject.targets).to eq(%w())
    end
  end
end
