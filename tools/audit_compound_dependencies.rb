#!/usr/bin/env ruby
# frozen_string_literal: true
require_relative "lib/era_zero_validation"
require_relative "lib/era_zero_compound_dependencies"

entries = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries")
inventory = EraZeroCompoundDependencies::Registry.new(entries).inventory
puts JSON.pretty_generate({
  "compound_count" => inventory.length,
  "maximum_dependency_depth" => inventory.map { |entry| entry.fetch("depth") }.max || 0,
  "scope" => "Dependency integrity only; not semantic coverage or renderer readiness.",
  "dependency_order" => inventory
})
