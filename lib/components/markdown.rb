# frozen_string_literal: true

module Components
  class Markdown < Phlex::Markdown
    def h1 = super(class: "text-3xl font-semibold my-5")
    def h2 = super(class: "text-2xl font-semibold mt-10 mb-5")
    def h3 = super(class: "text-xl font-semibold my-5")
    def h4 = super(class: "text-lg font-semibold my-4")

    def a(**attributes)
      super(
        class: "font-bold text-teal-600 active:text-teal-800 underline underline-offset-4",
        **attributes
      )
    end

    def code = super(class: "bg-stone-50 inline-block font-medium rounded border px-1 -mt-1")

    def code_block(code, language)
      if language == "ruby_example"
        instance_eval(code)
      else
        render CodeBlock.new(code, syntax: language)
      end
    end

    def example(&)
      render(RubyExample.new, &)
    end
  end
end