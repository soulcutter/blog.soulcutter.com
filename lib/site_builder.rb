require "bundler"
Bundler.require :default

module SiteBuilder
  BASE_PATH = "#{__dir__}/..".freeze

  LOADER = Zeitwerk::Loader.for_gem(warn_on_extra_files: false).tap do |loader|
    loader.enable_reloading
    loader.setup
  end

  def self.build_site
    asset_packs = [
      # We need to exclude application.css because tailwindcss handles building that
      AssetsInDirectory.new(directory: "#{BASE_PATH}/assets").reject { |asset| asset.path == "/application.css" },
      AssetsInDirectory.new(directory: "#{BASE_PATH}/pages", filename_pattern: "**/*.{jpg,png,gif}"),
    ].each do |assets|
      assets.write("#{BASE_PATH}/dist")
    end
  
    PageBuilder.build_all("#{BASE_PATH}/pages", "#{BASE_PATH}/dist")
  end
end
