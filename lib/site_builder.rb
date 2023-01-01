require "bundler"
Bundler.require :default

module SiteBuilder
  # We need `warn_on_extra_files` because of lib/components not matching
  # Zeitwerk's default expectation of "everything under site_builder/"
  LOADER = Zeitwerk::Loader.for_gem(warn_on_extra_files: false).tap do |loader|
    loader.enable_reloading
    loader.setup
  end

  BASE_PATH = "#{__dir__}/..".freeze
  private_constant :BASE_PATH

  def self.build(destination:)
    site = Site.new
    yield site
    site.build(destination)
  end
end
