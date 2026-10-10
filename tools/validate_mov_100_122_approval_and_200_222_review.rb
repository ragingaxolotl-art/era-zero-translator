#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
APPROVED_IDS = %w[
  MOV:100 MOV:101 MOV:102
  MOV:110 MOV:111 MOV:112
  MOV:120 MOV:121 MOV:122
].freeze
REVIEW_IDS = %w[
  MOV:200 MOV:201 MOV:202
  MOV:210 MOV:211 MOV:212
  MOV:220 MOV:221 MOV:222
].freeze
SCORE_KEYS = %w[
  atomicity address_fit motion_family_fit neighbor_separation
  separation_from_mov_000_122 cross_family_separation
  everyday_language_usefulness technical_programming_usefulness
  compound_usefulness
].freeze
REQUIRED_CONCEPTS = [
  "can move", "cannot move", "mobile", "immobile", "flexible",
  "range of motion", "freedom of movement", "reachable", "unreachable",
  "near", "far", "distance", "direction", "bearing", "orientation",
  "relative position", "beside", "above", "below", "between",
  "connected by a route", "accessible", "navigable", "blocked",
  "constrained", "path available", "possible path", "shortest path",
  "movement permission", "movement restriction", "traffic capacity",
  "network mobility", "spatial compatibility", "collision risk",
  "room to move", "drift potential", "orbit stability", "group mobility",
  "coordinated movement", "transport capacity", "teleportation possibility",
  "transition allowed", "state reachable", "route exists", "motion could occur"
].freeze
ALLOWED_CLASSIFICATIONS = [
  "direct atomic root", "root plus runtime state", "composition",
  "grammar or logic", "another family", "unresolved gap"
].freeze

APPROVED_MEANINGS = {
  "MOV:100" => ["completed source departure", "Completion of a mover's displacement away from a source position."],
  "MOV:101" => ["active source departure", "Ongoing displacement of a mover away from a source position."],
  "MOV:102" => ["potential source departure", "A potential displacement away from a source position that is not presently active or completed."],
  "MOV:110" => ["completed target arrival", "Completion of a mover's displacement to a target position."],
  "MOV:111" => ["active target approach", "Ongoing displacement of a mover toward a target position."],
  "MOV:112" => ["potential target approach", "A potential displacement toward a target position that is not presently active or completed."],
  "MOV:120" => ["completed shared-frame movement", "Completion of a mover's change of position relative to a shared or environmental reference frame."],
  "MOV:121" => ["active shared-frame movement", "Ongoing change of a mover's position relative to a shared or environmental reference frame."],
  "MOV:122" => ["potential shared-frame movement", "A potential change of a mover's position relative to a shared or environmental reference frame that is not presently active or completed."]
}.freeze

FAMILIES = {
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
SLOTS = {
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

def load_yaml(path)
  YAML.load_file(File.join(ROOT, path))
end

def fixed_projection(atom)
  {
    "canonical_id" => atom["canonical_id"],
    "family" => atom["family"],
    "address" => atom["address"],
    "universal_slot" => atom["universal_slot"],
    "family_onset" => atom["family_onset"],
    "family_qualified_transliteration" => atom["canonical_transliteration"],
    "local_compact_root" => atom["local_compact_root"],
    "formal_carrier" => atom["formal_carrier"],
    "harmonic_signature_semitones" => atom["harmonic_signature_semitones"],
    "relative_note_path_semitones" => atom["note_path_semitones"]
  }
end

checks = []
failures = []
check = lambda do |name, detail, condition|
  checks << [name, detail, condition]
  failures << "#{name}: #{detail}" unless condition
end

atoms_doc = load_yaml("lexicon/atoms.yaml")
atoms = atoms_doc.fetch("atoms")
atoms_by_id = atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }
all_atoms = load_yaml("lexicon/all_atoms.yaml").fetch("atoms")
all_by_id = all_atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }
source = load_yaml("lexicon/completed_atoms.yaml").fetch("atoms")
source_by_id = source.to_h { |atom| [atom.fetch("canonical_id"), atom] }
provisional = load_yaml("lexicon/provisional_atoms.yaml").fetch("atoms")
reviewed = load_yaml("lexicon/reviewed_canonical_atoms.yaml")
authority = load_yaml("lexicon/semantic_authority.yaml")
migration = load_yaml("migrations/MOV_100_122_semantic_approval.yaml")
scored = load_yaml("reviews/MOV_200_222_scored_candidates.yaml")
recommended = load_yaml("reviews/MOV_200_222_recommended_spec.yaml")
stress = load_yaml("reviews/MOV_200_222_stress_tests.yaml")
peer_text = File.read(File.join(ROOT, "reviews/MOV_200_222_peer_review.md"))
collision_text = File.read(File.join(ROOT, "reviews/MOV_200_222_collision_report.md"))

check.call("complete inventory", "324 atom records with unique IDs", atoms.length == 324 && atoms_by_id.length == 324)
check.call("canonical inventory", "exactly 45 canonical records", atoms.count { |atom| atom["status"] == "canonical" } == 45)
check.call("provisional inventory", "exactly 279 provisional records", atoms.count { |atom| atom["status"] == "provisional_pending_detailed_semantic_review" } == 279)
check.call("provisional file", "279 records excluding MOV:100–122", provisional.length == 279 && (provisional.map { |atom| atom["canonical_id"] } & APPROVED_IDS).empty?)
check.call("source canonical baseline", "36 source-developed roots retained object-for-object in both current lexicons",
           source.length == 36 &&
             source_by_id.all? { |id, atom| atoms_by_id[id] == atom && all_by_id[id] == atom })

approved_exact = APPROVED_MEANINGS.all? do |id, (title, definition)|
  atom = atoms_by_id.fetch(id)
  atom["status"] == "canonical" &&
    atom["title"] == title &&
    atom["core_definition"] == definition &&
    atom.dig("authority", "semantic_status") == "canonical"
end
check.call("approved meanings", "nine exact approved titles and invariant definitions", approved_exact)
check.call("reviewed canonical overlay", "nine separate reviewed canonical records", reviewed.fetch("atoms").map { |atom| atom["canonical_id"] }.to_set == APPROVED_IDS.to_set && reviewed.dig("metadata", "count") == 9)
check.call("authority counts", "machine authority is 45 canonical / 279 provisional", authority.dig("semantic_inventory", "canonical_roots") == 45 && authority.dig("semantic_inventory", "provisional_roots") == 279)
check.call("selective migration", "approval migration promotes exactly the nine reviewed roots and changes no generated fields",
           migration.fetch("promoted_roots").map { |root| root["canonical_id"] }.to_set == APPROVED_IDS.to_set &&
             migration.dig("metadata", "generated_fields_changed") == false)
check.call("process 1x2 clarification", "nonactualized process is separate from runtime [2]/num and excludes planning semantics",
           reviewed.dig("architecture_clarification", "status") == "canonical_architecture_clarification" &&
             reviewed.dig("architecture_clarification", "runtime_distinction").include?("Runtime [2]/num") &&
             %w[specification intention planning schedule queue permission readiness probability future_time certainty].all? do |term|
               reviewed.dig("architecture_clarification", "does_not_encode").include?(term)
             end)
check.call("route traversal decision", "route traversal is reserved for later composition", migration.dig("audit", "route_traversal_status").include?("shared-frame movement plus MOV:020"))
check.call("versioned change policy", "future changes require versioned migration", migration.dig("audit", "future_change_policy") == "explicit versioned migration required")

algorithm_errors = []
atoms.each do |atom|
  family = atom.fetch("family")
  address = atom.fetch("address")
  trits = address.chars.map(&:to_i)
  onset, harmony = FAMILIES.fetch(family)
  root = "#{%w[n k m][trits[0]]}#{%w[a o i][trits[1]]}#{%w[m k n][trits[2]]}"
  carrier = ([onset] + trits.map { |trit| %w[ma ki nu][trit] }).join("-")
  path = [0]
  trits.each { |trit| path << path.last + [0, 2, -2][trit] }
  expected = {
    "canonical_id" => "#{family}:#{address}",
    "family_onset" => onset,
    "harmonic_signature_semitones" => harmony,
    "universal_slot" => SLOTS.fetch([trits[0], trits[1]])[trits[2]],
    "local_compact_root" => root,
    "canonical_transliteration" => "#{onset}·#{root}",
    "formal_carrier" => carrier,
    "note_path_semitones" => path
  }
  expected.each do |field, value|
    algorithm_errors << "#{atom["canonical_id"]}.#{field}" unless atom[field] == value
  end
end
check.call("latest accepted generation algorithms", "2,592 family/address/slot/onset/harmony/root/transliteration/carrier/note-path assertions", algorithm_errors.empty?)

scored_roots = scored.fetch("roots")
recommended_roots = recommended.fetch("roots")
check.call("review scope", "exactly MOV:200–222 in both machine-readable review files",
           scored_roots.map { |root| root["canonical_id"] }.to_set == REVIEW_IDS.to_set &&
             recommended_roots.map { |root| root.dig("fixed_generated_fields", "canonical_id") }.to_set == REVIEW_IDS.to_set)
check.call("review remains noncanonical", "no MOV:200–222 root is promoted",
           recommended.dig("metadata", "status") == "ready_for_user_approval_not_canonical" &&
             recommended.dig("metadata", "roots_canonicalized") == [] &&
             REVIEW_IDS.all? { |id| atoms_by_id.fetch(id)["status"] == "provisional_pending_detailed_semantic_review" })
check.call("candidate depth", "four serious candidates per root including current candidate", scored_roots.all? do |root|
  candidates = root.fetch("candidates")
  candidates.length >= 4 && candidates.any? { |candidate| candidate["candidate_id"].start_with?("current_") }
end)
check.call("candidate scoring", "every candidate has nine integer scores from 1–10 and a correct total", scored_roots.all? do |root|
  root.fetch("candidates").all? do |candidate|
    scores = candidate.fetch("scores")
    scores.keys.to_set == SCORE_KEYS.to_set &&
      scores.values.all? { |score| score.is_a?(Integer) && score.between?(1, 10) } &&
      candidate["total"] == scores.values.sum &&
      candidate["maximum"] == 90
  end
end)
check.call("winner selection", "one existing recommended winner per root with a nonempty invariant", scored_roots.all? do |root|
  root.fetch("candidates").any? { |candidate| candidate["candidate_id"] == root["recommended_winner"] } &&
    root.fetch("recommended_invariant_definition").length > 25
end)

fixed_ok = (scored_roots + recommended_roots).all? do |root|
  projection = root.fetch("fixed_generated_fields")
  fixed_projection(atoms_by_id.fetch(projection.fetch("canonical_id"))) == projection
end
check.call("review generated fields", "all copied fixed fields match current canonical algorithms", fixed_ok)
check.call("semantic specification depth", "every recommended root has boundaries, exclusions, Motion contrasts, eight cross-family comparisons, tailored runtime states, 3 ordinary examples, 2 technical examples, decomposition sketches, and Era notes", recommended_roots.all? do |root|
  root.fetch("semantic_boundaries").length >= 3 &&
    root.fetch("excluded_meanings").length >= 4 &&
    root.fetch("nearest_motion_contrasts").length >= 3 &&
    root.fetch("cross_family_comparisons").keys.to_set == %w[MAT MIN CON STR LOG DAT CRE ORI].to_set &&
    root.fetch("runtime_state_interpretations").keys.to_set == %w[0 1 2].to_set &&
    root.fetch("ordinary_language_examples").length >= 3 &&
    root.fetch("technical_programming_examples").length >= 2 &&
    root.fetch("future_compound_decomposition_sketches_not_canonical").length >= 3 &&
    root.fetch("later_era_evolution_notes").length >= 2
end)

tests = stress.fetch("tests")
concepts = tests.map { |test| test["concept"] }
check.call("stress-test count", "exactly the 45 required concepts", tests.length == 45 && concepts.to_set == REQUIRED_CONCEPTS.to_set)
check.call("stress classifications", "all mappings use an authorized classification", tests.all? { |test| ALLOWED_CLASSIFICATIONS.include?(test["classification"]) })
check.call("no forced atomization", "stress test includes composition, logic/grammar, another family, and runtime-state mappings",
           ["composition", "grammar or logic", "another family", "root plus runtime state"].all? { |classification| tests.any? { |test| test["classification"] == classification } })
check.call("collision scope", "collision report explicitly covers all nine roots, 18 approved Motion roots by ranges/IDs, and eight competing families",
           REVIEW_IDS.all? { |id| collision_text.include?(id) } &&
             %w[MAT MIN CON STR LOG DAT CRE ORI].all? { |family| collision_text.include?(family) } &&
             %w[MOV:000 MOV:001 MOV:002 MOV:010 MOV:011 MOV:012 MOV:020 MOV:021 MOV:022 MOV:100 MOV:101 MOV:102 MOV:110 MOV:111 MOV:112 MOV:120 MOV:121 MOV:122].all? { |id| collision_text.include?(id) || collision_text.include?(id.sub(/:\d\d\d/, ":000–122")) })
check.call("peer report conclusion", "main report ends with the required readiness conclusion", peer_text.rstrip.end_with?("**READY FOR USER APPROVAL**"))
check.call("stop boundary", "no MAT review, other root review, or Gate 4 output was created by this packet",
           Dir.glob(File.join(ROOT, "reviews/MAT_*")).empty? &&
             peer_text.include?("Roots canonized by this packet:** none") &&
             recommended.dig("metadata", "stop_boundary").include?("Gate 4"))

part1_names = [
  "complete inventory", "canonical inventory", "provisional inventory",
  "provisional file", "source canonical baseline", "approved meanings",
  "reviewed canonical overlay", "authority counts", "selective migration",
  "process 1x2 clarification", "route traversal decision",
  "versioned change policy", "latest accepted generation algorithms"
]
part1_checks = checks.select { |name, _detail, _ok| part1_names.include?(name) }
part2_checks = checks.reject { |name, _detail, _ok| part1_names.include?(name) }

def render_report(title, status, selected_checks, failures, extras = [])
  report = +"# #{title}\n\n"
  report << "Status: **#{status}**\n\n"
  report << "- Checks passed: **#{selected_checks.count { |check| check[2] }}**\n"
  report << "- Checks failed: **#{selected_checks.count { |check| !check[2] }}**\n"
  extras.each { |extra| report << "- #{extra}\n" }
  report << "\n"
  selected_checks.each do |name, detail, ok|
    report << "## #{ok ? "PASS" : "FAIL"} — #{name}\n\n#{detail}\n\n"
  end
  relevant = failures.select { |failure| selected_checks.any? { |check| failure.start_with?("#{check[0]}:") } }
  unless relevant.empty?
    report << "## Failures\n\n"
    relevant.each { |failure| report << "- #{failure}\n" }
  end
  report
end

part1_report = render_report(
  "MOV:100–122 Approval and Canonization Validation",
  part1_checks.all? { |check| check[2] } ? "PASS" : "FAIL",
  part1_checks,
  failures,
  [
    "Source-canonical roots compared exactly: **36**",
    "Reviewed roots promoted: **9**",
    "Current canonical/provisional inventory: **45 / 279**",
    "Algorithm assertions: **2,592**"
  ]
)
File.write(File.join(ROOT, "reports/MOV_100_122_canonization_validation.md"), part1_report)

part2_report = render_report(
  "MOV:200–222 Review Packet Validation",
  part2_checks.all? { |check| check[2] } ? "PASS — READY FOR USER REVIEW" : "FAIL",
  part2_checks,
  failures,
  [
    "Roots reviewed: **9**",
    "Candidates scored: **#{scored_roots.sum { |root| root.fetch("candidates").length }}**",
    "Stress tests: **#{tests.length}**",
    "Roots canonized: **0**"
  ]
)
part2_report << "\n**#{failures.empty? ? "READY FOR USER APPROVAL" : "NOT READY — VALIDATION FAILURES"}**\n"
File.write(File.join(ROOT, "reviews/MOV_200_222_validation.md"), part2_report)

puts "Checks passed: #{checks.count { |check| check[2] }}"
puts "Checks failed: #{failures.length}"
puts "Algorithm assertions: #{atoms.length * 8}"
failures.each { |failure| warn failure }
exit(failures.empty? ? 0 : 1)
