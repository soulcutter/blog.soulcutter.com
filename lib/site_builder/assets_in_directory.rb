require "pathname"

module SiteBuilder
  AssetsInDirectory = Struct.new(:directory, :filename_pattern, :filters, :asset_type, keyword_init: true) do
    # This can only represent a set of a single `asset_type`
    def initialize(directory:, asset_type:, filename_pattern: "**/*", filters: []) = super

    def files = Dir[directory_pattern].reject { |file| Pathname(file).directory? }

    def directory_pattern = File.join(directory, filename_pattern)

    def assets
      files.map { |file| asset_type.new(full_path: file, base_path: directory) }.reject { |asset| filters.any? { |filter| filter.call(asset) } }
    end

    def reject(&block)
      raise ArgumentError unless block
      self.class.new(directory: directory, filename_pattern: filename_pattern, asset_type: asset_type, filters: filters + [block])
    end

    def write(destination_directory)
      assets.each do |asset|
        destination = File.join(destination_directory, asset.slug)
        asset.write(destination)
      end
    end
  end
end
