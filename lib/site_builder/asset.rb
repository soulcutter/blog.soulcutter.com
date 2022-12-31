require "pathname"

module SiteBuilder
  class Asset
    attr_reader :full_path
    attr_reader :base_path
    attr_reader :filename
    attr_reader :directory
    attr_reader :path

    def initialize(full_path:, base_path: "")
      @full_path = full_path
      @base_path = base_path
      @path = full_path.delete_prefix(base_path)
      @directory, @filename = *File.split(path)

      if Pathname(full_path).directory?
        puts "WARNING: full_path is a directory"
        puts "full_path: #{full_path.inspect}"
      end
    end

    def read = File.read(full_path)

    def slug
      raise NotImplementedError
    end

    def write(destination)
      raise NotImplementedError
    end
  end
end
