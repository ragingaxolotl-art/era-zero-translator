#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require_relative "lib/era_zero_general_english"

translator = EraZeroGeneralEnglish::Translator.new
if ARGV.first == "--resolve"
  selection_path = ARGV[1] or abort "usage: translate_general_english.rb --resolve SELECTION.json INPUT"
  selection = JSON.parse(File.read(selection_path, encoding: "UTF-8"))
  input = ARGV.drop(2).join(" ")
  result = translator.resolve(input, sense_id: selection.fetch("sense_id"), runtime_state: selection.fetch("runtime_state"), speech_act: selection.fetch("speech_act", "assertion"), roles: selection.fetch("roles", {}))
else
  input = ARGV.empty? ? STDIN.read : ARGV.join(" ")
  result = translator.analyze(input)
end
puts JSON.pretty_generate(result)
exit(result["status"] == "error" ? 2 : 0)
