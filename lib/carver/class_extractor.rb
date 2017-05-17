class ClassExtractor
  HTML_DECLARATIONS = [/class\s?=\s?".*"/, /class\s?:\s?".*"/, /class\s?=\s?'.*'/, /class\s?:\s?'.*'/]
  JS_DECLARATIONS = [/addClass(.*)/, /removeClass(.*)/, /toggleClass(.*)/, /className\s?=\s?.*/, /attr\(".*",/,
                     /attr\('.*',/, /.css\(.*,/, /.css\(.*".*":.*}/, /.css\(.*'.*':.*}/, /"[^"]*":/, /'[^']*':/]
  HTML_DELETIONS = ['class=', 'class:', '"', "'"]
  JS_DELETIONS = ['addClass', 'removeClass', 'toggleClass', "'", '"', '(', ')',
                  ';', 'attr', '{', '}', ',', 'className', '=', '.css', ':']

  def initialize(content, type)
    @content = content
    @type = type
    @classes = []
  end

  def scan
    current_type_declarations.each do |regex|
      @classes += @content.scan(regex).flatten.map do |expression|
        self.send("#{@type}_deletions", expression)
      end.flatten
    end

    @classes
  end

  private

  def current_type_declarations
    self.class.const_get("#{@type.to_s.upcase}_DECLARATIONS")
  end

  def html_deletions(expression)
    HTML_DELETIONS.each { |deletion| expression.gsub!(deletion, '') }
    expression.strip.split(' ')
  end

  def js_deletions(expression)
    JS_DELETIONS.each { |deletion| expression.gsub!(deletion, '') }
    expression.strip
  end
end
