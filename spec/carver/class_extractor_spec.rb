describe Carver::ClassExtractor do
  describe '#initialize' do
    subject { described_class.new(content, type) }
    let(:content) { File.read('spec/fixtures/sample_html.html') }
    let(:type) { :html }

    it 'initializes content, type and classes' do
      expect(subject.instance_variable_get(:@content)).to eq(content)
      expect(subject.instance_variable_get(:@type)).to eq(:html)
    end
  end

  describe '#scan' do
    subject { described_class.new(content, type).scan }

    context 'when type is html' do
      let(:type) { :html }
      let(:content) { File.read('spec/fixtures/sample_html.html') }

      it 'finds css classes within html' do
        expect(subject).to eq([
                                { element: 'div', id: nil, classes: ['container'] },
                                { element: 'div', id: 'super-row', classes: ['row'] },
                                { element: 'h2', id: nil, classes: %w(center bold) },
                                { element: 'p', id: 'awesome-paragraph', classes: ['italic'] }
                              ])
      end
    end

    context 'when type is js' do
      let(:type) { :js }
      let(:content) { File.read('spec/fixtures/sample_javascript.js') }

      it 'finds css classes within javascript' do
        expect(subject).to eq([
                                { element: nil, id: 'my-id', classes: ['blue'] },
                                { element: nil, id: 'my-other-id', classes: ['green'] },
                                { element: nil, id: 'yet-one-more', classes: ['visible-xs'] },
                                { element: nil, id: nil, classes: %w(simple-css background-color) },
                                { element: nil, id: 'more-ids', classes: ['font-weight'] },
                                { element: nil, id: 'more-and-more-ids', classes: ['font-size'] },
                                { element: nil, id: 'id', classes: ['italic'] },
                                { element: nil, id: 'complex-css', classes: %w(border-color padding-left) }
                              ])
      end
    end

    context 'when type is css' do
      let(:type) { :css }
      let(:content) { File.read('spec/fixtures/sample_css.css') }

      it 'finds css classes defined in stylesheet' do
        expect(subject).to eq([
                                { element: 'div', id: nil, classes: ['ui-helper-hidden'] },
                                { element: nil, id: nil, classes: ['ui-helper-hidden-accessible'] },
                                { element: nil, id: nil, classes: ['ui-helper-reset'] },
                                { element: nil, id: 'id-one', classes: [] },
                                { element: nil, id: 'id-two', classes: [] }
                              ])
      end
    end
  end
end
