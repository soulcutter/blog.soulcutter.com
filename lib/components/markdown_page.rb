module Components
  class MarkdownPage < Phlex::HTML
    FRONT_MATTER_PATTERN = /^---\n(?<META>(?:\n|.)+)?\n---/

    def initialize(document)
      @document = document
      @data = YAML.load(
        document.match(FRONT_MATTER_PATTERN)["META"],
        permitted_classes: [Time]
      )
    end

    def template
      render Layout.new(title: @data["title"]) do
        h1(class: "text-3xl font-semibold my-5") { @data["title"] }
        render Markdown.new(content)
      end
    end

    def content = @document.sub(FRONT_MATTER_PATTERN, "")
  end
end
