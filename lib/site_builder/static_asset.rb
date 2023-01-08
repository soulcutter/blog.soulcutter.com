module SiteBuilder
  class StaticAsset < Asset
    DATESTAMP_PATTERN = /\d{4}-\d{2}-\d{2}-/.freeze

    def write(destination)
      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.cp(full_path, destination)
    end

    def slug
      path.gsub(DATESTAMP_PATTERN, "")
    end
  end
end
