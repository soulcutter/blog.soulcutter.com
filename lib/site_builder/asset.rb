require "pathname"

module SiteBuilder
  Asset = Struct.new(:origin) do
    attr_reader :path
    
    def initialize(origin, prefix = "") 
      super origin
      @path = origin.delete_prefix(prefix)
    end
  
    def directory = File.dirname(path)
    def read = File.read(origin)
  
    def write(destination)
       FileUtils.mkdir_p(File.dirname(destination))
       if Pathname(origin).directory?
         puts "Origin: #{origin.inspect}"
         puts "Destination: #{destination.inspect}"
         puts "WARNING: Origin #{origin.inspect}, is a directory"
       end
       FileUtils.cp(origin, destination)
    end
  end
end
