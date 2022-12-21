require "pathname"

AssetsInDirectory = Struct.new(:directory, :filename_pattern) do
  def initialize(directory, filename_pattern = "**/*") = super

  def files = Dir[directory_pattern].reject { |file| Pathname(file).directory? }    
  def directory_pattern = File.join(directory, filename_pattern)

  def assets = files.map { |file| Asset.new(file, directory) }
  alias to_a assets
  alias to_ary assets

  def recursive_copy(destination_directory:)
    assets.each do |asset|
      destination = File.join(destination_directory, asset.path)
      asset.cp(destination)
    end
  end
end
