module Components
  class TabGroup

    class Tab < Phlex::HTML
      def initialize(name:, checked:)
        @name = name
        @checked = checked
        @unique_identifier = SecureRandom.hex
      end

      def template(&block)
        input class: "opacity-0 fixed peer", type: "radio", name: @_parent.unique_identifier, id: @unique_identifier, checked: @checked

        label id: "#{@unique_identifier}-label", for: @unique_identifier, role: "tab", aria_controls: "#{@unique_identifier}-panel", class: "order-1 py-2 px-5 bg-white text-sm border border-b-0 border-l-0 font-medium first-of-type:border-l first-of-type:rounded-tl last-of-type:rounded-tr before:absolute before:pointer-events-none before:w-full before:ring before:h-full before:left-0 before:top-0 before:hidden before:rounded peer-focus:before:block cursor-pointer" do
          @name
        end

        div id: "#{@unique_identifier}-panel", role: "tabpanel", aria_labelledby: "#{@unique_identifier}-label", class: "tab hidden order-2 w-full border rounded-b rounded-tr overflow-hidden" do
          yield_content(&block)
        end
      end

    end
  end
end