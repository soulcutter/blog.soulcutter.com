# frozen_string_literal: true

module Components
  class RubyExample < Phlex::HTML
    def initialize
      @sandbox = Module.new
    end

    def template(&block)
      render TabGroup.new do |t|
        @t = t
        yield self
      end
    end

    def tab(name, code, syntax: :ruby)
      @t.tab(name) do
        render CodeBlock.new(code, syntax: syntax)
      end

      @sandbox.class_eval(code) if syntax == :ruby
    end

    def execute(code)
      output = @sandbox.class_eval(code)

      @t.tab("👀 Output") do
        render CodeBlock.new(HtmlBeautifier.beautify(output), syntax: :html)
      end
    end
  end
end
