module Carver
  class ClassExtractor
    HTML_DECLARATIONS = [/class\s?=\s?".*"/, /class\s?:\s?".*"/, /class\s?=\s?'.*'/, /class\s?:\s?'.*'/,
                         /id\s?=\s?".*"/, /id\s?=\s?'.*'/, /id\s?:\s?".*"/, /id\s?:\s?'.*'/, /<[^><\/]*>/]
    JS_DECLARATIONS = [/addClass(.*)/, /removeClass(.*)/, /toggleClass(.*)/, /className\s?=\s?.*/, /attr\(".*",/,
                       /attr\('.*',/, /.css\(.*,/, /.css\(.*".*":.*}/, /.css\(.*'.*':.*}/, /"[^"]*":/, /'[^']*':/]
    JS_SCANNERS = [/\$\(.*\).*addClass\(.*\)/, /\$\(.*\).*removeClass\(.*\)/, /\$\(.*\).*toggleClass\(.*\)/, /\$\(.*\).*css\(.*\)/,
                   /\$\(.*\).*attr\(.*\)/]
    HTML_DELETIONS = ['class=', 'class:', '"', "'", 'id=', 'id:', '>', '<']
    JS_DELETIONS = ['addClass', 'removeClass', 'toggleClass', "'", '"', '(', ')',
                    ';', 'attr', '{', '}', ',', 'className', '=', '.css', ':', '$']

    def initialize(content, type)
      @content = content
      @type = type
    end

    def scan
      self.send("scan_#{@type}")
    end

    private

    def scan_js
      JS_DECLARATIONS.map do |regex|
        @content.scan(regex).flatten.map do |expression|
          self.send("#{@type}_deletions", expression)
        end.flatten
      end.flatten.uniq
    end

    def scan_html
      @content.scan(/<[^><\/]*>/).map do |element|
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

    def current_type_declarations
      self.class.const_get("#{@type.to_s.upcase}_DECLARATIONS")
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
