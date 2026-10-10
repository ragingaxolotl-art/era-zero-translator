#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)

families = {
  "LIF" => ["ni", [0, 4, 7]],
  "MOV" => ["gi", [0, 2, 7]],
  "MAT" => ["ba", [0, 7, 12]],
  "MIN" => ["si", [0, 3, 7]],
  "CON" => ["wu", [0, 4, 7, 9]],
  "STR" => ["do", [0, 5, 7]],
  "WRN" => ["da", [0, 3, 6]],
  "REP" => ["ya", [0, 3, 7, 9]],
  "LOG" => ["te", [0, 4, 8]],
  "DAT" => ["li", [0, 4, 7, 11]],
  "CRE" => ["ga", [0, 3, 7, 11]],
  "ORI" => ["nu", [0, 1, 7]]
}
slots = {
  "000" => "stable inward entity", "001" => "active inward entity", "002" => "dormant inward entity",
  "010" => "stable outward entity", "011" => "active outward entity", "012" => "dormant outward entity",
  "020" => "stable collective entity", "021" => "active collective entity", "022" => "dormant collective entity",
  "100" => "completed inward process", "101" => "active inward process", "102" => "pending inward process",
  "110" => "completed outward process", "111" => "active outward process", "112" => "pending outward process",
  "120" => "completed systemic process", "121" => "active systemic process", "122" => "pending systemic process",
  "200" => "stable inward capacity", "201" => "active inward capacity", "202" => "dormant inward capacity",
  "210" => "stable outward relationship", "211" => "active outward relationship", "212" => "unresolved outward relationship",
  "220" => "stable systemic relationship", "221" => "active systemic relationship", "222" => "unrealized systemic possibility"
}
initials = { "0" => "n", "1" => "k", "2" => "m" }
vowels = { "0" => "a", "1" => "o", "2" => "i" }
finals = { "0" => "m", "1" => "k", "2" => "n" }
carriers = { "0" => "ma", "1" => "ki", "2" => "nu" }
movements = { "0" => 0, "1" => 2, "2" => -2 }

canonical_source = YAML.load_file(File.join(ROOT, "lexicon/completed_atoms.yaml")).fetch("atoms")
provisional = YAML.load_file(File.join(ROOT, "lexicon/provisional_atoms.yaml")).fetch("atoms")
atoms_document = YAML.load_file(File.join(ROOT, "lexicon/atoms.yaml"))
atoms = atoms_document.fetch("atoms")
standard = YAML.load_file(File.join(ROOT, "spec/era_zero_core_standard_1.0.0.yaml"))
migration = YAML.load_file(File.join(ROOT, "migrations/1.0.0-canonization.yaml"))
issues = YAML.load_file(File.join(ROOT, "extraction/unresolved_issues_core_1.0.0.yaml")).fetch("issues")

checks = []
check = lambda { |name, passed, detail| checks << [name, passed, detail] }

expected_ids = families.keys.flat_map { |family| (0..26).map { |n| "#{family}:#{n.to_s(3).rjust(3, '0')}" } }
ids = atoms.map { |atom| atom.fetch("canonical_id") }

check.call("standard identity", standard.dig("metadata", "version") == "1.0.0" && standard.dig("metadata", "status") == "canonical", "Era Zero Core Standard 1.0.0 is the canonical specification")
check.call("canonical inventory metadata", atoms_document.dig("metadata", "version") == "1.0.0" && atoms_document.dig("metadata", "status") == "canonical", "lexicon/atoms.yaml identifies version 1.0.0")
check.call("324 canonical records", atoms.length == 324 && atoms.all? { |atom| atom["status"] == "canonical" }, "#{atoms.length} canonical records")
check.call("complete unique address set", ids.sort == expected_ids.sort && ids.uniq.length == 324, "#{ids.uniq.length} unique IDs; #{expected_ids.length - (expected_ids & ids).length} missing")
check.call("27 roots per family", families.keys.all? { |family| atoms.count { |atom| atom["family"] == family } == 27 }, families.keys.map { |f| "#{f}=#{atoms.count { |a| a['family'] == f }}" }.join(", "))
check.call("source-canonical objects unchanged", (atoms & canonical_source).length == canonical_source.length, "all #{canonical_source.length} extracted records retained exactly")

promoted_ids = provisional.map { |atom| atom.fetch("canonical_id") }
promoted = atoms.select { |atom| promoted_ids.include?(atom.fetch("canonical_id")) }
definition_changes = promoted.reject do |atom|
  source = provisional.find { |candidate| candidate["canonical_id"] == atom["canonical_id"] }
  source["core_definition"] == atom["core_definition"]
end
check.call("no semantic definition drift", definition_changes.empty?, definition_changes.empty? ? "all 288 promoted definitions match the reviewed proposals" : definition_changes.map { |a| a["canonical_id"] }.join(", "))
check.call("promotion provenance", promoted.length == 288 && promoted.all? { |atom| atom.dig("canonization", "standard") == "Era Zero Core Standard 1.0.0" }, "#{promoted.length} promoted records carry canonization metadata")
check.call("specific neighbor exclusions", promoted.all? { |atom| atom.fetch("neighbor_contrast_notes").length == 2 && atom.fetch("distinctions_and_exclusions").length >= 5 }, "all promoted records distinguish both stable/active/potential siblings")

algorithm_failures = []
atoms.each do |atom|
  family = atom.fetch("family")
  address = atom.fetch("address")
  onset, harmony = families.fetch(family)
  root = "#{initials.fetch(address[0])}#{vowels.fetch(address[1])}#{finals.fetch(address[2])}"
  carrier = ([onset] + address.chars.map { |trit| carriers.fetch(trit) }).join("-")
  path = address.chars.each_with_object([0]) { |trit, values| values << values.last + movements.fetch(trit) }
  algorithm_failures << "#{atom['canonical_id']}: onset" unless atom["family_onset"] == onset
  algorithm_failures << "#{atom['canonical_id']}: harmony" unless atom["harmonic_signature_semitones"] == harmony
  algorithm_failures << "#{atom['canonical_id']}: slot" unless atom["universal_slot"] == slots.fetch(address)
  algorithm_failures << "#{atom['canonical_id']}: compact" unless atom["local_compact_root"] == root
  algorithm_failures << "#{atom['canonical_id']}: transliteration" unless atom["canonical_transliteration"] == "#{onset}·#{root}"
  algorithm_failures << "#{atom['canonical_id']}: carrier" unless atom["formal_carrier"] == carrier
  algorithm_failures << "#{atom['canonical_id']}: path" unless atom["note_path_semitones"] == path
end
check.call("all accepted encoding algorithms", algorithm_failures.empty?, algorithm_failures.empty? ? "2,268 atom-field assertions passed" : algorithm_failures.first(20).join("; "))

duplicate_titles = atoms.group_by { |atom| atom["title"] }.select { |_title, records| records.length > 1 }
duplicate_definitions = atoms.group_by { |atom| atom["core_definition"] }.select { |_definition, records| records.length > 1 }
check.call("globally unique titles", duplicate_titles.empty?, duplicate_titles.empty? ? "no exact title duplicates" : duplicate_titles.keys.join(", "))
check.call("globally unique definitions", duplicate_definitions.empty?, duplicate_definitions.empty? ? "no exact definition duplicates" : duplicate_definitions.keys.first(10).join(" | "))

ori002 = atoms.find { |atom| atom["canonical_id"] == "ORI:002" }
check.call("ORI:002 resolution", ori002 && ori002["canonical_transliteration"] == "nu·nan" && ori002["title"] == "latent first condition", "ORI:002 is nu·nan, latent first condition")
check.call("runtime num separation", standard.dig("resolved_decisions", "runtime_state_2", "canonical_name") == "num" && standard.dig("resolved_decisions", "runtime_state_2", "distinct_from") == "ORI:002", "num is runtime state 2, distinct from ORI:002")

resolved_ids = issues.select { |issue| issue["status"] == "resolved_in_core_1.0.0" }.map { |issue| issue["issue_id"] }
check.call("resolved issue snapshot", %w[EZ-UNRES-0001 EZ-UNRES-0009].all? { |id| resolved_ids.include?(id) }, "Origin/num and Motion approval issues are resolved in the 1.0.0 snapshot")
check.call("migration coverage", migration.fetch("promoted_records").sort == promoted_ids.sort, "#{migration.fetch('promoted_records').length} promoted IDs recorded")
check.call("title changes are non-semantic", migration.fetch("semantic_definition_changes").empty? && migration.fetch("title_clarifications").length == 13, "13 label clarifications and 0 definition changes")

chunk_files = Dir[File.join(ROOT, "reports/core_1.0.0_chunks/*.md")]
check.call("canonical chunk files", chunk_files.length == 32, "#{chunk_files.length} canonical post-Phase-1 chunk files")
check.call("zero atomic gaps", standard.dig("inventory", "missing_roots") == 0 && standard.dig("inventory", "provisional_roots") == 0, "no missing or provisional atomic roots")
check.call("provisional history preserved", provisional.length == 288 && File.exist?(File.join(ROOT, "reports/phase2_chunk_review.md")), "Phase 2 proposal records remain available for audit history")
check.call("translator still deferred", !File.exist?(File.join(ROOT, "translator")) && Dir[File.join(ROOT, "**/*english_parser*")].empty?, "no English translator or parser was generated")

passed = checks.count { |_name, ok, _detail| ok }
failed = checks.length - passed
lines = [
  "# Era Zero Core Standard 1.0.0 Validation Report",
  "",
  "- Checks passed: **#{passed}**",
  "- Checks failed: **#{failed}**",
  "- Atom-field algorithm assertions: **2,268**",
  ""
]
checks.each do |name, ok, detail|
  lines << "## #{ok ? 'PASS' : 'FAIL'} — #{name}"
  lines << ""
  lines << detail
  lines << ""
end
lines << "## Conclusion"
lines << ""
lines << (failed.zero? ? "Era Zero Core Standard 1.0.0 passes the atomic-lexicon canonization gate: all 324 roots are canonical, generated encodings are valid, the source-approved 36 are unchanged, and the proposal history remains preserved." : "Validation failed. Core Standard 1.0.0 must not be treated as frozen until the failures are corrected.")
File.write(File.join(ROOT, "reports/core_1.0.0_validation.md"), lines.join("\n"), encoding: "UTF-8")

puts "#{passed} checks passed; #{failed} checks failed."
exit(failed.zero? ? 0 : 1)
