#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MIN:100 MIN:101 MIN:102
  MIN:110 MIN:111 MIN:112
  MIN:120 MIN:121 MIN:122
].freeze
SCORE_KEYS = %w[
  atomicity address_fit family_fit neighbor_separation
  cross_family_separation compound_usefulness
  everyday_language_coverage technical_coverage
].freeze
REQUIRED_CANDIDATES = %w[
  current_phase2 representational_revision attention_reallocation
  inference_or_evaluation memory_access
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

def authority_projection(record)
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
canonical_ids = atoms.values.select { |record| record["status"] == "canonical" }.map { |record| record["canonical_id"] }.to_set
provisional_ids = atoms.values.select do |record|
  record["status"] == "provisional_pending_detailed_semantic_review"
end.map { |record| record["canonical_id"] }.to_set

check.call("pre-approval inventory", "324 records remain 90 canonical and 234 provisional",
           atoms.length == 324 && all_atoms.length == 324 &&
             canonical_ids.length == 90 && provisional_ids.length == 234 &&
             canonical_ids.disjoint?(provisional_ids) &&
             (canonical_ids | provisional_ids).length == 324)
check.call("source-canonical immutability", "all 36 source-developed records remain exact",
           source.length == 36 &&
             source.all? { |id, record| atoms[id] == record && all_atoms[id] == record })
check.call("reviewed-canonical immutability", "all 54 reviewed canonical records remain exact",
           reviewed.length == 54 &&
             reviewed.all? do |id, record|
               authority_projection(atoms.fetch(id)) == authority_projection(record) &&
                 authority_projection(all_atoms.fetch(id)) == authority_projection(record)
             end)
check.call("target authority before approval", "all nine MIN:100–122 records remain provisional",
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

scored = load_yaml("reviews/MIN_100_122_scored_candidates.yaml")
recommended = load_yaml("reviews/MIN_100_122_recommended_spec.yaml")
stress = load_yaml("reviews/MIN_100_122_stress_tests.yaml")
scored_roots = scored.fetch("roots")
recommended_roots = recommended.fetch("roots")

check.call("review scope", "the packet contains exactly MIN:100–122 and nothing else",
           scored_roots.map { |root| root["canonical_id"] } == IDS &&
             recommended_roots.map { |root| root.dig("fixed_generated_fields", "canonical_id") } == IDS)
check.call("candidate breadth", "five genuinely different architecture candidates appear for every root",
           scored_roots.all? do |root|
             root.fetch("candidates").map { |candidate| candidate["candidate_id"] } == REQUIRED_CANDIDATES &&
               root.fetch("candidates").map { |candidate| candidate["title"] }.uniq.length == 5
           end)
score_count = scored_roots.sum { |root| root.fetch("candidates").sum { |candidate| candidate.fetch("scores").length } }
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
check.call("winner selection", "representational revision is the unique highest-scoring candidate for all nine",
           scored_roots.all? do |root|
             candidates = root.fetch("candidates")
             best = candidates.map { |candidate| candidate["total"] }.max
             winners = candidates.select { |candidate| candidate["total"] == best }
             root["recommended_candidate_id"] == "representational_revision" &&
               winners.length == 1 && winners.first["candidate_id"] == "representational_revision"
           end)
check.call("current candidate provenance", "every current candidate exactly quotes the replaceable Phase 2 record",
           scored_roots.all? do |root|
             current = root.fetch("candidates").find { |candidate| candidate["candidate_id"] == "current_phase2" }
             atom = atoms.fetch(root.fetch("canonical_id"))
             current["title"] == atom["title"] &&
               current["invariant_candidate"] == atom["core_definition"]
           end)
check.call("fixed generated fields", "both review YAML files copy all seven fixed fields exactly",
           IDS.all? do |id|
             atom = atoms.fetch(id)
             scored_root = scored_roots.find { |root| root["canonical_id"] == id }
             spec_root = recommended_roots.find { |root| root.dig("fixed_generated_fields", "canonical_id") == id }
             scored_root["fixed_generated_fields"] == fixed_projection(atom) &&
               spec_root["fixed_generated_fields"] == fixed_projection(atom) &&
               scored_root["fixed_generated_fields"].keys == FIXED_FIELDS
           end)

expected_titles = {
  "MIN:100" => "completed self-model revision",
  "MIN:101" => "active self-model revision",
  "MIN:102" => "nonactualized self-model revision",
  "MIN:110" => "completed target-model revision",
  "MIN:111" => "active target-model revision",
  "MIN:112" => "nonactualized target-model revision",
  "MIN:120" => "completed shared-schema revision",
  "MIN:121" => "active shared-schema revision",
  "MIN:122" => "nonactualized shared-schema revision"
}
check.call("coherent 3x3 semantic grid", "titles express one scope axis and one phase axis",
           recommended_roots.all? do |root|
             id = root.dig("fixed_generated_fields", "canonical_id")
             root["proposed_title"] == expected_titles.fetch(id) &&
               root["semantic_center"] == "cognitive representational revision"
           end)
check.call("invariant atomic definitions", "every winner defines one representational-change process",
           recommended_roots.all? do |root|
             definition = root.fetch("invariant_definition")
             definition.match?(/\A(?:A completed cognitive process|An active cognitive process|A cognitive process)/) &&
               definition.include?("representation") &&
               definition.match?(/\bchang(?:e|ing)\b/) &&
               !definition.match?(/\b(memory, insight|observing, questioning|perceptions, memories)\b/i)
           end)
nonactualized_roots = recommended_roots.select do |root|
  root.dig("fixed_generated_fields", "canonical_id").end_with?("2")
end
banned = /\b(planned|intended|scheduled|queued|prepared|ready|probable|future)\b/i
check.call("lexical 1x2 compliance", "all three *2 winners are nonactualized without planning leakage",
           nonactualized_roots.length == 3 &&
             nonactualized_roots.all? do |root|
               root["proposed_title"].start_with?("nonactualized") &&
                 root["invariant_definition"].include?("not active or completed") &&
                 !root["invariant_definition"].match?(banned) &&
                 root.dig("address_justification", "third_trit").include?("does not encode a plan")
             end)
check.call("boundaries and neighbors", "every root states inclusion, exclusions, and five nearest neighbors",
           recommended_roots.all? do |root|
             root.fetch("inclusion_boundary").length > 180 &&
               root.fetch("excluded_meanings").length >= 5 &&
               root.fetch("nearest_neighbors").length == 5 &&
               root.fetch("same_family_contrast").include?("owns the representation")
           end)
check.call("cross-family audit", "every root has a tailored comparison for all eleven competing families",
           recommended_roots.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys == CROSS_FAMILIES &&
               comparisons.values.all? { |value| value.length > 80 }
           end)
check.call("runtime-state tailoring", "every root defines [0], [1], [2]/num and lexical/runtime separation",
           recommended_roots.all? do |root|
             runtime = root.fetch("runtime_state_interpretation")
             runtime.keys == %w[0 1 2/num] &&
               runtime.values.all? { |value| value.include?("revision") } &&
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
check.call("coverage stress tests", "51 unique English concepts permit atoms, compounds, grammar, families, and gaps",
           stress.dig("metadata", "test_count") == 51 &&
             stress_tests.length == 51 &&
             stress_tests.map { |test| test["english_concept"] }.uniq.length == 51 &&
             routes.length >= 8 &&
             stress_tests.all? { |test| test.fetch("analysis").length > 45 })

review_text = File.read(File.join(ROOT, "reviews/MIN_100_122_peer_review.md"))
collision_text = File.read(File.join(ROOT, "reviews/MIN_100_122_collision_report.md"))
check.call("human-readable peer review", "all roots, matrices, stress tests, and approval boundary are present",
           IDS.all? { |id| review_text.include?("## #{id} —") } &&
             review_text.include?("## Triplet coherence") &&
             review_text.include?("## Nine-root ownership matrix") &&
             review_text.include?("51 English concepts were tested") &&
             review_text.include?("not canonical in this review artifact"))
check.call("collision report", "all nine roots and eleven families are explicitly audited",
           IDS.all? { |id| collision_text.include?("| #{id} |") } &&
             CROSS_FAMILIES.all? { |family| collision_text.include?("**#{family}:**") } &&
             collision_text.include?("MIN:*2") &&
             collision_text.include?("MIN:120–122` versus `CON"))
check.call("authority and stop boundary", "broad withdrawal remains; no approval, MIN:200, Gate 4, or translator work has begun",
           atoms_doc.dig("metadata", "gate3_approval_status") ==
             "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION" &&
             recommended.dig("metadata", "status") == "recommended_pending_delegated_approval" &&
             recommended_roots.none? { |root| root["canonicalized"] } &&
             recommended.dig("metadata", "gate4_started") == false &&
             recommended.dig("metadata", "translator_started") == false &&
             Dir.glob(File.join(ROOT, "reviews/MIN_200_222_*")).empty?)

report = +"# MIN:100–122 Pre-Approval Validation\n\n"
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
File.write(File.join(ROOT, "reviews/MIN_100_122_validation.md"), report)

puts "Checks passed: #{checks.count { |item| item[2] }}"
puts "Checks failed: #{failures.length}"
puts "Candidates: 45; score assertions: #{score_count}"
puts "Stress tests: #{stress_tests.length}; generation assertions: #{atoms.length * 8}"
failures.each { |failure| warn failure }
exit(failures.empty? ? 0 : 1)
