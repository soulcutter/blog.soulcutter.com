# frozen_string_literal: true

module Components
  class TabGroup < Phlex::HTML
    def initialize
      @index = 1
    end

    def template(&block)
      div class: "tabs flex flex-wrap relative my-5", role: "tablist" do
        yield_content(&block)
      end
    end

    def tab(name, &block)
      render(Tab.new(name: name, checked: first?), &block)
      @index += 1
      nil
    end

    def unique_identifier
      @unique_identifier ||= SecureRandom.hex
    end

    private

    def first?
      @index == 1
    end
  end
end