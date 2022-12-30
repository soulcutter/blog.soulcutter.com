# frozen_string_literal: true

module Components
  class Nav < Phlex::HTML
    def template
      nav(class: "flex text-stone-500 font-medium justify-left sticky top-0 left-0 px-6 lg:px-20 z-20") do
        ul(class: "flex flex-row space-x-8") do
          li { nav_link(to: "/articles") { "Articles" } }
          li { nav_link(to: "/code") { "Code" } }
        end
      end
    end

    def nav_link(to:, &block)
      a(
        href: to, 
        **classes(
          "block border-b-4 border-x-2 py-2 px-4 rounded-b-md bg-white",
          "hover:text-teal-600 hover:border-teal-600",
          "active:text-teal-800 active:border-teal-800",
          -> { @_view_context[:current_page].start_with?(to) } => "border-teal-200 bg-teal-100"
        ),
        &block
      )
    end
  end
end