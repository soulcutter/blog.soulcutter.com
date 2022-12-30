#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

$:.unshift File.expand_path("#{__dir__}/../lib")

require "site_builder"

class Build
  BASE_PATH = File.expand_path("#{__dir__}/..").freeze
  
  def self.watch
    puts "bin/build.rb: Watching for file changes..."
    Filewatcher.new([
      "#{BASE_PATH}/lib/*.rb", 
      "#{BASE_PATH}/pages/**/*", 
      "#{BASE_PATH}/assets/**/*"
    ]).watch do |_changes|
      puts "File changes: #{_changes.inspect}"
      SiteBuilder::LOADER.reload
      SiteBuilder.build_site
    end
  end
end

SiteBuilder.build_site
Build.watch if ARGV.include? "--watch"
