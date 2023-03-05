RSpec.describe SiteBuilder::Site do
  subject(:site) { SiteBuilder::Site.new }

  context "#static_assets" do
    it "filters out assets according to excludes rules" do
      filter = ->(asset) { asset.filename == "site_spec.rb" }
      site.static_assets(directory: __dir__, excluding: filter)
      expect(site.asset_at(/site_spec/)).to be_nil
    end

    it "registers assets in the directory" do
      site.static_assets(directory: __dir__)
      expect(site.asset_at(/site_spec/)).to be
    end
  end

  context "#asset_at(destination)" do
    it "return the first asset matching the destination" do
      asset = SiteBuilder::StaticAsset.new(full_path: "/dev/null")
      site.register_asset(asset)
      expect(site.asset_at("nonsense")).to be_nil
      expect(site.asset_at(asset.slug)).to eq(asset)
      expect(site.asset_at(/dev/)).to eq(asset)
      expect(
        site.asset_at(->(slug) { slug.end_with? "null" })
      ).to eq(asset)
    end
  end
end
