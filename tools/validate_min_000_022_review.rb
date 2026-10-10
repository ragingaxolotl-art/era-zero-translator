#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MIN:000 MIN:001 MIN:002
  MIN:010 MIN:011 MIN:012
  MIN:020 MIN:021 MIN:022
].freeze
SCORE_KEYS = %w[
  atomicity address_fit mind_family_fit triplet_coherence
  neighbor_separation cross_family_separation everyday_language_usefulness
  technical_programming_usefulness compound_usefulness translation_safety
].freeze
EXAMPLE_CATEGORIES = %w[
  ordinary_conversation physical_or_spatial temporal_or_sequential
  cross_family_compound executable_or_programming counterexample
].freeze
CROSS_FAMILIES = %w[LIF MOV MAT CON STR WRN REP LOG DAT CRE ORI].freeze
FAMILIES = {
  "LIF" => ["ni", [0, 4, 7]], "MOV" => ["gi", [0, 2, 7]],
  "MAT" => ["ba", [0, 7, 12]], "MIN" => ["si", [0, 3, 7]],
  "CON" => ["wu", [0, 4, 7, 9]], "STR" => ["do", [0, 5, 7]],
  "WRN" => ["da", [0, 3, 6]], "REP" => ["ya", [0, 3, 7, 9]],
  "LOG" => ["te", [0, 4, 8]], "DAT" => ["li", [0, 4, 7, 11]],
  "CRE" => ["ga", [0, 3, 7, 11]], "ORI" => ["nu", [0, 1, 7]]
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
AUTHORITY_FIELDS = %w[
  canonical_id title core_definition status family address universal_slot
  harmonic_signature_semitones family_onset local_compact_root
  canonical_transliteration formal_carrier note_path_semitones
].freeze

def load_yaml(path)
  YAML.load_file(File.join(ROOT, path))
end

def projection(atom)
  atom.slice(*AUTHORITY_FIELDS)
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
reviewed = load_yaml("lexicon/reviewed_canonical_atoms.yaml").fetch("atoms")
provisional = load_yaml("lexicon/provisional_atoms.yaml").fetch("atoms")
provisional_by_id = provisional.to_h { |atom| [atom.fetch("canonical_id"), atom] }
authority = load_yaml("lexicon/semantic_authority.yaml")
readiness = load_yaml("spec/translator_readiness.yaml")
scored = load_yaml("reviews/MIN_000_022_scored_candidates.yaml")
recommended = load_yaml("reviews/MIN_000_022_recommended_spec.yaml")
stress = load_yaml("reviews/MIN_000_022_stress_tests.yaml")
peer_text = File.read(File.join(ROOT, "reviews/MIN_000_022_peer_review.md"))
collision_text = File.read(File.join(ROOT, "reviews/MIN_000_022_collision_report.md"))

check.call("complete address inventory", "324 records with unique canonical IDs",
           atoms.length == 324 && atoms_by_id.length == 324 && all_by_id.length == 324)
check.call("pre-approval inventory", "81 canonical and 243 provisional roots",
           atoms.count { |atom| atom["status"] == "canonical" } == 81 &&
             atoms.count { |atom| atom["status"] == "provisional_pending_detailed_semantic_review" } == 243)
check.call("canonical immutability",
           "36 source-canonical records remain object-identical and 45 reviewed records retain identical authoritative fields",
           source.length == 36 &&
             source.all? { |atom| atoms_by_id[atom["canonical_id"]] == atom && all_by_id[atom["canonical_id"]] == atom } &&
             reviewed.length == 45 &&
             reviewed.all? do |atom|
               projection(atoms_by_id[atom["canonical_id"]]) == projection(atom) &&
                 projection(all_by_id[atom["canonical_id"]]) == projection(atom)
             end)
check.call("MIN:000–022 remains provisional",
           "all nine authoritative records retain the Phase 2 candidates before approval",
           IDS.all? do |id|
             projection(atoms_by_id[id]) == projection(provisional_by_id[id]) &&
               atoms_by_id[id]["status"] == "provisional_pending_detailed_semantic_review"
           end)

algorithm_errors = []
atoms.each do |atom|
  family = atom.fetch("family")
  trits = atom.fetch("address").chars.map(&:to_i)
  onset, harmony = FAMILIES.fetch(family)
  compact = "#{%w[n k m][trits[0]]}#{%w[a o i][trits[1]]}#{%w[m k n][trits[2]]}"
  path = [0]
  trits.each { |trit| path << path.last + [0, 2, -2][trit] }
  expected = {
    "canonical_id" => "#{family}:#{atom["address"]}",
    "family_onset" => onset,
    "harmonic_signature_semitones" => harmony,
    "universal_slot" => SLOTS.fetch([trits[0], trits[1]])[trits[2]],
    "local_compact_root" => compact,
    "canonical_transliteration" => "#{onset}·#{compact}",
    "formal_carrier" => ([onset] + trits.map { |trit| %w[ma ki nu][trit] }).join("-"),
    "note_path_semitones" => path
  }
  expected.each do |field, value|
    algorithm_errors << "#{atom["canonical_id"]}.#{field}" unless atom[field] == value
  end
end
check.call("accepted generation algorithms",
           "2,592 address/onset/harmony/slot/root/transliteration/carrier/note-path assertions",
           algorithm_errors.empty?)

scored_roots = scored.fetch("roots")
recommended_roots = recommended.fetch("roots")
check.call("exact review scope", "only MIN:000–022 appears in both specifications",
           scored_roots.map { |root| root["canonical_id"] }.to_set == IDS.to_set &&
             recommended_roots.map { |root| root.dig("fixed_generated_fields", "canonical_id") }.to_set == IDS.to_set)
check.call("delegated pre-approval status", "delegated authority is recorded but no root is canonized",
           scored.dig("metadata", "status") == "ready_for_delegated_approval_not_yet_canonical" &&
             scored.dig("metadata", "delegated_approval_authorized") == true &&
             scored.dig("metadata", "roots_canonicalized") == [] &&
             recommended.dig("metadata", "status") == "ready_for_delegated_approval_not_yet_canonical" &&
             recommended.dig("metadata", "roots_canonicalized") == [] &&
             recommended_roots.all? { |root| root["canonicalized"] == false })
candidate_ids = %w[
  current_phase2_candidate cognitive_representation_architecture
  attention_salience_architecture epistemic_status_architecture memory_architecture
].to_set
check.call("candidate depth", "each root compares the current meaning with four different alternatives",
           scored_roots.all? do |root|
             root.fetch("candidates").length == 5 &&
               root.fetch("candidates").map { |candidate| candidate["candidate_id"] }.to_set == candidate_ids
           end)
check.call("candidate scoring", "all 45 candidates have ten integer scores from 1–10 and correct /100 totals",
           scored_roots.all? do |root|
             root.fetch("candidates").all? do |candidate|
               scores = candidate.fetch("scores")
               scores.keys.to_set == SCORE_KEYS.to_set &&
                 scores.values.all? { |score| score.is_a?(Integer) && score.between?(1, 10) } &&
                 candidate["total"] == scores.values.sum &&
                 candidate["maximum"] == 100
             end
           end)
check.call("winner selection", "the cognitive-representation architecture uniquely wins every address",
           scored_roots.all? do |root|
             candidates = root.fetch("candidates")
             winner = candidates.find { |candidate| candidate["candidate_id"] == root["recommended_winner"] }
             root["recommended_winner"] == "cognitive_representation_architecture" &&
               winner &&
               winner["total"] == candidates.map { |candidate| candidate["total"] }.max &&
               candidates.count { |candidate| candidate["total"] == winner["total"] } == 1
           end)
check.call("generated-field preservation", "all copied fixed fields match authoritative accepted algorithms",
           (scored_roots + recommended_roots).all? do |root|
             copied = root.fetch("fixed_generated_fields")
             copied == fixed_projection(atoms_by_id.fetch(copied.fetch("canonical_id")))
           end)

expected_centers = {
  "MIN:000" => "self-representation", "MIN:001" => "self-representation",
  "MIN:002" => "self-representation", "MIN:010" => "target representation",
  "MIN:011" => "target representation", "MIN:012" => "target representation",
  "MIN:020" => "shared cognitive schema", "MIN:021" => "shared cognitive schema",
  "MIN:022" => "shared cognitive schema"
}
check.call("triplet coherence",
           "self, target, and shared representation triplets share an exact persistent/manifest/latent axis",
           recommended.dig("metadata", "semantic_architecture") ==
             "self-representation → target representation → shared cognitive schema" &&
             recommended.dig("metadata", "lexical_expression_axis") ==
               "persistent → manifest → latent" &&
             recommended.fetch("triplet_contrasts").length == 3 &&
             recommended_roots.all? do |root|
               id = root.dig("fixed_generated_fields", "canonical_id")
               root["semantic_center"] == expected_centers.fetch(id)
             end)
check.call("specification depth",
           "every root contains boundaries, exclusions, neighbors, address axes, tailored runtime states, 11 family audits, six examples, compound sketches, and Era notes",
           recommended_roots.all? do |root|
             root.fetch("semantic_boundaries").length >= 4 &&
               root.fetch("excluded_meanings").length >= 7 &&
               root.fetch("nearest_neighbors").length >= 7 &&
               root.fetch("address_explanation").length == 3 &&
               root.fetch("runtime_state_interpretations").keys.to_set == %w[0 1 2].to_set &&
               root.fetch("cross_family_comparisons").keys.to_set == CROSS_FAMILIES.to_set &&
               root.fetch("examples").map { |example| example["category"] }.to_set == EXAMPLE_CATEGORIES.to_set &&
               root.fetch("examples").all? do |example|
                 %w[
                   semantic_graph literal_gloss natural_english runtime_state
                   contour role_registers use_status analysis
                 ].all? { |field| example.key?(field) }
               end &&
               root.fetch("future_compound_decomposition_sketches_not_canonical").length >= 3 &&
               root.fetch("later_era_evolution_notes").length >= 3
           end)
check.call("lexical/runtime separation", "all roots distinguish lexical expression from runtime [2]/num",
           recommended_roots.all? do |root|
             text = root.fetch("lexical_third_trit_vs_runtime_2")
             text.include?("third lexical trit") && text.include?("Runtime `[2]/num`")
           end)

tests = stress.fetch("tests")
classifications = tests.map { |test| test["classification"] }.to_set
check.call("stress-test breadth", "at least 85 unique English Mind concepts",
           tests.length >= 85 && tests.map { |test| test["concept"] }.uniq.length == tests.length)
check.call("no forced atomization",
           "coverage distinguishes direct roots, compositions, later MIN layers, other families, grammar, runtime, and ambiguity",
           [
             "direct proposed root", "composition", "canonical/future other family",
             "future MIN capacity/relationship", "future MIN process/capacity",
             "grammar or quantity", "root plus runtime", "unresolved lexical ambiguity"
           ].all? { |classification| classifications.include?(classification) })
check.call("collision audit", "all nine roots and eleven competing families appear",
           IDS.all? { |id| collision_text.include?(id) } &&
             CROSS_FAMILIES.all? { |family| collision_text.include?(family) })
check.call("peer-review conclusion", "the detailed report ends ready for delegated approval",
           peer_text.rstrip.end_with?("**READY FOR DELEGATED APPROVAL**"))

check.call("authority alignment", "81 canonical, 243 unreviewed, no decision queue, and MIN:000–022 is next",
           authority.dig("semantic_inventory", "canonical_roots") == 81 &&
             authority.dig("semantic_inventory", "provisional_roots") == 243 &&
             authority.fetch("review_packets_pending_user_decision").empty? &&
             authority.dig("semantic_review_progress", "unreviewed_roots") == 243 &&
             authority.dig("semantic_review_progress", "unreviewed_chunks") == 27 &&
             authority.dig("next_review_packet", "range") == "MIN:000–022" &&
             authority.dig("next_review_packet", "status") == "not_begun")
check.call("translator remains blocked", "translator inventory mirrors authority and rejects provisional meanings",
           readiness.dig("current_inventory", "canonical_meanings") == 81 &&
             readiness.dig("current_inventory", "provisional_meanings") == 243 &&
             readiness.dig("safe_now", "maximum_semantic_scope") == "81 canonical roots" &&
             readiness.dig("safe_now", "reject_provisional_roots") == true &&
             readiness.dig("metadata", "broad_translator_authorized") == false)
check.call("stop boundary", "no later MIN block, other block, Gate 4, or translator implementation was begun",
           Dir.glob(File.join(ROOT, "reviews/MIN_100*")).empty? &&
             Dir.glob(File.join(ROOT, "reviews/CON_000*")).empty? &&
             recommended.dig("metadata", "stop_boundary").include?("MIN:100–122") &&
             recommended.dig("metadata", "stop_boundary").include?("Gate 4") &&
             recommended.dig("metadata", "stop_boundary").include?("translator implementation"))

report = +"# MIN:000–022 Review Validation\n\n"
report << "Status: **#{failures.empty? ? "PASS — READY FOR DELEGATED APPROVAL" : "FAIL"}**\n\n"
report << "- Checks passed: **#{checks.count { |item| item[2] }}**\n"
report << "- Checks failed: **#{failures.length}**\n"
report << "- Roots reviewed: **9**\n"
report << "- Candidates scored: **#{scored_roots.sum { |root| root.fetch("candidates").length }}**\n"
report << "- Stress tests: **#{tests.length}**\n"
report << "- Generation assertions: **#{atoms.length * 8}**\n"
report << "- Roots canonized by validation: **0**\n\n"
checks.each do |name, detail, ok|
  report << "## #{ok ? "PASS" : "FAIL"} — #{name}\n\n#{detail}\n\n"
end
unless failures.empty?
  report << "## Failures\n\n"
  failures.each { |failure| report << "- #{failure}\n" }
end
report << "\n**#{failures.empty? ? "READY FOR DELEGATED APPROVAL" : "NOT READY — VALIDATION FAILURES"}**\n"
File.write(File.join(ROOT, "reviews/MIN_000_022_validation.md"), report)

puts "Checks passed: #{checks.count { |item| item[2] }}"
puts "Checks failed: #{failures.length}"
puts "Stress tests: #{tests.length}"
puts "Generation assertions: #{atoms.length * 8}"
failures.each { |failure| warn failure }
exit(failures.empty? ? 0 : 1)
