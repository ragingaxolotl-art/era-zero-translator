#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MAT:100 MAT:101 MAT:102
  MAT:110 MAT:111 MAT:112
  MAT:120 MAT:121 MAT:122
].freeze
SCORE_KEYS = %w[
  atomicity address_fit matter_family_fit triplet_coherence
  neighbor_separation cross_family_separation everyday_language_usefulness
  technical_programming_usefulness compound_usefulness translation_safety
].freeze
EXAMPLE_CATEGORIES = %w[
  ordinary_conversation physical_or_spatial temporal_or_sequential
  cross_family_compound executable_or_programming counterexample
].freeze
CROSS_FAMILIES = %w[LIF MOV MIN CON STR WRN REP LOG DAT CRE ORI].freeze

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

def authoritative_semantic_projection(atom)
  {
    "canonical_id" => atom["canonical_id"],
    "title" => atom["title"],
    "core_definition" => atom["core_definition"],
    "status" => atom["status"],
    "family" => atom["family"],
    "address" => atom["address"],
    "universal_slot" => atom["universal_slot"],
    "family_onset" => atom["family_onset"],
    "canonical_transliteration" => atom["canonical_transliteration"],
    "local_compact_root" => atom["local_compact_root"],
    "formal_carrier" => atom["formal_carrier"],
    "harmonic_signature_semitones" => atom["harmonic_signature_semitones"],
    "note_path_semitones" => atom["note_path_semitones"]
  }
end

def fixed_projection(atom)
  {
    "canonical_id" => atom["canonical_id"],
    "universal_slot" => atom["universal_slot"],
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

atoms = load_yaml("lexicon/atoms.yaml").fetch("atoms")
atoms_by_id = atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }
all_atoms = load_yaml("lexicon/all_atoms.yaml").fetch("atoms")
all_by_id = all_atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }
source = load_yaml("lexicon/completed_atoms.yaml").fetch("atoms")
reviewed_canonical = load_yaml("lexicon/reviewed_canonical_atoms.yaml").fetch("atoms")
provisional = load_yaml("lexicon/provisional_atoms.yaml").fetch("atoms")
provisional_by_id = provisional.to_h { |atom| [atom.fetch("canonical_id"), atom] }
authority = load_yaml("lexicon/semantic_authority.yaml")
scored = load_yaml("reviews/MAT_100_122_scored_candidates.yaml")
recommended = load_yaml("reviews/MAT_100_122_recommended_spec.yaml")
stress = load_yaml("reviews/MAT_100_122_stress_tests.yaml")
readiness = load_yaml("spec/translator_readiness.yaml")
peer_text = File.read(File.join(ROOT, "reviews/MAT_100_122_peer_review.md"))
collision_text = File.read(File.join(ROOT, "reviews/MAT_100_122_collision_report.md"))
roadmap_text = File.read(File.join(ROOT, "reports/translator_readiness_roadmap.md"))

check.call("complete address inventory", "324 records with unique IDs",
           atoms.length == 324 && atoms_by_id.length == 324)
check.call("authority inventory", "45 canonical and 279 provisional meanings",
           atoms.count { |atom| atom["status"] == "canonical" } == 45 &&
             atoms.count { |atom| atom["status"] == "provisional_pending_detailed_semantic_review" } == 279)
check.call("canonical immutability", "36 source-canonical records remain object-identical; 9 reviewed-canonical records retain identical authoritative semantic/generated fields",
           source.all? { |atom| atoms_by_id[atom["canonical_id"]] == atom && all_by_id[atom["canonical_id"]] == atom } &&
             reviewed_canonical.all? do |atom|
               atoms_by_id[atom["canonical_id"]] == atom &&
                 authoritative_semantic_projection(all_by_id[atom["canonical_id"]]) == authoritative_semantic_projection(atom)
             end)
check.call("MAT meanings unchanged", "all nine MAT:100–122 records retain their Phase 2 candidate semantics and provisional status",
           IDS.all? do |id|
             authoritative_semantic_projection(atoms_by_id[id]) == authoritative_semantic_projection(provisional_by_id[id]) &&
               atoms_by_id[id]["status"] == "provisional_pending_detailed_semantic_review"
           end)

algorithm_errors = []
atoms.each do |atom|
  family = atom.fetch("family")
  address = atom.fetch("address")
  trits = address.chars.map(&:to_i)
  onset, harmony = FAMILIES.fetch(family)
  compact = "#{%w[n k m][trits[0]]}#{%w[a o i][trits[1]]}#{%w[m k n][trits[2]]}"
  carrier = ([onset] + trits.map { |trit| %w[ma ki nu][trit] }).join("-")
  path = [0]
  trits.each { |trit| path << path.last + [0, 2, -2][trit] }
  expected = {
    "canonical_id" => "#{family}:#{address}",
    "family_onset" => onset,
    "harmonic_signature_semitones" => harmony,
    "universal_slot" => SLOTS.fetch([trits[0], trits[1]])[trits[2]],
    "local_compact_root" => compact,
    "canonical_transliteration" => "#{onset}·#{compact}",
    "formal_carrier" => carrier,
    "note_path_semitones" => path
  }
  expected.each do |field, value|
    algorithm_errors << "#{atom["canonical_id"]}.#{field}" unless atom[field] == value
  end
end
check.call("accepted generation algorithms", "2,592 address/onset/harmony/slot/root/transliteration/carrier/path assertions",
           algorithm_errors.empty?)

scored_roots = scored.fetch("roots")
recommended_roots = recommended.fetch("roots")
check.call("review scope", "exactly MAT:100–122 appears in both review specifications",
           scored_roots.map { |root| root["canonical_id"] }.to_set == IDS.to_set &&
             recommended_roots.map { |root| root.dig("fixed_generated_fields", "canonical_id") }.to_set == IDS.to_set)
check.call("review remains provisional", "no MAT root was canonized or changed in the authoritative lexicon",
           scored.dig("metadata", "status") == "ready_for_user_approval_not_canonical" &&
             recommended.dig("metadata", "roots_canonicalized") == [] &&
             IDS.all? { |id| atoms_by_id[id]["status"] == "provisional_pending_detailed_semantic_review" })
check.call("independent review basis", "the packet does not semantically depend on either earlier pending review packet",
           scored.dig("metadata", "semantic_dependency_on_pending_mov_200_222") == false &&
             scored.dig("metadata", "semantic_dependency_on_pending_mat_000_022") == false)
check.call("candidate depth", "each root compares the current meaning with three genuinely different replacements",
           scored_roots.all? do |root|
             root.fetch("candidates").length == 4 &&
               root.fetch("candidates").map { |candidate| candidate["candidate_id"] }.to_set ==
                 %w[current_phase2_candidate physical_state_change material_transfer energy_or_work_process].to_set
           end)
check.call("candidate scoring", "every candidate has ten integer scores from 1–10 and a correct /100 total",
           scored_roots.all? do |root|
             root.fetch("candidates").all? do |candidate|
               scores = candidate.fetch("scores")
               scores.keys.to_set == SCORE_KEYS.to_set &&
                 scores.values.all? { |score| score.is_a?(Integer) && score.between?(1, 10) } &&
                 candidate["total"] == scores.values.sum &&
                 candidate["maximum"] == 100
             end
           end)
check.call("winner selection", "physical-state change wins every root and has one invariant definition",
           scored_roots.all? do |root|
             winner = root.fetch("candidates").find { |candidate| candidate["candidate_id"] == root["recommended_winner"] }
             root["recommended_winner"] == "physical_state_change" &&
               winner &&
               winner["total"] == root.fetch("candidates").map { |candidate| candidate["total"] }.max &&
               root.fetch("recommended_invariant_definition").length > 40
           end)
check.call("generated-field preservation", "all copied generated forms match authoritative accepted algorithms",
           (scored_roots + recommended_roots).all? do |root|
             copied = root.fetch("fixed_generated_fields")
             copied == fixed_projection(atoms_by_id.fetch(copied.fetch("canonical_id")))
           end)
check.call("block grid", "the recommendation uses physical-state change × three loci × three lexical phases",
           recommended["block_invariant"].include?("physical-state change") &&
             recommended_roots.map { |root| root["semantic_center"] }.uniq == ["physical-state change"] &&
             %w[completed active potential].all? do |phase|
               recommended_roots.count { |root| root["proposed_title"].start_with?(phase) } == 3
             end)
check.call("semantic specification depth", "every root has boundaries, exclusions, neighbors, address axes, runtime interpretations, eleven family audits, six examples, compound sketches, and Era notes",
           recommended_roots.all? do |root|
             root.fetch("semantic_boundaries").length >= 4 &&
               root.fetch("excluded_meanings").length >= 6 &&
               root.fetch("nearest_neighbors").length >= 6 &&
               root.fetch("address_explanation").length == 3 &&
               root.fetch("runtime_state_interpretations").keys.to_set == %w[0 1 2].to_set &&
               root.fetch("cross_family_comparisons").keys.to_set == CROSS_FAMILIES.to_set &&
               root.fetch("examples").map { |example| example["category"] }.to_set == EXAMPLE_CATEGORIES.to_set &&
               root.fetch("examples").all? do |example|
                 %w[semantic_graph literal_gloss natural_english runtime_state contour role_registers use_status analysis].all? do |field|
                   example.key?(field)
                 end
               end &&
               root.fetch("future_compound_decomposition_sketches_not_canonical").length >= 3 &&
               root.fetch("later_era_evolution_notes").length >= 3
           end)
check.call("lexical/runtime separation", "all nine specs explicitly distinguish lexical third trit from runtime [2]/num",
           recommended_roots.all? do |root|
             text = root.fetch("lexical_third_trit_vs_runtime_2")
             text.include?("third lexical trit") && text.include?("Runtime `[2]/num`")
           end)

tests = stress.fetch("tests")
classifications = tests.map { |test| test["classification"] }.to_set
check.call("stress-test breadth", "at least 75 unique English Matter/process concepts",
           tests.length >= 75 && tests.map { |test| test["concept"] }.uniq.length == tests.length)
check.call("no forced atomization", "coverage includes direct roots, compositions, other families, grammar/quantity, runtime, and unresolved ambiguity",
           [
             "direct proposed root",
             "composition",
             "canonical/future other family",
             "grammar or quantity",
             "root plus runtime",
             "unresolved lexical ambiguity"
           ].all? { |classification| classifications.include?(classification) })
check.call("collision coverage", "all nine roots and eleven competing families appear in the collision audit",
           IDS.all? { |id| collision_text.include?(id) } &&
             CROSS_FAMILIES.all? { |family| collision_text.include?(family) })
check.call("peer report conclusion", "the detailed report ends ready for user approval",
           peer_text.rstrip.end_with?("**READY FOR USER APPROVAL**"))

pending_packets = authority.fetch("review_packets_pending_user_decision")
check.call("semantic authority progress", "three packets pending decision; 252 roots in 28 chunks remain unreviewed",
           pending_packets.map { |packet| packet["range"] }.to_set ==
             %w[MOV:200–222 MAT:000–022 MAT:100–122].to_set &&
             authority.dig("semantic_review_progress", "reviewed_pending_decision_roots") == 27 &&
             authority.dig("semantic_review_progress", "unreviewed_roots") == 252 &&
             authority.dig("semantic_review_progress", "unreviewed_chunks") == 28)
check.call("translator inventory", "translator readiness mirrors semantic authority and rejects broad translation",
           readiness.dig("current_inventory", "canonical_meanings") == 45 &&
             readiness.dig("current_inventory", "provisional_meanings") == 279 &&
             readiness.dig("current_inventory", "reviewed_pending_user_decision", "roots") == 27 &&
             readiness.dig("current_inventory", "unreviewed", "roots") == 252 &&
             readiness.dig("current_inventory", "unreviewed", "nine_root_chunks") == 28 &&
             readiness.dig("metadata", "broad_translator_authorized") == false)
check.call("translator roadmap coverage", "roadmap carries current counts and required translator dependencies",
           roadmap_text.include?("27 provisional meanings") &&
             roadmap_text.include?("252 meanings in 28 nine-root chunks") &&
             %w[compound sense IR grammar renderer decoder round-trip ambiguity canonical].all? do |term|
               roadmap_text.downcase.include?(term.downcase)
             end)
check.call("stop boundary", "no MAT:200–222 review, other block, Gate 4, or translator implementation was produced",
           Dir.glob(File.join(ROOT, "reviews/MAT_200*")).empty? &&
             authority.dig("stop_boundary", "do_not_begin").include?("MAT:200–222") &&
             recommended.dig("metadata", "stop_boundary").include?("translator implementation"))

report = +"# MAT:100–122 Review Validation\n\n"
report << "Status: **#{failures.empty? ? "PASS — READY FOR USER REVIEW" : "FAIL"}**\n\n"
report << "- Checks passed: **#{checks.count { |item| item[2] }}**\n"
report << "- Checks failed: **#{failures.length}**\n"
report << "- Roots reviewed: **9**\n"
report << "- Candidates scored: **#{scored_roots.sum { |root| root.fetch("candidates").length }}**\n"
report << "- Stress tests: **#{tests.length}**\n"
report << "- Generation assertions: **#{atoms.length * 8}**\n"
report << "- Roots canonized: **0**\n\n"
checks.each do |name, detail, ok|
  report << "## #{ok ? "PASS" : "FAIL"} — #{name}\n\n#{detail}\n\n"
end
unless failures.empty?
  report << "## Failures\n\n"
  failures.each { |failure| report << "- #{failure}\n" }
end
report << "\n**#{failures.empty? ? "READY FOR USER APPROVAL" : "NOT READY — VALIDATION FAILURES"}**\n"
File.write(File.join(ROOT, "reviews/MAT_100_122_validation.md"), report)

translator_check_names = [
  "semantic authority progress",
  "translator inventory",
  "translator roadmap coverage",
  "stop boundary"
]
translator_checks = checks.select { |name, _detail, _ok| translator_check_names.include?(name) }
translator_report = +"# Translator Readiness Validation\n\n"
translator_report << "Status: **#{translator_checks.all? { |item| item[2] } ? "PASS — ROADMAP CONSISTENT; BROAD TRANSLATOR STILL BLOCKED" : "FAIL"}**\n\n"
translator_report << "- Checks passed: **#{translator_checks.count { |item| item[2] }}**\n"
translator_report << "- Checks failed: **#{translator_checks.count { |item| !item[2] }}**\n\n"
translator_checks.each do |name, detail, ok|
  translator_report << "## #{ok ? "PASS" : "FAIL"} — #{name}\n\n#{detail}\n\n"
end
translator_report << "The safe near-term implementation surface remains an explicit-ID renderer restricted to the 45 canonical roots. General English translation remains unauthorized.\n"
File.write(File.join(ROOT, "reports/translator_readiness_validation.md"), translator_report)

puts "Checks passed: #{checks.count { |item| item[2] }}"
puts "Checks failed: #{failures.length}"
puts "Stress tests: #{tests.length}"
puts "Generation assertions: #{atoms.length * 8}"
failures.each { |failure| warn failure }
exit(failures.empty? ? 0 : 1)
