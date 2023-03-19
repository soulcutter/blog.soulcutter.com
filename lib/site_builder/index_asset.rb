module SiteBuilder
  class IndexAsset < Asset
    def initialize(assets, **)
      super(**)
      @assets = assets
    end

    def write(destination)
      FileUtils.mkdir_p(File.dirname(destination))

      File.write(
        destination,
        Components::IndexPage.new(@assets).call(view_context: {current_page: slug})
      )
    end

    def slug = full_path
  end
end
