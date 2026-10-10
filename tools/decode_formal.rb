#!/usr/bin/env ruby
# frozen_string_literal: true
require "json"
require_relative "lib/era_zero_renderer"
path = ARGV.fetch(0) { abort "usage: decode_formal.rb FORMAL.json" }
puts JSON.pretty_generate(EraZeroRenderer.decode(JSON.parse(File.read(path, encoding: "UTF-8"))))
