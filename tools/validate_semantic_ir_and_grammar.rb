#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require "set"
require_relative "lib/era_zero_semantic_validation"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation
spec = EraZeroValidation.load_yaml("spec/semantic_ir_1.0.yaml")
schema = EraZeroValidation.load_yaml("spec/semantic_ir_schema.yaml")
cases = EraZeroValidation.load_yaml("tests/semantic_ir_cases.yaml")
atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
compounds_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
atom_ids = atoms_doc.fetch("atoms").map { |a| a["canonical_id"] }.to_set
compound_ids = compounds_doc.fetch("entries").map { |c| c["compound_id"] }.to_set
node_kinds = schema.fetch("node_kinds").to_set
edge_types = schema.fetch("edge_types").to_set
roles = schema.fetch("roles").to_set
forbidden = schema.fetch("forbidden_semantic_fields").to_set
units = spec.dig("quantity_and_measurement", "units").values.flatten.to_set
checks = EraZeroValidation::CheckSet.new

validate = ->(ir) { EraZeroSemanticValidation.validate(ir) }

valid_results = cases.fetch("valid_cases").to_h { |c| [c["case_id"], validate.call(c["ir"])] }
invalid_results = cases.fetch("invalid_cases").to_h { |c| [c["case_id"], validate.call(c["ir"])] }

checks.add("lexical immutability", "atomic baseline matches directly or through exact editorial reconciliation; compound fingerprint remains unchanged", EraZeroValidation.atomic_fingerprint_matches?(atoms_doc.fetch("atoms"), spec.dig("metadata", "atomic_lexicon_fingerprint")) && spec.dig("metadata", "compound_dictionary_fingerprint") == EraZeroValidation.fingerprint(compounds_doc.fetch("entries")))
checks.add("complete required scope", "IR covers every required semantic and grammar area", %w[role_system runtime_state polarity_and_scope quantity_and_measurement modality time_and_aspect composition discourse execution_semantics canonical_serialization].all? { |k| spec.key?(k) })
checks.add("dimension separation", "trit, runtime, polarity, modality, time, and aspect are explicitly independent", spec.dig("design_principles", "dimension_separation").include?("independent") && spec.dig("runtime_state", "separations").length == 4)
checks.add("role inventory", "core roles and typed extensions are explicit", roles.length >= 20 && %w[actor source cause predicate target result destination content time quantity].all? { |r| roles.include?(r) })
checks.add("negation scope", "negation is explicit and cannot be encoded as runtime zero", spec.dig("polarity_and_scope", "prohibition").include?("runtime [0]"))
checks.add("quantity and units", "canonical numbers, quantifiers, units, and none-vs-negation are specified", spec.dig("quantity_and_measurement", "quantifiers").length >= 7 && units.length >= 10 && spec.dig("quantity_and_measurement", "none_vs_negation").include?("not identical"))
checks.add("modality separation", "modality has named modes and is separate from runtime and lexical potential", spec.dig("modality", "modes").length >= 7 && spec.dig("modality", "separation").include?("not runtime"))
checks.add("time and transition", "reference-time relations, aspect, and explicit before/after states are specified", spec.dig("time_and_aspect", "relations").length >= 7 && spec.dig("time_and_aspect", "aspects").length >= 6 && spec.dig("time_and_aspect", "state_transition").include?("before_state"))
checks.add("composition", "coordination, sequence, parallelism, repetition, recursion, and conditionals are explicit", %w[coordination seriality parallelism repetition recursion conditionals].all? { |k| spec.fetch("composition").key?(k) })
checks.add("canonical identity", "serialization defines deterministic UTT content identity and excludes surface metadata", spec.dig("canonical_serialization", "content_identity").include?("SHA-256") && spec.dig("canonical_serialization", "excluded").include?("english_source"))
checks.add("valid cases", "all diverse valid conformance cases pass", valid_results.values.all?(&:empty?) && valid_results.length >= 16)
checks.add("invalid cases", "all invalid fixtures produce their required diagnostics", cases.fetch("invalid_cases").all? { |c| c["expected_errors"].to_set.subset?(invalid_results[c["case_id"]].to_set) } && invalid_results.length >= 12)
checks.add("later-gate boundary", "the semantic-IR release itself started no renderer, decoder, or translator work", spec.dig("metadata", "renderer_started") == false && spec.dig("metadata", "decoder_started") == false && spec.dig("metadata", "translator_started") == false)
checks.add("authority integration", "semantic IR remains canonical after orderly downstream progression", begin
  version = EraZeroValidation.load_yaml("spec/version.yaml")
  readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
  migration = EraZeroValidation.load_yaml("migrations/semantic_ir_and_grammar_1.0.yaml")
  gate = readiness.fetch("required_gates").find { |g| g["gate"] == "semantic_ir_and_grammar" }
  downstream = %w[deterministic_renderer_and_decoder controlled_english general_english glyph_and_audio]
  general_gate = readiness.fetch("required_gates").find { |item| item["gate"] == "general_english" }
  translator_progress_ok = readiness.dig("safe_now", "general_english_translation") == false || general_gate["status"] == "complete"
  downstream_ok = downstream.include?(version["next_gate_authorized"]) || (version["next_gate_authorized"].nil? && version["glyph_audio_status"] == "canonical")
  version["semantic_ir_status"] == "canonical" && migration["next_gate"] == "deterministic_renderer_and_decoder" && gate["status"] == "complete" && downstream_ok && translator_progress_ok
end)

report = checks.markdown(title: "Semantic IR and Executable Grammar Validation", pass_status: "PASS — BOUNDED SEMANTIC IR REGRESSION", summary: ["IR version: **#{spec.dig('metadata', 'ir_version')}**", "Valid cases: **#{valid_results.length}**", "Invalid cases: **#{invalid_results.length}**", "Canonical atoms preserved: **#{atom_ids.length}**", "Canonical compounds preserved: **#{compound_ids.length}**", "This fixture suite does not establish full translator completion."])
unless valid_results.values.all?(&:empty?)
  report << "\n## Unexpected valid-case failures\n\n"
  valid_results.each { |id, errors| report << "- `#{id}`: #{errors.join(', ')}\n" unless errors.empty? }
end
EraZeroValidation.write("reports/semantic_ir_validation.md", report)
puts "Semantic IR validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}; valid: #{valid_results.length}; invalid: #{invalid_results.length}"
checks.failures.each { |f| warn f }
exit(checks.success? ? 0 : 1)
