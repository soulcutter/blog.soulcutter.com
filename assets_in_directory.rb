AssetsInDirectory = Struct.new(:directory, :filename_pattern) do
  def initialize(directory, filename_pattern = "**/*") = super

  def files = Dir[directory_pattern]    
  def directory_pattern = File.join(directory, filename_pattern)

  def assets = files.map! { |file| Asset.new(file, directory) }
end
