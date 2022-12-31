module SiteBuilder
  class StaticAsset < Asset
    def write(destination)
      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.cp(full_path, destination)
    end

    def slug
      path
    end
  end
end