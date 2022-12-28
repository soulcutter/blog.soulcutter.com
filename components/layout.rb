# frozen_string_literal: true

module Components
  class Layout < Phlex::HTML
    register_element :style

    def initialize(title:)
      @title = title
    end

    def template(&block)
      doctype

      html do
        head do
          meta charset: "utf-8"
          meta name: "viewport", content: "width=device-width, initial-scale=1"

          meta name: "author", content: "Bradley Schaefer"
          meta(name: "description", content: @description) if @description
          meta(name: "keywords", content: Array(@keywords).join(",")) if @keywords

          # favicon
          # generated via https://realfavicongenerator.net/ on 2022-11-28
          link rel: "apple-touch-icon", sizes: "180x180", href: "/assets/favicon/apple-touch-icon.png"
          link rel: "icon", type: "image/png", sizes: "32x32", href: "/assets/favicon/favicon-32x32.png"
          link rel: "icon", type: "image/png", sizes: "16x16", href: "/assets/favicon/favicon-16x16.png"
          link rel: "manifest", href: "/assets/favicon/site.webmanifest"
          link rel: "mask-icon", href: "/assets/favicon/safari-pinned-tab.svg", color: "#c90058"
          link rel: "shortcut icon", href: "/assets/favicon/favicon.ico"
          meta name: "msapplication-TileColor", content: "#00aba9"
          meta name: "msapplication-config", content: "/assets/favicon/browserconfig.xml"
          meta name: "theme-color", content: "#ffffff"

          title { @title }
          link href: "/application.css", rel: "stylesheet"
          style { unsafe_raw Rouge::Theme.find("github").render(scope: ".highlight") }
        end

        body class: "text-stone-700 flex flex-col" do
          header class: "border-b py-4 px-4 lg:px-10 flex justify-between items-center" do
            div class: "flex flex-row items-center gap-2" do
              a(href: "/", class: "block") { img src: "/images/logo.png", width: "100" }
            end

            div class: "flex flex-row items-center gap-2 border-b-2" do
              h2(class: "text-4xl") { "Soulcutter" }
            end

            div class: "flex flex-row items-center gap-2" do
              a(href: "/", class: "block") { img src: "/images/logo.png", width: "100" }
            end
          end

          render Nav.new

          div class: "flex flex-row justify-center" do
            main class: "px-6 lg:px-20 py-5" do
              div(class: "max-w-full lg:max-w-prose prose", &block)
            end
          end

          render Footer.new
        end
      end
    end
  end
end