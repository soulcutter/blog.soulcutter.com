#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

$:.unshift File.expand_path("#{__dir__}/../lib")
require "site_builder"

$:.unshift File.expand_path("#{__dir__}/../pages")

require "zeitwerk"

class Build
  BASE_PATH = File.expand_path("#{__dir__}/..").freeze

  LOADER = Zeitwerk::Loader.new.tap do |loader|
    loader.push_dir File.expand_path("#{__dir__}/../pages")
    loader.enable_reloading
    loader.setup
  end


  def self.build
    SiteBuilder.build(destination: "#{BASE_PATH}/dist") do |site|
      # We need to exclude application.css because tailwindcss handles building that, and two processes
      # both trying to write that specific file is a race condition
      site.add_static_assets(directory: "#{BASE_PATH}/assets", excluding: ->(asset) { asset.path == "/application.css" })
      site.add_static_assets(directory: "#{BASE_PATH}/pages", file_pattern: "**/*.{jpg,png,gif}")
      site.add_markdown_assets(directory: "#{BASE_PATH}/pages")
      site.add_index_asset(
        site.assets_matching(/^\/articles/),
        full_path: "/articles/index.html",
        template: Articles::Index,
      )
    end
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
