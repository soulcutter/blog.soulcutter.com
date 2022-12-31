require "bundler"
Bundler.require :default

module SiteBuilder
  LOADER = Zeitwerk::Loader.for_gem(warn_on_extra_files: false).tap do |loader|
    loader.enable_reloading
    loader.setup
  end

  BASE_PATH = "#{__dir__}/..".freeze
  private_constant :BASE_PATH

  def self.site
    Site.new
  end

  # 💡 have this take a block and allow you to configure the assets within that block
  def self.build_site(assets:, pages:, destination:)
    # eventually pass some post-asset-writing artifact to page-building
    assets.each { |asset| asset.write(destination) }
  
    pages.each { |asset| asset.write(destination) }
  end
end
