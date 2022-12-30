#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

require "bundler"
Bundler.require :default

class Build
  BASE_PATH = "#{__dir__}/..".freeze

  LOADER = Zeitwerk::Loader.new
  LOADER.push_dir(File.expand_path(BASE_PATH))
  LOADER.enable_reloading
  LOADER.setup
  
  send def self.build_site
    asset_packs = [
      # We need to exclude application.css because tailwindcss handles building that
      AssetsInDirectory.new(directory: "#{BASE_PATH}/assets").reject { |asset| asset.path == "/application.css" },
      AssetsInDirectory.new(directory: "#{BASE_PATH}/pages", filename_pattern: "**/*.{jpg,png,gif}"),
    ].each do |assets|
      assets.write("#{BASE_PATH}/dist")
    end
  
    PageBuilder.build_all
  end  

  def self.watch
    puts "bin/build.rb: Watching for file changes..."
    Filewatcher.new([
      "#{BASE_PATH}/**/*.rb", 
      "#{BASE_PATH}/pages/**/*", 
      "#{BASE_PATH}/assets/**/*"
    ]).watch do |_changes|
      puts "File changes: #{_changes.inspect}"
      Build::LOADER.reload
      Build.build_site
    end
  end
end

Build.watch if ARGV.include? "--watch"
