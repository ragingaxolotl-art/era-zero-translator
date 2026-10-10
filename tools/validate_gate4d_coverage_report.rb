#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation
metrics = EraZeroValidation.load_yaml("reports/gate4d_coverage_metrics.yaml")
index_doc = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml")
senses = index_doc.fetch("senses")
lemmas = index_doc.fetch("lemma_index")
checks = EraZeroValidation::CheckSet.new

route_counts = senses.group_by { |s| s["route"] }.transform_values(&:length)
sum = route_counts.values.sum
checks.add("inventory", "measured inventory matches Gate 4C exactly", metrics.dig("inventory", "total_senses") == senses.length && metrics.dig("inventory", "total_lemmas") == lemmas.length)
checks.add("route partition", "all senses are partitioned exactly once by route", sum == senses.length && %w[atom compound grammar semantic_ir gap].all? { |r| route_counts.key?(r) })
checks.add("metric arithmetic", "direct, structural, and gap percentages are arithmetically correct", begin
  direct = route_counts["atom"] + route_counts["compound"]
  structural = direct + route_counts["grammar"] + route_counts["semantic_ir"]
  metrics.dig("route_coverage", "direct_lexical_percent") == (100.0 * direct / senses.length).round(2) && metrics.dig("route_coverage", "structurally_routed_percent") == (100.0 * structural / senses.length).round(2) && structural + route_counts["gap"] == senses.length
end)
checks.add("exact label coverage", "every family has 27/27 exact controlled atomic senses", metrics.fetch("family_exact_label_coverage").values.all? { |v| v["canonical_atoms"] == 27 && v["exact_controlled_senses"] == 27 && v["coverage_percent"] == 100.0 })
checks.add("compound coverage", "all approved compounds are represented in the benchmark", metrics.dig("inventory", "canonical_compound_targets") == EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries").length)
checks.add("high-frequency benchmark", "reviewed high-frequency routing counts are exhaustive", metrics.dig("high_frequency_benchmark", "by_route").values.sum == metrics.dig("high_frequency_benchmark", "senses"))
checks.add("gaps exact", "gap register matches every and only Gate 4C gap sense", metrics.fetch("gaps").length == route_counts["gap"] && metrics.fetch("gaps").map { |g| [g["lemma"], g["sense_key"]] }.sort == senses.select { |s| s["route"] == "gap" }.map { |s| [s["lemma"], s["sense_key"]] }.sort)
checks.add("ambiguity exact", "ambiguity count matches the lemma index", metrics.dig("ambiguity", "lemmas_requiring_disambiguation") == lemmas.count { |_k, v| v["requires_disambiguation"] })
checks.add("no first-match policy", "ambiguity policy forbids silent first-candidate selection", metrics.dig("ambiguity", "policy").include?("Never choose the first"))
checks.add("source immutability", "coverage report fingerprints the unchanged Gate 4C index", metrics.dig("metadata", "sense_index_fingerprint") == EraZeroValidation.fingerprint(index_doc))
checks.add("translator boundary", "the Gate 4D release began no translation and later translator progression is orderly", begin
  version = EraZeroValidation.load_yaml("spec/version.yaml")
  readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
  migration = EraZeroValidation.load_yaml("migrations/gate4d_coverage_and_ambiguity_1.0.yaml")
  general_gate = readiness.fetch("required_gates").find { |gate| gate["gate"] == "general_english" }
  translator_progress_ok = readiness.dig("safe_now", "general_english_translation") == false || general_gate["status"] == "complete"
  metrics.dig("metadata", "translator_started") == false && version["gate4d_status"] == "complete" && migration["next_gate"] == "gate4e_etymology_table" && translator_progress_ok
end)

report = checks.markdown(title: "Gate 4D Coverage and Ambiguity Validation", pass_status: "PASS — GATE 4D COMPLETE; GATE 4E MAY BEGIN", summary: ["Measured senses: **#{senses.length}**", "Measured lemmas: **#{lemmas.length}**", "Direct lexical coverage: **#{metrics.dig('route_coverage', 'direct_lexical_percent')}%**", "Explicit gaps: **#{route_counts['gap']}**", "Translator authorized: **no**"])
EraZeroValidation.write("reports/gate4d_validation.md", report)
puts "Gate 4D validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |f| warn f }
exit(checks.success? ? 0 : 1)
