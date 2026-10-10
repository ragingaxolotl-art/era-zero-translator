#!/usr/bin/env ruby
# frozen_string_literal: true
require "json"
require "yaml"
require_relative "lib/era_zero_renderer"
path = ARGV.fetch(0) { abort "usage: render_ir.rb IR.(yaml|json) [anchor_midi]" }
input = File.read(path, encoding: "UTF-8")
ir = path.end_with?(".json") ? JSON.parse(input) : YAML.safe_load(input)
puts JSON.pretty_generate(EraZeroRenderer.render(ir, anchor_midi: Integer(ARGV[1] || 60)))
