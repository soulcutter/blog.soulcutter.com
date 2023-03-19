module Components
  class IndexPage < Phlex::HTML
    def initialize(assets, **metadata)
      @assets = assets
      @metadata = metadata
    end

    def template
      render Layout.new(title: @metadata["title"]) do
        h1(class: "text-3xl font-semibold my-5") { @metadata["title"] }
        ul do
          @assets.each do |asset|
            li { asset.slug }
          end
        end
      end
    end
  end
end
