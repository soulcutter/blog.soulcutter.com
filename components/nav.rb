# frozen_string_literal: true

module Components
  class Nav < Phlex::HTML
    def template
      nav(class: "flex text-stone-500 font-medium justify-center") do
        ul(class: "flex flex-row space-x-8") do
          li { a(class: "block border-b-4 border-x-2 py-2 px-4 rounded-b-md", href: "/articles") { "Articles" } }
          li { a(class: "block border-b-4 border-x-2 py-2 px-4 rounded-b-md", href: "/code") { "Code" } }
        end
      end
    end
  end
end