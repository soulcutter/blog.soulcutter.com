module Components
  class Footer < Phlex::HTML
    def template
      footer class: "bg-white border-t" do
        div class: "container max-w-4xl mx-auto flex py-8" do
          div class: "w-full mx-auto flex flex-wrap" do
            footer_section do
              h3(class: "font-semibold text-stone-900") { "About" }
              p class: "text-stone-600 text-sm italic" do
                "Bradley Schaefer aka Soulcutter is a software developer of over 20 years residing in Ohio, USA"
              end
            end

            footer_section do
              h3(class: "font-semibold text-stone-900") { "Social" }
              ul class: "list-reset items-center text-sm pt-3" do
                social_link(href: "https://github.com/soulcutter") { "GitHub" }
                social_link(href: "https://ruby.social/@soulcutter") { "Mastodon" }
              end
            end
          end
        end

        div class: "border-t border-stone-400 py-6 px-10 flex justify-center text-stone-500 text-lg font-medium" do
          "© Copyright 2017-2023 Bradley Schaefer"
        end
      end
    end

    def footer_section(&block)
      div class: "flex w-full md:w-1/2" do
        div(class: "px-8", &block)
      end
    end

    def social_link(href:, &block)
      li do
        a class: "inline-block text-stone-600 hover:text-stone-900 hover:underline py-1", href: href, &block
      end
    end
  end
end
