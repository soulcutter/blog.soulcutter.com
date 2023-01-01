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

  # 💡 have this take a block and allow you to configure the assets within that block
  def self.build_site(assets:, pages:, destination:)
    assets.each do |asset|
      file_path = File.join(destination, asset.slug)
      asset.write(file_path)
    end

    pages.each do |asset|
      file_path = File.join(destination, asset.slug)
      asset.write(file_path)
    end
  end
end
