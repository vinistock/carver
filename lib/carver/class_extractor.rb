module Carver
  class ClassExtractor
    HTML_DECLARATIONS = [/class\s?=\s?".*"/, /class\s?:\s?".*"/, /class\s?=\s?'.*'/, /class\s?:\s?'.*'/,
                         /id\s?=\s?".*"/, /id\s?=\s?'.*'/, /id\s?:\s?".*"/, /id\s?:\s?'.*'/, /<[^><\/]*>/]
    JS_DECLARATIONS = [/addClass(.*)/, /removeClass(.*)/, /toggleClass(.*)/, /className\s?=\s?.*/, /attr\(".*",/,
                       /attr\('.*',/, /.css\(.*,/, /.css\(.*".*":.*}/, /.css\(.*'.*':.*}/, /"[^"]*":/, /'[^']*':/]
    JS_SCANNERS = [/.*\.addClass\(.*\)/, /.*\.removeClass\(.*\)/, /.*\.toggleClass\(.*\)/, /.*\.css\(.*\)/,
                   /\$\(.*\).*attr\(.*\)/, /.*\.className\s?=\s?.*/, /.*\.css\([\s\S][^();]+\)/]
    JS_SELECTORS = [/\$\([^()]+\)/, /(?<=querySelector)\([^()]+\)/]
    JS_TARGETS = [/(?<=.addClass)\([^()]+\)/, /(?<=.removeClass)\([^()]+\)/, /(?<=.toggleClass)\([^()]+\)/,
                  /(?<=.css)\([^()]+\)/, /(?<=.attr)\([^()]+\)/, /(?<=\.className).*/]
    HTML_DELETIONS = ['class=', 'class:', '"', "'", 'id=', 'id:', '>', '<']
    JS_DELETIONS = ['addClass', 'removeClass', 'toggleClass', "'", '"', '(', ')',
                    ';', 'attr', '{', '}', ',', 'className', '=', '.css', ':', '$', '.', '#']
    CSS_SCANNERS = [/[^{}]+(?={)/]

    def initialize(content, type)
      @content = content
      @type = type
    end

    def scan
      self.send("scan_#{@type}")
    end

    private

    def scan_css
      CSS_SCANNERS.map do |scanner|
        @content.scan(scanner).map do |expression|
          split_multiple_class_declaration(expression)
        end
      end.flatten.compact
    end

    def split_multiple_class_declaration(expression)
      expression.split(',').map do |selector|
        next if expression.include?('@import')
        build_css_hash(selector)
      end
    end

    def build_css_hash(selector)
      hash = { element: nil, id: nil, classes: [] }
      klass = safe_strip(selector.scan(/(?<=\.)[^.#,{]+/).first)
      hash[:classes] << klass unless klass.nil?
      hash[:id] = safe_strip(selector.scan(/(?<=#)[^.#,{]+/).first)
      hash[:element] = safe_strip(selector.scan(/.+?(?=[#.])/).first)
      hash[:id].nil? && hash[:element].nil? && hash[:classes].empty? ? nil : hash
    end

    def safe_strip(string)
      string.to_s.strip unless string.nil?
    end

    def scan_js
      JS_SCANNERS.map do |scanner|
        @content.scan(scanner).map do |expression|
          hash = extract_js_selector(expression) || { element: nil, id: nil, classes: [] }
          hash[:classes] += extract_js_target(expression)
          hash
        end.flatten
      end.flatten.compact.uniq
    end

    def extract_js_target(expression)
      JS_TARGETS.map do |regex|
        target = expression.scan(regex).first.to_s

        if target.empty?
          nil
        elsif target.include?('{')
          target.split(',').map.with_index { |word| js_deletions(word.split(':').first) }
        elsif target.include?(',')
          js_deletions(target.split(',').first)
        else
          js_deletions(target)
        end
      end.flatten.compact
    end

    def extract_js_selector(expression)
      JS_SELECTORS.map do |regex|
        selector = expression.scan(regex).first.to_s

        hash = { element: nil, id: nil, classes: [] }

        if selector.include?('#')
          hash[:id] = js_deletions(selector)
        elsif selector.include?('.')
          hash[:classes] << js_deletions(selector)
        else
          hash[:element] = js_deletions(selector)
        end

        selector.empty? ? nil : hash
      end.flatten.compact.first
    end

    def scan_html
      @content.scan(/<[^><\/]*>/).map do |element|
        next if element.include?('DOCTYPE') || element.include?('doctype') || element.include?('<%')
        html_tag = html_deletions(element.scan(/<([^\s]+)/).flatten.first)
        id = html_deletions(element.scan(/(id\s?=\s?".*") | (id\s?=\s?'.*') | (id\s?:\s?".*") | (id\s?:\s?'.*')/).flatten.compact.first)

        {
          element: html_tag && html_tag.first,
          id: id && id.first,
          classes: element
                     .scan(/(class\s?=\s?".*")|(class\s?:\s?".*")|(class\s?=\s?'.*')|(class\s?:\s?'.*')/)
                     .flatten.compact.map { |klass| html_deletions(klass) }
                     .flatten.uniq
        }
      end
    end

    def html_deletions(expression)
      return nil if expression.nil?
      HTML_DELETIONS.each { |deletion| expression.gsub!(deletion, '') }
      expression.strip.split(' ')
    end

    def js_deletions(expression)
      JS_DELETIONS.each { |deletion| expression.gsub!(deletion, '') }
      expression.strip
    end
  end
end
