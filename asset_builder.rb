class AssetBuilder
	def self.build_all(source_directory = "#{__dir__}/assets", destination_directory = "#{__dir__}/dist")
		assets = AssetsInDirectory.new(source_directory).assets

    # well crap, we need to exclude application.css because tailwindcss handles that
		assets.each { |asset| build_asset(asset, destination_directory) }
	end

  def self.build_asset(asset, destination_directory = "#{__dir__}/dist")
    destination = File.join(destination_directory, asset.path)
    asset.cp(destination)
  end
end