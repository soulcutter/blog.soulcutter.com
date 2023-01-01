#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true


$:.unshift File.expand_path("#{__dir__}/../lib")
require "site_builder"

class Build
  BASE_PATH = File.expand_path("#{__dir__}/..").freeze

  def self.build
    # We need to exclude application.css because tailwindcss handles building that, and two processes
    # both trying to write that specific file is a race condition
    static_assets = SiteBuilder::AssetsInDirectory.new(asset_type: SiteBuilder::StaticAsset, directory: "#{BASE_PATH}/assets").assets.reject { |asset| asset.path == "/application.css" }
    static_assets += SiteBuilder::AssetsInDirectory.new(asset_type: SiteBuilder::StaticAsset, directory: "#{BASE_PATH}/pages", filename_pattern: "**/*.{jpg,png,gif}").assets
    markdown_pages = SiteBuilder::AssetsInDirectory.new(asset_type: SiteBuilder::MarkdownAsset, directory: "#{BASE_PATH}/pages", filename_pattern: "**/*.md").assets

    SiteBuilder.build_site(assets: static_assets + markdown_pages, destination: "#{BASE_PATH}/dist")
  end
  
  def self.watch
    puts "bin/build.rb: Watching for file changes..."
    Filewatcher.new([
      "#{BASE_PATH}/lib/**/*.rb", 
      "#{BASE_PATH}/pages/**/*", 
      "#{BASE_PATH}/assets/**/*"
    ]).watch do |_changes|
      puts "File changes: #{_changes.inspect}"
      SiteBuilder::LOADER.reload
      build
    end
  end
end

Build.build
Build.watch if ARGV.include? "--watch"
