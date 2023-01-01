require "pathname"

module SiteBuilder
  class AssetsInDirectory
    # This can only represent a set of a single `asset_type`
    def initialize(directory:, asset_type:, filename_pattern: "**/*")
      @directory = directory
      @asset_type = asset_type
      @filename_pattern = filename_pattern
      freeze
    end

    def files = Dir[File.join(@directory, @filename_pattern)].reject { |file| Pathname(file).directory? }

    def assets
      files.map { |file| @asset_type.new(full_path: file, base_path: @directory) }
    end
  end
end
