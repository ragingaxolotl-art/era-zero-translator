#!/usr/bin/env ruby

require "yaml"
require "digest"
require "set"

ROOT = File.expand_path("..", __dir__)
WITHDRAWAL = "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION"
PROVISIONAL_STATUS = "provisional_pending_detailed_semantic_review"
IDS = %w[MOV:100 MOV:101 MOV:102 MOV:110 MOV:111 MOV:112 MOV:120 MOV:121 MOV:122].freeze

checks = []
failures = []

def assert(checks, failures, name, detail, condition)
  checks << [name, detail, condition]
  failures << "#{name}: #{detail}" unless condition
end

completed = YAML.load_file(File.join(ROOT, "lexicon/completed_atoms.yaml")).fetch("atoms")
atoms_doc = YAML.load_file(File.join(ROOT, "lexicon/atoms.yaml"))
atoms = atoms_doc.fetch("atoms")
all_atoms = YAML.load_file(File.join(ROOT, "lexicon/all_atoms.yaml")).fetch("atoms")
proposals = YAML.load_file(File.join(ROOT, "lexicon/provisional_atoms.yaml")).fetch("atoms")
authority = YAML.load_file(File.join(ROOT, "lexicon/semantic_authority.yaml"))
standard = YAML.load_file(File.join(ROOT, "spec/era_zero_core_standard_1.0.0.yaml"))
migration = YAML.load_file(File.join(ROOT, "migrations/1.0.0-canonization.yaml"))
candidates = YAML.load_file(File.join(ROOT, "reviews/MOV_100_122_candidates.yaml"))
tests = YAML.load_file(File.join(ROOT, "reviews/MOV_100_122_test_cases.yaml"))

completed_by_id = completed.to_h { |atom| [atom.fetch("canonical_id"), atom] }
atoms_by_id = atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }
all_by_id = all_atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }
canonical_ids = completed_by_id.keys.to_set

assert(checks, failures, "canonical baseline count", "36 source-developed roots", completed.length == 36)
assert(checks, failures, "complete address inventory", "324 records", atoms.length == 324)
assert(checks, failures, "unique IDs", "324 unique family/address IDs", atoms_by_id.length == 324)
assert(checks, failures, "source-canonical immutability", "lexicon/atoms.yaml retains all 36 objects exactly", canonical_ids.all? { |id| atoms_by_id[id] == completed_by_id[id] })
assert(checks, failures, "source-canonical all-atoms immutability", "lexicon/all_atoms.yaml retains all 36 objects exactly", canonical_ids.all? { |id| all_by_id[id] == completed_by_id[id] })
assert(checks, failures, "canonical statuses", "exactly 36 canonical records", atoms.count { |atom| atom["status"] == "canonical" } == 36)
assert(checks, failures, "provisional statuses", "exactly 288 provisional records", atoms.count { |atom| atom["status"] == PROVISIONAL_STATUS } == 288)
assert(checks, failures, "proposal statuses", "all 288 Phase 2 records are provisional", proposals.length == 288 && proposals.all? { |atom| atom["status"] == PROVISIONAL_STATUS })
assert(checks, failures, "withdrawal authority", "machine authority records exact user wording", authority.dig("metadata", "user_direction") == WITHDRAWAL)
assert(checks, failures, "withdrawn migration", "canonization migration is audit history only", migration["approval_status"] == WITHDRAWAL && migration["effective_as_semantic_authority"] == false && migration["audit_history_only"] == true)
assert(checks, failures, "standard authority counts", "36 canonical and 288 provisional", standard.dig("inventory", "canonical_roots") == 36 && standard.dig("inventory", "provisional_roots") == 288)
assert(checks, failures, "no downstream dependency", "provisional meanings cannot support downstream layers", authority["prohibited_dependencies"].sort == ["English concept index", "compounds", "etymology layer", "grammar implementation", "renderer", "semantic IR", "translator"].sort)

family_rules = {
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
}.freeze

first_char = %w[n k m].freeze
middle_vowel = %w[a o i].freeze
last_char = %w[m k n].freeze
carrier_syllable = %w[ma ki nu].freeze
delta = [0, 2, -2].freeze
slots = {
  [0, 0] => ["stable inward entity", "active inward entity", "dormant inward entity"],
  [0, 1] => ["stable outward entity", "active outward entity", "dormant outward entity"],
  [0, 2] => ["stable collective entity", "active collective entity", "dormant collective entity"],
  [1, 0] => ["completed inward process", "active inward process", "pending inward process"],
  [1, 1] => ["completed outward process", "active outward process", "pending outward process"],
  [1, 2] => ["completed systemic process", "active systemic process", "pending systemic process"],
  [2, 0] => ["stable inward capacity", "active inward capacity", "dormant inward capacity"],
  [2, 1] => ["stable outward relationship", "active outward relationship", "unresolved outward relationship"],
  [2, 2] => ["stable systemic relationship", "active systemic relationship", "unrealized systemic possibility"]
}.freeze

algorithm_errors = []
atoms.each do |atom|
  family = atom.fetch("family")
  address = atom.fetch("address")
  trits = address.chars.map(&:to_i)
  onset, harmony = family_rules.fetch(family)
  root = "#{first_char[trits[0]]}#{middle_vowel[trits[1]]}#{last_char[trits[2]]}"
  carrier = ([onset] + trits.map { |trit| carrier_syllable[trit] }).join("-")
  path = [0]
  trits.each { |trit| path << path.last + delta[trit] }
  expected = {
    "canonical_id" => "#{family}:#{address}",
    "family_onset" => onset,
    "harmonic_signature_semitones" => harmony,
    "universal_slot" => slots.fetch([trits[0], trits[1]])[trits[2]],
    "local_compact_root" => root,
    "canonical_transliteration" => "#{onset}·#{root}",
    "formal_carrier" => carrier,
    "note_path_semitones" => path
  }
  expected.each do |field, value|
    algorithm_errors << "#{atom["canonical_id"]}.#{field}: expected #{value.inspect}, got #{atom[field].inspect}" unless atom[field] == value
  end
end
assert(checks, failures, "latest accepted algorithms", "#{atoms.length * 8} structural field assertions", algorithm_errors.empty?)

families_ok = family_rules.keys.all? do |family|
  family_atoms = atoms.select { |atom| atom["family"] == family }
  family_atoms.length == 27 &&
    family_atoms.map { |atom| atom["address"] }.to_set == %w[000 001 002 010 011 012 020 021 022 100 101 102 110 111 112 120 121 122 200 201 202 210 211 212 220 221 222].to_set &&
    family_atoms.map { |atom| atom["local_compact_root"] }.uniq.length == 27 &&
    family_atoms.map { |atom| atom["formal_carrier"] }.uniq.length == 27 &&
    family_atoms.map { |atom| atom["note_path_semitones"] }.uniq.length == 27
end
assert(checks, failures, "family address/form uniqueness", "27 unique addresses, roots, carriers, and paths per family", families_ok)

review_roots = candidates.fetch("roots")
review_by_id = review_roots.to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
assert(checks, failures, "review scope", "exactly MOV:100–122 and no MOV:200–222", review_by_id.keys.to_set == IDS.to_set)
assert(checks, failures, "review not canonical", "all nine packet records explicitly noncanonical", review_roots.all? { |root| root["status"] == "proposed_in_detailed_review_not_canonical" } && candidates.dig("approval", "canonicalized") == false)
assert(checks, failures, "candidate depth", "at least two plausible candidates per root", review_roots.all? { |root| root.fetch("candidate_analysis").length >= 2 })
assert(checks, failures, "candidate selection", "one selected candidate per root", review_roots.all? { |root| root.fetch("candidate_analysis").count { |candidate| candidate["selection"] == "selected" } == 1 })
assert(checks, failures, "invariant definitions", "one nonempty invariant per root", review_roots.all? { |root| root.fetch("invariant_definition").is_a?(String) && root.fetch("invariant_definition").length > 30 })

fixed_match = review_roots.all? do |root|
  fixed = root.fetch("fixed_generated_fields")
  atom = atoms_by_id.fetch(fixed.fetch("canonical_id"))
  fixed == {
    "canonical_id" => atom["canonical_id"],
    "universal_slot" => atom["universal_slot"],
    "family_qualified_transliteration" => atom["canonical_transliteration"],
    "local_compact_root" => atom["local_compact_root"],
    "formal_carrier" => atom["formal_carrier"],
    "harmonic_signature_semitones" => atom["harmonic_signature_semitones"],
    "relative_note_path_semitones" => atom["note_path_semitones"]
  }
end
assert(checks, failures, "review generated-field preservation", "all 63 copied generated fields match lexicon/atoms.yaml", fixed_match)

root_examples = tests.fetch("root_examples")
assert(checks, failures, "example scope", "nine roots represented", root_examples.map { |item| item["root"] }.to_set == IDS.to_set)
assert(checks, failures, "examples per root", "six tailored examples for each root", root_examples.all? { |item| item.fetch("examples").length == 6 })
required_example_fields = %w[category semantic_graph literal_gloss natural_english runtime_state contour role_register_assignments]
assert(checks, failures, "example completeness", "all 54 examples include graph, gloss, English, runtime, contour, and roles", root_examples.flat_map { |item| item.fetch("examples") }.all? { |example| required_example_fields.all? { |field| !example[field].to_s.empty? } })
assert(checks, failures, "coverage test count", "at least 20 English Motion concepts", tests.fetch("english_motion_coverage").length >= 20)
required_coverage = %w[leave depart go approach arrive follow wait pause stop continue cross return redirect schedule delay transition transport]
coverage_words = tests.fetch("english_motion_coverage").map { |test| test["english_concept"] }
assert(checks, failures, "required coverage concepts", "all required English concepts present", (required_coverage - coverage_words).empty?)

collision_lines = File.readlines(File.join(ROOT, "reviews/MOV_100_122_collision_report.md"))
collision_rows = collision_lines.count { |line| line.start_with?("| MOV:") }
assert(checks, failures, "collision audit", "9 roots × 7 competing families = 63 rows", collision_rows == 63)

forbidden_review_paths = Dir.glob(File.join(ROOT, "reviews/*")).select do |path|
  File.basename(path).match?(/MOV_200|Gate_?4|compound/i)
end
assert(checks, failures, "stop boundary", "no MOV:200–222 or Gate 4 review output created", forbidden_review_paths.empty?)

report = +"# Gate 3 Withdrawal and MOV:100–122 Validation\n\n"
report << "- Checks passed: **#{checks.count { |check| check[2] }}**\n"
report << "- Checks failed: **#{failures.length}**\n"
report << "- Structural algorithm assertions: **#{atoms.length * 8}**\n"
report << "- Source-canonical roots compared exactly: **36**\n"
report << "- Provisional semantic roots: **288**\n"
report << "- MOV packet examples: **54**\n"
report << "- English coverage tests: **#{tests.fetch("english_motion_coverage").length}**\n"
report << "- Cross-family collision rows: **#{collision_rows}**\n\n"
checks.each do |name, detail, condition|
  report << "## #{condition ? "PASS" : "FAIL"} — #{name}\n\n#{detail}\n\n"
end
unless algorithm_errors.empty?
  report << "## Structural errors\n\n"
  algorithm_errors.each { |error| report << "- #{error}\n" }
end
unless failures.empty?
  report << "## Failures\n\n"
  failures.each { |failure| report << "- #{failure}\n" }
end
File.write(File.join(ROOT, "reports/gate3_withdrawal_mov_100_122_validation.md"), report)

puts "Checks passed: #{checks.count { |check| check[2] }}"
puts "Checks failed: #{failures.length}"
puts "Structural assertions: #{atoms.length * 8}"
failures.each { |failure| warn failure }
exit(failures.empty? ? 0 : 1)
