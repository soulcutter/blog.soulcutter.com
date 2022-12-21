Asset = Struct.new(:path) do
  def initialize(origin, prefix = "") 
    super origin.delete_prefix(prefix)
    @origin = origin
  end

  def directory = File.dirname(path)
  def read = File.read(@origin)

  def cp(destination)
     FileUtils.mkdir_p(File.dirname(destination))
     FileUtils.cp(@origin, destination)
  end
end
