require "bundler"
Bundler.require :default

module SiteBuilder
  LOADER = Zeitwerk::Loader.for_gem(warn_on_extra_files: false).tap do |loader|
    loader.enable_reloading
    loader.setup
  end

  BASE_PATH = "#{__dir__}/..".freeze
  private_constant :BASE_PATH

  def self.build_site(assets:, pages:, destination:)
    # eventually pass some post-asset-writing artifact to page-building
    assets.each { |assets| assets.write(destination) }
  
    # eventually `pages` should be a collection object and not a string
    PageBuilder.build_all(pages, destination)
  end
end
