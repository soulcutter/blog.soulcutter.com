RSpec.describe SiteBuilder::Site do
  subject(:site) { SiteBuilder::Site.new }

  context "#static_assets" do
    it "filters out assets according to excludes rules" do
      site.static_assets(directory: __dir__, excluding: ->(asset) { asset.filename == "site_spec.rb" })
      # WIP
    end
  end
end