module SiteBuilder
  class IndexAsset < Asset
    def initialize(assets, template: Components::IndexPage, **)
      super(**)
      @assets = assets
      @template = template
    end

    def write(destination)
      FileUtils.mkdir_p(File.dirname(destination))

      File.write(
        destination,
        @template.new(@assets).call(view_context: {current_page: slug})
      )
    end

    def slug = full_path
  end
end
