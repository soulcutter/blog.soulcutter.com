#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

BASE_PATH = File.expand_path("#{__dir__}/..")

$:.unshift File.join(BASE_PATH, "lib")

require "site_builder"

class Build
  BASE_PATH = File.expand_path("#{__dir__}/..").freeze

  def self.build
    assets = [
      # We need to exclude application.css because tailwindcss handles building that
      SiteBuilder::AssetsInDirectory.new(asset_type: SiteBuilder::StaticAsset, directory: "#{BASE_PATH}/assets").reject { |asset| asset.path == "/application.css" },
      SiteBuilder::AssetsInDirectory.new(asset_type: SiteBuilder::StaticAsset, directory: "#{BASE_PATH}/pages", filename_pattern: "**/*.{jpg,png,gif}"),
    ]
    markdown_pages = SiteBuilder::AssetsInDirectory.new(asset_type: SiteBuilder::MarkdownAsset, directory: "#{BASE_PATH}/pages", filename_pattern: "**/*.md")
    SiteBuilder.build_site(assets: assets, pages: [markdown_pages], destination: "#{BASE_PATH}/dist")
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
