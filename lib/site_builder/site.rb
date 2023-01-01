module SiteBuilder
  class Site
    def initialize
      @assets = []
    end

    def static_assets(directory:, file_pattern: "**/*", excluding: Proc.new { false }) 
      files(directory, file_pattern).each do |file|
        register_asset StaticAsset.new(full_path: file, base_path: directory)
      end
    end

    def markdown_assets(directory:, file_pattern: "**/*.md")
      files(directory, file_pattern).each do |file|
        register_asset MarkdownAsset.new(full_path: file, base_path: directory)
      end
    end

    def register_asset(asset)
      @assets << asset
      # more-interesting behavior to come, I think
    end

    def build(destination)
      @assets.each do |asset|
        file_path = File.join(destination, asset.slug)
        asset.write(file_path)
      end 
    end

    private def files(directory, file_pattern) = Dir[File.join(directory, file_pattern)].reject { |file| Pathname(file).directory? }
  end
end