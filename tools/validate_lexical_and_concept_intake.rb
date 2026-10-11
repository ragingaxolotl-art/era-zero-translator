#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require_relative "lib/era_zero_validation"

audit = EraZeroValidation.load_yaml("lexicon/lexical_pos_audit.yaml")
intake = EraZeroValidation.load_yaml("spec/concept_intake_1.0.yaml")
examples = EraZeroValidation.load_yaml("examples/concept_intake_examples.yaml")
atoms = EraZeroValidation.load_yaml("lexicon/all_atoms.yaml").fetch("atoms")
senses = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml").fetch("senses")
profile = EraZeroValidation.load_yaml("lexicon/game_story_surface_routes.yaml").fetch("senses")
checks = EraZeroValidation::CheckSet.new

root_records = audit.fetch("roots")
sense_records = audit.fetch("senses")
checks.add("root completeness", "all 324 roots occur exactly once with unchanged title and definition", root_records.length == 324 && root_records.map { |root| root.fetch("target_id") }.uniq.length == 324 && atoms.all? { |atom| (record = root_records.find { |root| root["target_id"] == atom["canonical_id"] }) && record["canonical_title"] == atom["title"] && record["invariant_definition"] == atom["core_definition"] })
checks.add("sense completeness", "all canonical and game/story senses occur exactly once", sense_records.length == senses.length + profile.length && sense_records.map { |sense| sense.fetch("sense_id") }.to_set == (senses + profile).map { |sense| sense.fetch("sense_id") }.to_set)
checks.add("POS completeness", "every sense has normalized POS and every root has address-derived affordance", sense_records.all? { |sense| !sense.fetch("part_of_speech").empty? } && root_records.all? { |root| %w[entity_like process_like relationship_like].include?(root.dig("semantic_affordance", "primary")) })
checks.add("authority boundary", "audit and intake make zero semantic changes", audit.dig("metadata", "canonical_semantic_changes") == 0 && intake["canonical_semantic_changes"] == 0 && audit.dig("metadata", "status") == "noncanonical_metadata_complete")
expected_order = %w[existing_surface existing_atom existing_compound proposed_compound semantic_ir grammar documented_gap future_era]
checks.add("DBA decision order", "intake exhausts consolidation, composition, structure, gap, and future-era routes in order", intake.fetch("decision_order").map { |route| route.fetch("id") } == expected_order)
checks.add("safe proposal lifecycle", "workflow requires review fields, explicit states, and prohibitions", intake.fetch("required_fields").length >= 9 && intake.fetch("proposal_states").include?("semantic_review") && intake.fetch("prohibitions").any? { |rule| rule.include?("automated matching") } && intake.fetch("prohibitions").any? { |rule| rule.include?("EZNAME") })
checks.add("worked routes", "examples demonstrate consolidation, composition, and honest gaps", examples.fetch("examples").map { |item| item.fetch("decision") }.to_set.superset?(%w[existing_surface proposed_compound documented_gap].to_set))

report = checks.markdown(title: "Lexical/POS and concept-intake validation", pass_status: "PASS — COMPLETE METADATA AND SAFE INTAKE WORKFLOW", summary: ["Canonical roots: **#{root_records.length}**", "Audited English senses: **#{sense_records.length}**", "Decision routes: **#{expected_order.length}**", "Canonical semantic changes: **0**"])
EraZeroValidation.write("reports/lexical_and_concept_intake_validation.md", report)
puts "Lexical/concept intake: #{checks.success? ? 'PASS' : 'FAIL'} · #{checks.passed} checks"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
