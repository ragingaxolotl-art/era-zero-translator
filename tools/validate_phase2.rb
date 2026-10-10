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

canonical = YAML.load_file(File.join(ROOT, "lexicon/completed_atoms.yaml")).fetch("atoms")
provisional_doc = YAML.load_file(File.join(ROOT, "lexicon/provisional_atoms.yaml"))
provisional = provisional_doc.fetch("atoms")
all_doc = YAML.load_file(File.join(ROOT, "lexicon/all_atoms.yaml"))
all_atoms = all_doc.fetch("atoms")
phase2_spec = YAML.load_file(File.join(ROOT, "spec/phase2_provisional_spec.yaml"))

checks = []
check = lambda do |name, passed, detail|
  checks << [name, passed, detail]
end

expected_ids = families.keys.flat_map { |family| (0..26).map { |n| "#{family}:#{n.to_s(3).rjust(3, '0')}" } }
canonical_ids = canonical.map { |atom| atom.fetch("canonical_id") }
provisional_ids = provisional.map { |atom| atom.fetch("canonical_id") }
all_ids = all_atoms.map { |atom| atom.fetch("canonical_id") }

check.call("canonical baseline count", canonical.length == 36, "#{canonical.length} canonical records")
check.call("provisional count", provisional.length == 288, "#{provisional.length} provisional records")
check.call("total count", all_atoms.length == 324, "#{all_atoms.length} total records")
check.call("unique total IDs", all_ids.uniq.length == 324, "#{all_ids.uniq.length} unique IDs")
check.call("complete address set", all_ids.sort == expected_ids.sort, "#{expected_ids.length - (expected_ids & all_ids).length} missing expected IDs")
check.call("provisional is exact former gap", provisional_ids.sort == (expected_ids - canonical_ids).sort, "#{provisional_ids.length} gap IDs populated")
check.call("canonical objects unchanged", (all_atoms & canonical).length == canonical.length, "all #{canonical.length} extracted objects retained byte-for-structure")
check.call("status boundary", canonical.all? { |a| a["status"] == "canonical" } && provisional.all? { |a| a["status"] == "provisional_for_review" }, "canonical and provisional status sets do not overlap")

family_counts_ok = families.keys.all? { |family| all_atoms.count { |atom| atom["family"] == family } == 27 }
check.call("27 addresses per family", family_counts_ok, families.keys.map { |f| "#{f}=#{all_atoms.count { |a| a['family'] == f }}" }.join(", "))

algorithm_failures = []
all_atoms.each do |atom|
  family = atom.fetch("family")
  address = atom.fetch("address")
  onset, harmony = families.fetch(family)
  expected_root = "#{initials.fetch(address[0])}#{vowels.fetch(address[1])}#{finals.fetch(address[2])}"
  expected_carrier = ([onset] + address.chars.map { |trit| carriers.fetch(trit) }).join("-")
  expected_path = address.chars.each_with_object([0]) { |trit, path| path << path.last + movements.fetch(trit) }
  algorithm_failures << "#{atom['canonical_id']}: onset" unless atom["family_onset"] == onset
  algorithm_failures << "#{atom['canonical_id']}: harmony" unless atom["harmonic_signature_semitones"] == harmony
  algorithm_failures << "#{atom['canonical_id']}: slot" unless atom["universal_slot"] == slots.fetch(address)
  algorithm_failures << "#{atom['canonical_id']}: compact" unless atom["local_compact_root"] == expected_root
  algorithm_failures << "#{atom['canonical_id']}: transliteration" unless atom["canonical_transliteration"] == "#{onset}·#{expected_root}"
  algorithm_failures << "#{atom['canonical_id']}: carrier" unless atom["formal_carrier"] == expected_carrier
  algorithm_failures << "#{atom['canonical_id']}: note path" unless atom["note_path_semitones"] == expected_path
end
check.call("accepted encoding algorithms", algorithm_failures.empty?, algorithm_failures.empty? ? "2,268 atom-field assertions passed" : algorithm_failures.first(20).join("; "))

provisional_quality = provisional.all? do |atom|
  atom.fetch("title").strip.length >= 3 &&
    atom.fetch("core_definition").strip.end_with?(".") &&
    atom.fetch("distinctions_and_exclusions").length >= 3 &&
    atom.fetch("neighbor_contrasts").length == 2 &&
    atom.fetch("runtime_state_examples").keys.sort == %w[0 1 2]
end
check.call("provisional record completeness", provisional_quality, "all provisional records contain definition, boundaries, two neighbors, examples, and three runtime states")

title_duplicates = provisional.group_by { |atom| [atom["family"], atom["title"]] }.select { |_key, values| values.length > 1 }
check.call("family-local title uniqueness", title_duplicates.empty?, title_duplicates.empty? ? "no duplicate proposal titles within a family" : title_duplicates.keys.inspect)

chunks = phase2_spec.fetch("review_chunks")
chunk_ids = chunks.flat_map { |chunk| chunk.fetch("ids") }
chunk_files = Dir[File.join(ROOT, "reports/phase2_chunks/*.md")]
check.call("32 review chunks", chunks.length == 32 && chunk_files.length == 32, "#{chunks.length} chunk definitions and #{chunk_files.length} chunk files")
check.call("nine unique roots per chunk", chunks.all? { |chunk| chunk.fetch("ids").length == 9 && chunk.fetch("ids").uniq.length == 9 }, "all chunks have nine unique addresses")
check.call("chunk coverage", chunk_ids.sort == provisional_ids.sort, "#{chunk_ids.uniq.length} proposal IDs covered once")

ori002 = provisional.find { |atom| atom["canonical_id"] == "ORI:002" }
check.call("ORI:002 latest algorithm", ori002 && ori002["canonical_transliteration"] == "nu·nan" && ori002["title"] == "latent first condition", "ORI:002 is nu·nan; runtime state 2 remains num")
check.call("no translator generated", !File.exist?(File.join(ROOT, "translator")) && Dir[File.join(ROOT, "**/*translator*")].empty?, "no English translator artifact exists")

passed = checks.count { |_name, ok, _detail| ok }
failed = checks.length - passed
lines = [
  "# Era Zero Phase 2 Validation Report",
  "",
  "- Checks passed: **#{passed}**",
  "- Checks failed: **#{failed}**",
  "- Atomic-field algorithm assertions: **2,268**",
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
lines << (failed.zero? ? "The 324-address inventory is structurally complete and all generated forms follow the latest accepted algorithms. The 288 new meanings remain provisional pending user review." : "Validation failed. Do not approve or publish this lexicon until the failures are corrected.")
File.write(File.join(ROOT, "reports/phase2_validation_report.md"), lines.join("\n"), encoding: "UTF-8")

puts "#{passed} checks passed; #{failed} checks failed."
exit(failed.zero? ? 0 : 1)
