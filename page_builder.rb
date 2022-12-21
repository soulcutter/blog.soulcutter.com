class PageBuilder
	def self.build_all(source_directory = "#{__dir__}/pages", destination_directory = "#{__dir__}/dist")
		FileUtils.mkdir_p(destination_directory)

		assets = AssetsInDirectory.new(directory: source_directory, filename_pattern: "**/*.md").assets
		assets.each { |asset| build_asset(asset, destination_directory) }
	end

	def self.build_asset(asset, destination_directory = "#{__dir__}/dist")
		new(asset, destination_directory).call
	end

	def initialize(asset, destination_directory)
		@asset = asset
		@destination_directory = destination_directory

    @path = compute_path(asset)
    freeze
	end

	def call
		FileUtils.mkdir_p(File.dirname(destination_file))
		File.write(destination_file, Components::Page.new(@asset.read).call(view_context: { current_page: @path }))
	end

	private

	def destination_file
		File.join(@destination_directory, @path, "index.html")
	end

	def compute_path(asset)
		File.join(
			asset.path.delete_suffix(".md").delete_suffix("/index").tr("_", "-"),
			"/"
		)
	end
end