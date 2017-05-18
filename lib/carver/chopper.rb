require_relative 'class_extractor'

module Carver
  class Chopper
    def initialize(css)
      @declared_classes = Carver::ClassExtractor.new(css, :css).scan
    end

    def chop
    end

    private

    def identify_all_used_classes
      (identify_html_classes + identify_js_classes).flatten.compact
    end

    def identify_html_classes
      files_for(:html).map do |path|
        Carver::ClassExtractor.new(File.read(path), :html).scan
      end
    end

    def identify_js_classes
      files_for(:js).map do |path|
        Carver::ClassExtractor.new(File.read(path), :js).scan
      end
    end

    def files_for(type)
      Dir["./**/*.#{type}*"].reject do |dir|
        dir.include?('tmp') || dir.include?('spec') ||
          dir.include?('json') || dir.include?('coverage')
      end
    end
  end
end
