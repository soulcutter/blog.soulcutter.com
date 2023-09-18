module SiteBuilder
  class Site
    def initialize
      @assets = Set.new
      @site_map = {}
    end

    def add_static_assets(directory:, file_pattern: "**/*", excluding: proc { false })
      assets = files(directory, file_pattern).map do |file|
        StaticAsset.new(full_path: file, base_path: directory)
      end
      assets.reject(&excluding).each { |asset| register_asset asset }
    end

    def add_markdown_assets(directory:, file_pattern: "**/*.md")
      files(directory, file_pattern).each do |file|
        register_asset MarkdownAsset.new(full_path: file, base_path: directory)
      end
    end

    def add_index_asset(assets, full_path:, template: Components::IndexPage)
      register_asset IndexAsset.new(assets, full_path: full_path, template: template)
    end

    def register_asset(asset)
      @assets << asset
      @site_map[asset.slug] = asset
    end

    def assets_matching(destination)
      @assets.select { |asset| destination === asset.slug }
    end

    def asset_at(destination)
      @assets.find { |asset| destination === asset.slug }
    end

    def build(destination)
      @assets.each do |asset|
        file_path = File.join(destination, asset.slug)
        asset.write(file_path)
      end
    end

    def slugs = @site_map.keys.freeze

    def assets = @assets.dup

    private def files(directory, file_pattern) = Dir[File.join(directory, file_pattern)].reject { |file| Pathname(file).directory? }
  end
end
