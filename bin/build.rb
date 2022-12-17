#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

require "bundler"
Bundler.require :default

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path("#{__dir__}/.."))
loader.enable_reloading
loader.setup

PageBuilder.build_all

if ARGV.include? "--watch"
  Filewatcher.new(["#{__dir__}/../**/*rb", "#{__dir__}/**/*md"]).watch do |_changes|
    loader.reload
    PageBuilder.build_all
  end
end