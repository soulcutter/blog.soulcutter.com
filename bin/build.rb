#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

$:.unshift File.expand_path("#{__dir__}/../lib")
require "site_builder"

class Build
  BASE_PATH = File.expand_path("#{__dir__}/..").freeze

  def self.build
    SiteBuilder.build(destination: "#{BASE_PATH}/dist") do |site|
      # We need to exclude application.css because tailwindcss handles building that, and two processes
      # both trying to write that specific file is a race condition
      site.add_static_assets(directory: "#{BASE_PATH}/assets", excluding: ->(asset) { asset.path == "/application.css" })
      site.add_static_assets(directory: "#{BASE_PATH}/pages", file_pattern: "**/*.{jpg,png,gif}")
      site.add_markdown_assets(directory: "#{BASE_PATH}/pages")
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
