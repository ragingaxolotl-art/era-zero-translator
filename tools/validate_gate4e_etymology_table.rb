#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation
table = EraZeroValidation.load_yaml("lexicon/etymology_table.yaml")
schema = EraZeroValidation.load_yaml("spec/etymology_schema.yaml")
tests = EraZeroValidation.load_yaml("tests/gate4e_etymology_cases.yaml")
atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
atoms = atoms_doc.fetch("atoms")
atom_map = atoms.to_h { |a| [a["canonical_id"], a] }
compounds_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
compounds = compounds_doc.fetch("entries")
compound_map = compounds.to_h { |c| [c["compound_id"], c] }
rows = table.fetch("entries")
atom_rows = rows.select { |r| r["target_type"] == "atom" }
compound_rows = rows.select { |r| r["target_type"] == "compound" }
checks = EraZeroValidation::CheckSet.new

checks.add("inventory", "table contains exactly one derivation for all 324 atoms and all approved compounds", atom_rows.length == 324 && compound_rows.length == compounds.length && rows.map { |r| [r["target_type"], r["target_id"]] }.uniq.length == rows.length)
checks.add("target coverage", "target sets match authority exactly", atom_rows.map { |r| r["target_id"] }.to_set == atom_map.keys.to_set && compound_rows.map { |r| r["target_id"] }.to_set == compound_map.keys.to_set)
checks.add("unique etymology ids", "every derivation has one unique ETY identity", rows.map { |r| r["etymology_id"] }.uniq.length == rows.length && rows.all? { |r| r["etymology_id"].match?(/\AETY:[0-9a-f]{24}\z/) })
checks.add("required fields", "all rows satisfy common and type-specific schema fields", rows.all? do |r|
  common = schema.fetch("required_common_fields").to_set.subset?(r.keys.to_set)
  type = (r["target_type"] == "atom" ? schema["atom_required_fields"] : schema["compound_required_fields"]).to_set.subset?(r.keys.to_set)
  common && type
end)
checks.add("atomic forms exact", "compact roots, transliterations, carriers, harmony, and note paths are copied exactly", atom_rows.all? do |r|
  a = atom_map.fetch(r["target_id"])
  r.dig("form_derivation", "local_compact_root") == a["local_compact_root"] && r.dig("form_derivation", "family_qualified_transliteration") == a["canonical_transliteration"] && r.dig("form_derivation", "formal_carrier") == a["formal_carrier"] && r.dig("family_derivation", "harmonic_signature_semitones") == a["harmonic_signature_semitones"] && r.dig("form_derivation", "relative_note_path_semitones") == a["note_path_semitones"]
end)
checks.add("atomic semantics exact", "every invariant definition is copied without change", atom_rows.all? { |r| r.dig("semantic_derivation", "invariant_definition") == atom_map.fetch(r["target_id"])["core_definition"] })
checks.add("source authority partition", "36 source-canonical and 288 reviewed atoms are distinguished exactly", tests.fetch("source_canonical_targets").length == 36 && tests.fetch("reviewed_targets").length == 288 && atom_rows.count { |r| r.dig("semantic_derivation", "provenance", "authority") == "source_canonical" } == 36 && atom_rows.count { |r| r.dig("semantic_derivation", "provenance", "authority") == "reviewed_canonical" } == 288)
checks.add("review provenance", "every reviewed atom names its effective approval migration", atom_rows.select { |r| r.dig("semantic_derivation", "provenance", "authority") == "reviewed_canonical" }.all? { |r| r.dig("semantic_derivation", "provenance", "approval_migration").to_s.start_with?("migrations/") })
checks.add("compound graphs exact", "head, components, relations, digest, and definition match Gate 4B", compound_rows.all? do |r|
  c = compound_map.fetch(r["target_id"])
  r.dig("semantic_derivation", "conventional_meaning") == c["conventional_meaning"] && r.dig("provenance", "record") == c.fetch("approval_record", "migrations/gate4b_compound_dictionary_1.0.yaml") && r["components"] == c["nodes"] && r["relations"] == c["edges"] && r.dig("identity_derivation", "content_digest") == c["content_digest"] && r.dig("semantic_derivation", "invariant_definition") == c["invariant_definition"]
end)
checks.add("English independence", "every English label is explicitly non-identifying metadata", rows.all? { |r| r["english_label_status"].include?("not_") })
checks.add("no fictional ancestry", "every row rejects invented historical claims", rows.all? { |r| r["historical_claim"].include?("No ") })
checks.add("fingerprint immutability", "atomic baseline matches directly or through exact editorial reconciliation; compound fingerprint remains exact", EraZeroValidation.atomic_fingerprint_matches?(atoms, table.dig("metadata", "atomic_lexicon_fingerprint")) && table.dig("metadata", "compound_dictionary_fingerprint") == EraZeroValidation.fingerprint(compounds))
checks.add("authority integration", "Gate 4 remains complete, its migration records the semantic-IR handoff, and later translation is orderly", begin
  version = EraZeroValidation.load_yaml("spec/version.yaml")
  readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
  gate2 = readiness.fetch("required_gates").find { |g| g["gate"] == "compound_and_coverage" }
  migration = EraZeroValidation.load_yaml("migrations/gate4e_etymology_table_1.0.yaml")
  general_gate = readiness.fetch("required_gates").find { |gate| gate["gate"] == "general_english" }
  translator_progress_ok = readiness.dig("safe_now", "general_english_translation") == false || general_gate["status"] == "complete"
  version["gate4e_status"] == "canonical" && migration["next_gate"] == "semantic_ir_and_grammar" && gate2["status"] == "complete" && gate2.fetch("subgates").all? { |g| g["status"] == "complete" } && translator_progress_ok
end)

report = checks.markdown(title: "Gate 4E Formal Etymology Validation", pass_status: "PASS — GATE 4 COMPOUND AND COVERAGE COMPLETE; SEMANTIC IR MAY BEGIN", summary: ["Atomic derivations: **#{atom_rows.length}**", "Compound derivations: **#{compound_rows.length}**", "Source-canonical atoms: **36**", "Reviewed-canonical atoms: **288**", "Semantic or generated-form changes: **0**", "Translator authorized: **no**"])
EraZeroValidation.write("reports/gate4e_validation.md", report)
puts "Gate 4E validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |f| warn f }
exit(checks.success? ? 0 : 1)
