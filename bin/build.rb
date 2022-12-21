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
  
  def self.build_site
    asset_packs = [
      # well crap, we need to exclude application.css because tailwindcss handles that
      # otherwise we get some race conditions with what's in that file
      AssetsInDirectory.new("#{BASE_PATH}/assets"),
      AssetsInDirectory.new("#{BASE_PATH}/pages", "**/*.{jpg,png,gif}"),
    ].each do |assets|
      assets.recursive_copy(destination_directory: "#{BASE_PATH}/dist")
    end
  
    PageBuilder.build_all
  end  
end

Build.build_site

if ARGV.include? "--watch"
  puts "bin/build.rb: Watching for file changes..."
  Filewatcher.new([
    "#{Build::BASE_PATH}/**/*.rb", 
    "#{Build::BASE_PATH}/pages/**/*", 
    "#{Build::BASE_PATH}/assets/**/*"
  ]).watch do |_changes|
    puts "File changes: #{_changes.inspect}"
    Build::LOADER.reload
    Build.build_site
  end
end