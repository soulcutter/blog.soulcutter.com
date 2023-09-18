RSpec.describe SiteBuilder::Site do
  subject(:site) { SiteBuilder::Site.new }

  context "#add_static_assets" do
    it "filters out assets according to excludes rules" do
      filter = ->(asset) { asset.filename == "site_spec.rb" }
      site.add_static_assets(directory: __dir__, excluding: filter)
      expect(site.asset_at(/site_spec/)).to be_nil
    end

    it "registers assets in the directory" do
      site.add_static_assets(directory: __dir__)
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

  specify "#slugs" do
    asset = SiteBuilder::StaticAsset.new(full_path: "/dev/null")
    expect(asset.slug).to eq "/dev/null"
    site.register_asset(asset)
    site.register_asset(SiteBuilder::StaticAsset.new(full_path: "/srv/www/images/fox.png"))

    expect(site.slugs).to match_array(["/dev/null", "/srv/www/images/fox.png"])
  end

  context "#add_index_asset" do
    it "creates an index page" do
      site.add_static_assets(directory: __dir__)
      site.add_index_asset(site.assets, full_path: "/spec/index.html")
      expect(site.asset_at("/spec/index.html")).to be_an_instance_of SiteBuilder::IndexAsset
    end
  end
end
