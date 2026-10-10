#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MIN:200 MIN:201 MIN:202
  MIN:210 MIN:211 MIN:212
  MIN:220 MIN:221 MIN:222
].freeze
SCORE_KEYS = %w[
  atomicity address_fit family_fit neighbor_separation
  cross_family_separation compound_usefulness
  everyday_language_coverage technical_coverage
].freeze
CANDIDATE_IDS = %w[
  current_phase2 attention_allocation representational_grounding
  epistemic_stance executive_control
].freeze
EXAMPLE_CATEGORIES = %w[
  ordinary_conversation physical_or_spatial temporal_or_sequential
  cross_family_compound executable_or_programming counterexample
].freeze
CROSS_FAMILIES = %w[LIF MOV MAT CON STR WRN REP LOG DAT CRE ORI].freeze
FIXED_FIELDS = %w[
  canonical_id universal_slot family_qualified_transliteration
  local_compact_root formal_carrier harmonic_signature_semitones
  relative_note_path_semitones
].freeze
AUTHORITY_FIELDS = %w[
  canonical_id title core_definition status family address universal_slot
  harmonic_signature_semitones family_onset local_compact_root
  canonical_transliteration formal_carrier note_path_semitones
].freeze
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

def load_yaml(path)
  YAML.load_file(File.join(ROOT, path))
end

def by_id(document)
  document.fetch("atoms").to_h { |record| [record.fetch("canonical_id"), record] }
end

def projection(record)
  record.slice(*AUTHORITY_FIELDS)
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

yaml_files = Dir[File.join(ROOT, "{lexicon,spec,reviews,migrations,extraction}/**/*.{yaml,yml}")]
yaml_failures = yaml_files.map do |path|
  begin
    YAML.load_file(path)
    nil
  rescue StandardError => error
    "#{path.delete_prefix("#{ROOT}/")}: #{error.message}"
  end
end.compact
check.call("machine-readable syntax", "all #{yaml_files.length} YAML files parse", yaml_failures.empty?)

atoms_doc = load_yaml("lexicon/atoms.yaml")
all_doc = load_yaml("lexicon/all_atoms.yaml")
source_doc = load_yaml("lexicon/completed_atoms.yaml")
reviewed_doc = load_yaml("lexicon/reviewed_canonical_atoms.yaml")
provisional_doc = load_yaml("lexicon/provisional_atoms.yaml")
atoms = by_id(atoms_doc)
all_atoms = by_id(all_doc)
source = by_id(source_doc)
reviewed = by_id(reviewed_doc)
provisional = by_id(provisional_doc)
canonical_ids = atoms.values.select { |record| record["status"] == "canonical" }
                     .map { |record| record["canonical_id"] }.to_set
provisional_ids = atoms.values.select do |record|
  record["status"] == "provisional_pending_detailed_semantic_review"
end.map { |record| record["canonical_id"] }.to_set

check.call("pre-approval inventory", "324 records remain 99 canonical and 225 provisional",
           atoms.length == 324 && all_atoms.length == 324 &&
             canonical_ids.length == 99 && provisional_ids.length == 225 &&
             canonical_ids.disjoint?(provisional_ids) &&
             (canonical_ids | provisional_ids).length == 324)
check.call("source-canonical immutability", "all 36 source-developed records remain exact",
           source.length == 36 &&
             source.all? { |id, record| atoms[id] == record && all_atoms[id] == record })
check.call("reviewed-canonical immutability", "all 63 reviewed canonical records remain exact",
           reviewed.length == 63 &&
             reviewed.all? do |id, record|
               projection(atoms.fetch(id)) == projection(record) &&
                 projection(all_atoms.fetch(id)) == projection(record)
             end)
check.call("target authority before approval", "all nine MIN:200–222 records remain provisional",
           IDS.all? { |id| provisional_ids.include?(id) && provisional.key?(id) })

algorithm_errors = []
atoms.each_value do |atom|
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
check.call("accepted generation algorithms", "all 2,592 fixed-field assertions pass",
           algorithm_errors.empty?)

scored = load_yaml("reviews/MIN_200_222_scored_candidates.yaml")
recommended = load_yaml("reviews/MIN_200_222_recommended_spec.yaml")
stress = load_yaml("reviews/MIN_200_222_stress_tests.yaml")
scored_roots = scored.fetch("roots")
recommended_roots = recommended.fetch("roots")

check.call("review scope", "the packet contains exactly MIN:200–222 and nothing else",
           scored_roots.map { |root| root["canonical_id"] } == IDS &&
             recommended_roots.map { |root| root.dig("fixed_generated_fields", "canonical_id") } == IDS)
check.call("candidate breadth", "five genuinely different architecture candidates appear for every root",
           scored_roots.all? do |root|
             root.fetch("candidates").map { |candidate| candidate["candidate_id"] } == CANDIDATE_IDS &&
               root.fetch("candidates").map { |candidate| candidate["title"] }.uniq.length == 5
           end)
score_count = scored_roots.sum do |root|
  root.fetch("candidates").sum { |candidate| candidate.fetch("scores").length }
end
check.call("candidate scoring", "45 candidates carry all eight requested scores: 360 values",
           scored.dig("metadata", "scored_categories") == SCORE_KEYS &&
             scored_roots.sum { |root| root.fetch("candidates").length } == 45 &&
             score_count == 360 &&
             scored_roots.all? do |root|
               root.fetch("candidates").all? do |candidate|
                 scores = candidate.fetch("scores")
                 scores.keys == SCORE_KEYS &&
                   scores.values.all? { |value| value.is_a?(Integer) && value.between?(1, 10) } &&
                   candidate["total"] == scores.values.sum &&
                   candidate["maximum"] == 80
               end
             end)
check.call("winner selection", "attention allocation is the unique highest-scoring candidate for all nine",
           scored_roots.all? do |root|
             candidates = root.fetch("candidates")
             best = candidates.map { |candidate| candidate["total"] }.max
             winners = candidates.select { |candidate| candidate["total"] == best }
             root["recommended_candidate_id"] == "attention_allocation" &&
               winners.length == 1 && winners.first["candidate_id"] == "attention_allocation"
           end)
check.call("current candidate provenance", "every current candidate exactly quotes the Phase 2 record",
           scored_roots.all? do |root|
             current = root.fetch("candidates").find do |candidate|
               candidate["candidate_id"] == "current_phase2"
             end
             atom = atoms.fetch(root.fetch("canonical_id"))
             current["title"] == atom["title"] &&
               current["invariant_candidate"] == atom["core_definition"]
           end)
check.call("fixed generated fields", "both review YAML files copy all seven fixed fields exactly",
           IDS.all? do |id|
             atom = atoms.fetch(id)
             scored_root = scored_roots.find { |root| root["canonical_id"] == id }
             spec_root = recommended_roots.find do |root|
               root.dig("fixed_generated_fields", "canonical_id") == id
             end
             scored_root["fixed_generated_fields"] == fixed_projection(atom) &&
               spec_root["fixed_generated_fields"] == fixed_projection(atom) &&
               spec_root["fixed_generated_fields"].keys == FIXED_FIELDS
           end)

expected_titles = {
  "MIN:200" => "enduring attentional capacity",
  "MIN:201" => "available attentional capacity",
  "MIN:202" => "latent attentional capacity",
  "MIN:210" => "established target-attention relation",
  "MIN:211" => "active target attention",
  "MIN:212" => "unresolved target-attention relation",
  "MIN:220" => "established joint-attention relation",
  "MIN:221" => "active joint attention",
  "MIN:222" => "potential joint attention"
}
check.call("coherent 3x3 semantic grid", "titles express attention with exact capacity/target/joint status",
           recommended_roots.all? do |root|
             id = root.dig("fixed_generated_fields", "canonical_id")
             root["proposed_title"] == expected_titles.fetch(id) &&
               root["semantic_center"] == "selective allocation of cognitive processing"
           end)
check.call("invariant atomic definitions", "every winner defines one capacity or attention relation",
           recommended_roots.all? do |root|
             definition = root.fetch("invariant_definition")
             definition.include?("cognizer") &&
               definition.match?(/capacity|relation/) &&
               definition.match?(/cognitive processing|attentional/) &&
               !definition.match?(/\b(understand, remember|interpreting, trusting|explanations or understandings)\b/i)
           end)
check.call("address-axis compliance", "first-, second-, and third-trit justifications are tailored for all nine",
           recommended_roots.all? do |root|
             justification = root.fetch("address_justification")
             justification.keys == %w[first_trit_2 second_trit third_trit] &&
               justification.values.all? { |value| value.length > 70 }
           end)
check.call("boundaries and neighbors", "every root states inclusion, exclusions, and eight nearest neighbors",
           recommended_roots.all? do |root|
             root.fetch("inclusion_boundary").length > 220 &&
               root.fetch("excluded_meanings").length == 5 &&
               root.fetch("nearest_neighbors").length == 8 &&
               root.fetch("same_family_contrast").include?("owns")
           end)
check.call("cross-family audit", "every root has a comparison for all eleven competing families",
           recommended_roots.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys == CROSS_FAMILIES &&
               comparisons.values.all? { |value| value.length > 90 }
           end)
check.call("runtime-state tailoring", "every root defines [0], [1], [2]/num and lexical/runtime separation",
           recommended_roots.all? do |root|
             runtime = root.fetch("runtime_state_interpretation")
             runtime.keys == %w[0 1 2/num] &&
               runtime.values.all? { |value| value.include?(root.fetch("proposed_title")) } &&
               root.fetch("lexical_runtime_distinction").include?("third lexical trit") &&
               root.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`")
           end)
check.call("example completeness", "54 examples include graph, gloss, English, runtime, contour, roles, and counterexample status",
           recommended_roots.sum { |root| root.fetch("examples").length } == 54 &&
             recommended_roots.all? do |root|
               examples = root.fetch("examples")
               examples.map { |item| item["category"] } == EXAMPLE_CATEGORIES &&
                 examples.all? do |item|
                   item.fetch("semantic_graph").include?("(") &&
                     !item.fetch("literal_gloss").empty? &&
                     !item.fetch("natural_english").empty? &&
                     [0, 1, 2].include?(item.fetch("runtime_state")) &&
                     !item.fetch("contour").empty? &&
                     item.fetch("role_registers").keys == %w[low middle high sustained]
                 end &&
                 examples.last["use_status"] == "must_not_use_this_root"
             end)
check.call("future extensibility", "every root supplies four compound patterns and a later-era stability note",
           recommended_roots.all? do |root|
             root.fetch("future_compound_examples").length == 4 &&
               root.fetch("later_era_notes").include?("invariant")
           end)

stress_tests = stress.fetch("tests")
routes = stress_tests.map { |test| test["routing"] }.to_set
check.call("coverage stress tests", "61 unique English concepts permit atoms, compounds, grammar, families, and gaps",
           stress.dig("metadata", "test_count") == 61 &&
             stress_tests.length == 61 &&
             stress_tests.map { |test| test["english_concept"] }.uniq.length == 61 &&
             routes.length >= 12 &&
             stress_tests.all? { |test| test.fetch("analysis").length > 45 })

review_text = File.read(File.join(ROOT, "reviews/MIN_200_222_peer_review.md"))
collision_text = File.read(File.join(ROOT, "reviews/MIN_200_222_collision_report.md"))
check.call("human-readable peer review", "all roots, matrices, tests, and approval boundary are present",
           IDS.all? { |id| review_text.include?("## #{id} —") } &&
             review_text.include?("## Triplet coherence") &&
             review_text.include?("## Nine-root ownership matrix") &&
             review_text.include?("61 English concepts were tested") &&
             review_text.include?("not canonical in this review artifact"))
check.call("collision report", "all nine roots and eleven families are explicitly audited",
           IDS.all? { |id| collision_text.include?("| #{id} |") } &&
             CROSS_FAMILIES.all? { |family| collision_text.include?("**#{family}:**") } &&
             collision_text.include?("MIN:212[1]") &&
             collision_text.include?("MIN:222` versus `CRE"))
check.call("authority and stop boundary", "broad withdrawal remains; no approval, CON review, Gate 4, or translator work has begun",
           atoms_doc.dig("metadata", "gate3_approval_status") ==
             "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION" &&
             recommended.dig("metadata", "status") == "recommended_pending_delegated_approval" &&
             recommended_roots.none? { |root| root["canonicalized"] } &&
             recommended.dig("metadata", "gate4_started") == false &&
             recommended.dig("metadata", "translator_started") == false &&
             Dir.glob(File.join(ROOT, "reviews/CON_000_022_*")).empty?)

report = +"# MIN:200–222 Pre-Approval Validation\n\n"
report << "Status: **#{failures.empty? ? "PASS — READY FOR DELEGATED APPROVAL" : "FAIL"}**\n\n"
report << "- Checks passed: **#{checks.count { |item| item[2] }}**\n"
report << "- Checks failed: **#{failures.length}**\n"
report << "- Candidate architectures scored: **45**\n"
report << "- Individual score assertions: **#{score_count}**\n"
report << "- English coverage tests: **#{stress_tests.length}**\n"
report << "- Fixed generation assertions: **#{atoms.length * 8}**\n\n"
checks.each do |name, detail, ok|
  report << "## #{ok ? "PASS" : "FAIL"} — #{name}\n\n#{detail}\n\n"
end
unless failures.empty?
  report << "## Failures\n\n"
  failures.each { |failure| report << "- #{failure}\n" }
end
report << "\n**#{failures.empty? ? "REVIEW VALIDATED — NO ROOT CANONICALIZED BY THIS CHECK" : "REVIEW VALIDATION FAILED"}**\n"
File.write(File.join(ROOT, "reviews/MIN_200_222_validation.md"), report)

puts "Checks passed: #{checks.count { |item| item[2] }}"
puts "Checks failed: #{failures.length}"
puts "Candidates: 45; score assertions: #{score_count}"
puts "Stress tests: #{stress_tests.length}; generation assertions: #{atoms.length * 8}"
failures.each { |failure| warn failure }
exit(failures.empty? ? 0 : 1)
