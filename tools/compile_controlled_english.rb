#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require_relative "lib/era_zero_controlled_english"

input = ARGV.empty? ? STDIN.read : ARGV.join(" ")
result = EraZeroControlledEnglish::Compiler.new.compile(input)
puts JSON.pretty_generate(result)
exit(result["status"] == "ok" ? 0 : 2)
