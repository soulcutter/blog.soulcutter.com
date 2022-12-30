require "pathname"

AssetsInDirectory = Struct.new(:directory, :filename_pattern, :filters, keyword_init: true) do
  def initialize(directory:, filename_pattern: "**/*", filters: []) = super

  def files = Dir[directory_pattern].reject { |file| Pathname(file).directory? }    
  def directory_pattern = File.join(directory, filename_pattern)

  def assets = files.map { |file| Asset.new(file, directory) }.reject { |asset| filters.any? { |filter| filter.call(asset) } }
  alias to_a assets
  alias to_ary assets

  def reject(&block)
    raise ArgumentError unless block_given?
    self.class.new(directory: directory, filename_pattern: filename_pattern, filters: filters + [block])
  end

  def write(destination_directory)
    assets.each do |asset|
      destination = File.join(destination_directory, asset.path)
      destination = PageBuilder.strip_date_prefix destination
      asset.write(destination)
    end
  end
end
