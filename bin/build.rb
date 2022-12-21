#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

require "bundler"
Bundler.require :default

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path("#{__dir__}/.."))
loader.enable_reloading
loader.setup

def build_site
  AssetBuilder.build_all
  PageBuilder.build_all
end
build_site

if ARGV.include? "--watch"
  Filewatcher.new([
    "#{__dir__}/../**/*rb", 
    "#{__dir__}/../**/*md", 
    "#{__dir__}/../assets/**/*"
  ]).watch do |_changes|
    puts "File changes: #{_changes.inspect}"
    loader.reload
    build_site
  end
end