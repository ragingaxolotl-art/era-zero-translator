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

def by_id(document)
  document.fetch("atoms").to_h { |record| [record.fetch("canonical_id"), record] }
end

def projection(record)
  record.slice(*AUTHORITY_FIELDS)
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

check.call("complete current lexicon", "324 unique records: 108 canonical and 216 provisional",
           atoms.length == 324 && all_atoms.length == 324 &&
             canonical_ids.length == 108 && provisional_ids.length == 216 &&
             canonical_ids.disjoint?(provisional_ids) &&
             (canonical_ids | provisional_ids).length == 324)
check.call("source-canonical immutability", "all 36 source records remain object-identical",
           source.length == 36 &&
             source.all? { |id, record| atoms[id] == record && all_atoms[id] == record })
check.call("reviewed-canonical ledger", "72 reviewed records match both authoritative lexicons",
           reviewed.length == 72 &&
             reviewed.all? do |id, record|
               projection(atoms.fetch(id)) == projection(record) &&
                 projection(all_atoms.fetch(id)) == projection(record)
             end)
check.call("provisional complement", "provisional file contains exactly 216 noncanonical IDs",
           provisional.length == 216 && provisional.keys.to_set == provisional_ids &&
             provisional.all? do |id, record|
               current = atoms.fetch(id)
               %w[
                 canonical_id family address universal_slot harmonic_signature_semitones
                 family_onset local_compact_root canonical_transliteration formal_carrier
                 note_path_semitones status
               ].all? { |field| current[field] == record[field] }
             end)

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

prior_migrations = %w[
  migrations/MOV_100_122_semantic_approval.yaml
  migrations/2026-07-29_pending_review_packets_approval.yaml
  migrations/MAT_200_222_semantic_approval.yaml
  migrations/MIN_000_022_semantic_approval.yaml
  migrations/MIN_100_122_semantic_approval.yaml
].map { |path| load_yaml(path) }
prior_promotions = prior_migrations.flat_map { |migration| migration.fetch("promoted_roots", []) }
check.call("earlier selective approvals preserved", "all 63 earlier approved meanings remain exact",
           prior_promotions.length == 63 &&
             prior_promotions.all? do |promotion|
               record = atoms.fetch(promotion.fetch("canonical_id"))
               record["title"] == promotion.fetch("canonical_title") &&
                 record["core_definition"] == promotion.fetch("invariant_definition")
             end)

recommendation = load_yaml("reviews/MIN_200_222_recommended_spec.yaml")
recommendation_roots = recommendation.fetch("roots")
check.call("MIN:200–222 canonical meaning", "all nine approved winners match the authoritative lexicon",
           recommendation.dig("metadata", "status") == "approved_and_canonical_by_delegated_authority" &&
             recommendation.dig("metadata", "roots_canonicalized").to_set == IDS.to_set &&
             recommendation_roots.all? do |root|
               id = root.dig("fixed_generated_fields", "canonical_id")
               record = atoms.fetch(id)
               record["status"] == "canonical" &&
                 record["title"] == root.fetch("proposed_title") &&
                 record["core_definition"] == root.fetch("invariant_definition") &&
                 root["canonicalized"] == true
             end)
check.call("MIN family completion", "all 27 MIN meanings are canonical with three distinct layer centers",
           atoms.values.count { |record| record["family"] == "MIN" && record["status"] == "canonical" } == 27 &&
             atoms.fetch("MIN:000")["title"].include?("representation") &&
             atoms.fetch("MIN:100")["title"].include?("revision") &&
             atoms.fetch("MIN:200")["title"].include?("attentional"))
check.call("MIN:200–222 fixed forms", "all copied generated fields remain exact",
           IDS.all? do |id|
             record = atoms.fetch(id)
             root = recommendation_roots.find do |item|
               item.dig("fixed_generated_fields", "canonical_id") == id
             end
             root.fetch("fixed_generated_fields") == {
               "canonical_id" => id,
               "universal_slot" => record["universal_slot"],
               "family_qualified_transliteration" => record["canonical_transliteration"],
               "local_compact_root" => record["local_compact_root"],
               "formal_carrier" => record["formal_carrier"],
               "harmonic_signature_semitones" => record["harmonic_signature_semitones"],
               "relative_note_path_semitones" => record["note_path_semitones"]
             }
           end)

migration = load_yaml("migrations/MIN_200_222_semantic_approval.yaml")
check.call("versioned approval migration", "migration records nine promotions and 108/216 inventory",
           migration.dig("metadata", "status") == "applied" &&
             migration.dig("metadata", "generated_fields_changed") == false &&
             migration.fetch("promoted_roots").map { |item| item["canonical_id"] }.to_set == IDS.to_set &&
             migration.dig("audit", "source_canonical_roots_changed") == false &&
             migration.dig("audit", "previous_review_approved_roots_changed") == false &&
             migration.dig("audit", "canonical_count_after") == 108 &&
             migration.dig("audit", "provisional_count_after") == 216 &&
             migration.dig("audit", "unreviewed_chunks_after") == 24)

canonical_spec = load_yaml("spec/canonical_spec.yaml")
canonical_spec_atoms = canonical_spec.dig("lexicon", "completed_atoms")
check.call("canonical specification", "canonical spec contains exactly 108 authoritative records",
           canonical_spec.dig("lexicon", "completed_count") == 108 &&
             canonical_spec.dig("lexicon", "remaining_count") == 216 &&
             canonical_spec_atoms.length == 108 &&
             canonical_spec_atoms.map { |record| record["canonical_id"] }.to_set == canonical_ids &&
             canonical_spec_atoms.all? { |record| atoms.fetch(record["canonical_id"]) == record })

authority = load_yaml("lexicon/semantic_authority.yaml")
approved_ranges = authority.fetch("approved_review_packets").map { |packet| packet["range"] }
check.call("semantic authority ledger", "108/216 inventory, eight packets, 24 chunks, no decision queue",
           authority.dig("semantic_inventory", "canonical_roots") == 108 &&
             authority.dig("semantic_inventory", "provisional_roots") == 216 &&
             approved_ranges == %w[
               MOV:100–122 MOV:200–222
               MAT:000–022 MAT:100–122 MAT:200–222
               MIN:000–022 MIN:100–122 MIN:200–222
             ] &&
             authority.fetch("review_packets_pending_user_decision").empty? &&
             authority.dig("semantic_review_progress", "canonical_review_chunks") == 8 &&
             authority.dig("semantic_review_progress", "unreviewed_chunks") == 24 &&
             authority.dig("semantic_review_progress", "unreviewed_roots") == 216 &&
             authority.dig("last_completed_review_packet", "range") == "MIN:200–222" &&
             authority.dig("next_review_packet", "range") == "CON:000–022")

version = load_yaml("spec/version.yaml")
phase2 = load_yaml("spec/phase2_provisional_spec.yaml")
standard = load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
readiness = load_yaml("spec/translator_readiness.yaml")
check.call("specification count reconciliation", "version, Phase 2, and standard report 108/216 and 24 chunks",
           version["canonical_semantic_roots"] == 108 &&
             version["provisional_semantic_roots"] == 216 &&
             version["unreviewed_nine_root_chunks"] == 24 &&
             version["next_semantic_review_packet"] == "CON:000–022" &&
             phase2.dig("scope", "canonical_meanings") == 108 &&
             phase2.dig("scope", "provisional_meanings") == 216 &&
             phase2.dig("scope", "remaining_review_chunks") == 24 &&
             standard.dig("inventory", "canonical_roots") == 108 &&
             standard.dig("inventory", "provisional_roots") == 216 &&
             standard.dig("inventory", "canonical_chunks") == 12 &&
             standard.dig("inventory", "provisional_review_chunks") == 24)
check.call("translator readiness reconciliation", "broad translator blocked; safe scope is 108 canonical IDs",
           readiness.dig("metadata", "broad_translator_authorized") == false &&
             readiness.dig("current_inventory", "canonical_meanings") == 108 &&
             readiness.dig("current_inventory", "provisional_meanings") == 216 &&
             readiness.dig("current_inventory", "unreviewed", "roots") == 216 &&
             readiness.dig("current_inventory", "unreviewed", "nine_root_chunks") == 24 &&
             readiness.dig("safe_now", "maximum_semantic_scope") == "108 canonical roots" &&
             readiness.dig("safe_now", "reject_provisional_roots") == true &&
             readiness["next_semantic_chunk_after_pending_decisions"] == "CON:000–022")

status_text = File.read(File.join(ROOT, "semantic_authority_status.md"))
roadmap_text = File.read(File.join(ROOT, "reports/translator_readiness_roadmap.md"))
approval_text = File.read(File.join(ROOT, "reviews/MIN_200_222_approval_record.md"))
check.call("human-readable status", "status, roadmap, and approval report final counts and next block",
           status_text.include?("108 CANONICAL ROOTS / 216 PROVISIONAL ROOTS") &&
             status_text.include?("CON:000–022`, **not begun**") &&
             roadmap_text.include?("108 meanings are canonical") &&
             roadmap_text.include?("216 meanings remain provisional in 24 nine-root chunks") &&
             roadmap_text.include?("`CON:000–022` is next") &&
             approval_text.include?("APPLIED — NINE ROOTS CANONICAL"))
check.call("review evidence", "validation, scoring, collisions, and 61 stress tests remain linked",
           File.read(File.join(ROOT, "reviews/MIN_200_222_validation.md"))
             .include?("Checks failed: **0**") &&
             load_yaml("reviews/MIN_200_222_scored_candidates.yaml")
               .dig("metadata", "status") == "approved_and_canonical_by_delegated_authority" &&
             File.read(File.join(ROOT, "reviews/MIN_200_222_collision_report.md"))
               .include?("COLLISIONS EXPLICITLY EXCLUDED OR COMPOUNDED") &&
             load_yaml("reviews/MIN_200_222_stress_tests.yaml")
               .dig("metadata", "test_count") == 61)
check.call("withdrawal preserved", "the broad Gate 3 approval remains withdrawn",
           atoms_doc.dig("metadata", "gate3_approval_status") ==
             "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION" &&
             authority.dig("metadata", "user_direction") ==
               "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION" &&
             migration.dig("metadata", "broad_gate3_history") ==
               "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION")
check.call("stop boundary", "CON:000–022, Gate 4, and translator implementation were not begun",
           Dir.glob(File.join(ROOT, "reviews/CON_000_022_*")).empty? &&
             authority.dig("stop_boundary", "do_not_begin").include?(
               "CON:000–022 in this approval packet"
             ) &&
             migration.dig("audit", "next_review_packet_begun") == false &&
             migration.dig("audit", "gate4_started") == false &&
             migration.dig("audit", "translator_implementation_started") == false)

report = +"# MIN:200–222 Canonization Validation\n\n"
report << "Status: **#{failures.empty? ? "PASS — DELEGATED APPROVAL APPLIED" : "FAIL"}**\n\n"
report << "- Checks passed: **#{checks.count { |item| item[2] }}**\n"
report << "- Checks failed: **#{failures.length}**\n"
report << "- Canonical roots: **#{canonical_ids.length}**\n"
report << "- Provisional roots: **#{provisional_ids.length}**\n"
report << "- Generation assertions: **#{atoms.length * 8}**\n\n"
checks.each do |name, detail, ok|
  report << "## #{ok ? "PASS" : "FAIL"} — #{name}\n\n#{detail}\n\n"
end
unless failures.empty?
  report << "## Failures\n\n"
  failures.each { |failure| report << "- #{failure}\n" }
end
report << "\n**#{failures.empty? ? "MIN:200–222 CANONICAL — NEXT BLOCK NOT BEGUN" : "CANONIZATION VALIDATION FAILED"}**\n"
File.write(File.join(ROOT, "reports/MIN_200_222_canonization_validation.md"), report)

puts "Checks passed: #{checks.count { |item| item[2] }}"
puts "Checks failed: #{failures.length}"
puts "Canonical: #{canonical_ids.length}; provisional: #{provisional_ids.length}"
puts "Generation assertions: #{atoms.length * 8}"
failures.each { |failure| warn failure }
exit(failures.empty? ? 0 : 1)
