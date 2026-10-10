#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MAT:200 MAT:201 MAT:202
  MAT:210 MAT:211 MAT:212
  MAT:220 MAT:221 MAT:222
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

def projection(record)
  record.slice(*AUTHORITY_FIELDS)
end

def by_id(document)
  document.fetch("atoms").to_h { |record| [record.fetch("canonical_id"), record] }
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

check.call("complete current lexicon", "324 unique records: 81 canonical and 243 provisional",
           atoms.length == 324 && all_atoms.length == 324 &&
             canonical_ids.length == 81 && provisional_ids.length == 243 &&
             canonical_ids.disjoint?(provisional_ids) &&
             (canonical_ids | provisional_ids).length == 324)
check.call("source-canonical immutability", "all 36 source records remain object-identical in both current lexicons",
           source.length == 36 &&
             source.all? { |id, record| atoms[id] == record && all_atoms[id] == record })
check.call("reviewed-canonical ledger", "45 reviewed records exactly match authoritative fields in both current lexicons",
           reviewed.length == 45 &&
             reviewed.all? do |id, record|
               projection(atoms.fetch(id)) == projection(record) &&
                 projection(all_atoms.fetch(id)) == projection(record)
             end)
check.call("provisional complement",
           "the provisional file contains the exact 243 noncanonical IDs with unchanged generated fields and provisional status",
           provisional.length == 243 && provisional.keys.to_set == provisional_ids &&
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

prior_migration = load_yaml("migrations/2026-07-29_pending_review_packets_approval.yaml")
mov_migration = load_yaml("migrations/MOV_100_122_semantic_approval.yaml")
prior_promotions =
  mov_migration.fetch("promoted_roots", []) +
  prior_migration.fetch("promoted_roots")
check.call("earlier selective approvals preserved", "all 36 earlier approved titles and definitions remain exact",
           prior_promotions.length == 36 &&
             prior_promotions.all? do |promotion|
               record = atoms.fetch(promotion.fetch("canonical_id"))
               record["title"] == promotion.fetch("canonical_title") &&
                 record["core_definition"] == promotion.fetch("invariant_definition")
             end)

recommendation = load_yaml("reviews/MAT_200_222_recommended_spec.yaml")
recommendation_roots = recommendation.fetch("roots")
check.call("MAT:200–222 canonical meaning", "all nine approved winners exactly match the authoritative lexicon",
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
check.call("MAT:200–222 fixed forms", "no generated family, address, slot, onset, root, carrier, harmony, or path changed",
           IDS.all? do |id|
             record = atoms.fetch(id)
             root = recommendation_roots.find { |item| item.dig("fixed_generated_fields", "canonical_id") == id }
             copied = root.fetch("fixed_generated_fields")
             copied == {
               "canonical_id" => id,
               "universal_slot" => record["universal_slot"],
               "family_qualified_transliteration" => record["canonical_transliteration"],
               "local_compact_root" => record["local_compact_root"],
               "formal_carrier" => record["formal_carrier"],
               "harmonic_signature_semitones" => record["harmonic_signature_semitones"],
               "relative_note_path_semitones" => record["note_path_semitones"]
             }
           end)

migration = load_yaml("migrations/MAT_200_222_semantic_approval.yaml")
check.call("versioned approval migration", "migration records nine promotions, unchanged generated fields, and 81/243 counts",
           migration.dig("metadata", "status") == "applied" &&
             migration.dig("metadata", "generated_fields_changed") == false &&
             migration.fetch("promoted_roots").map { |item| item["canonical_id"] }.to_set == IDS.to_set &&
             migration.dig("audit", "source_canonical_roots_changed") == false &&
             migration.dig("audit", "previous_review_approved_roots_changed") == false &&
             migration.dig("audit", "canonical_count_after") == 81 &&
             migration.dig("audit", "provisional_count_after") == 243)

canonical_spec = load_yaml("spec/canonical_spec.yaml")
canonical_spec_atoms = canonical_spec.dig("lexicon", "completed_atoms")
check.call("canonical specification", "canonical spec contains exactly the 81 canonical authoritative records",
           canonical_spec.dig("lexicon", "completed_count") == 81 &&
             canonical_spec.dig("lexicon", "remaining_count") == 243 &&
             canonical_spec_atoms.length == 81 &&
             canonical_spec_atoms.map { |record| record["canonical_id"] }.to_set == canonical_ids &&
             canonical_spec_atoms.all? { |record| atoms.fetch(record["canonical_id"]) == record })

authority = load_yaml("lexicon/semantic_authority.yaml")
approved_ranges = authority.fetch("approved_review_packets").map { |packet| packet["range"] }
check.call("semantic authority ledger", "81/243 inventory, five approved packets, 27 unreviewed chunks, and no pending decision",
           authority.dig("semantic_inventory", "canonical_roots") == 81 &&
             authority.dig("semantic_inventory", "provisional_roots") == 243 &&
             approved_ranges == %w[
               MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122 MAT:200–222
             ] &&
             authority.fetch("review_packets_pending_user_decision").empty? &&
             authority.dig("semantic_review_progress", "canonical_review_chunks") == 5 &&
             authority.dig("semantic_review_progress", "unreviewed_chunks") == 27 &&
             authority.dig("semantic_review_progress", "unreviewed_roots") == 243 &&
             authority.dig("last_completed_review_packet", "range") == "MAT:200–222" &&
             authority.dig("next_review_packet", "range") == "MIN:000–022" &&
             authority.dig("next_review_packet", "status") == "not_begun")

version = load_yaml("spec/version.yaml")
phase2 = load_yaml("spec/phase2_provisional_spec.yaml")
standard = load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
readiness = load_yaml("spec/translator_readiness.yaml")
check.call("specification count reconciliation", "version, Phase 2, and core standard all report 81/243 and 27 chunks",
           version["canonical_semantic_roots"] == 81 &&
             version["provisional_semantic_roots"] == 243 &&
             version["unreviewed_nine_root_chunks"] == 27 &&
             phase2.dig("scope", "canonical_meanings") == 81 &&
             phase2.dig("scope", "provisional_meanings") == 243 &&
             phase2.dig("scope", "remaining_review_chunks") == 27 &&
             standard.dig("inventory", "canonical_roots") == 81 &&
             standard.dig("inventory", "provisional_roots") == 243 &&
             standard.dig("inventory", "canonical_chunks") == 9 &&
             standard.dig("inventory", "provisional_review_chunks") == 27)
check.call("translator readiness reconciliation", "broad translator remains blocked; safe scope is exactly 81 canonical IDs",
           readiness.dig("metadata", "broad_translator_authorized") == false &&
             readiness.dig("current_inventory", "canonical_meanings") == 81 &&
             readiness.dig("current_inventory", "provisional_meanings") == 243 &&
             readiness.dig("current_inventory", "unreviewed", "roots") == 243 &&
             readiness.dig("current_inventory", "unreviewed", "nine_root_chunks") == 27 &&
             readiness.dig("safe_now", "maximum_semantic_scope") == "81 canonical roots" &&
             readiness.dig("safe_now", "reject_provisional_roots") == true &&
             readiness["next_semantic_chunk_after_pending_decisions"] == "MIN:000–022")

status_text = File.read(File.join(ROOT, "semantic_authority_status.md"))
roadmap_text = File.read(File.join(ROOT, "reports/translator_readiness_roadmap.md"))
check.call("human-readable status", "authority summary and translator roadmap report the final counts and next block",
           status_text.include?("81 CANONICAL ROOTS / 243 PROVISIONAL ROOTS") &&
             status_text.include?("MIN:000–022`, **not begun**") &&
             roadmap_text.include?("81 meanings are canonical") &&
             roadmap_text.include?("243 meanings remain provisional in 27 nine-root chunks") &&
             roadmap_text.include?("`MIN:000–022` is next"))
check.call("withdrawal preserved", "the broad Gate 3 approval remains withdrawn everywhere that controls authority",
           atoms_doc.dig("metadata", "gate3_approval_status") ==
             "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION" &&
             authority.dig("metadata", "user_direction") ==
               "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION" &&
             migration.dig("metadata", "broad_gate3_history") ==
               "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION")
check.call("stop boundary", "MIN review, Gate 4, and translator implementation were not begun",
           Dir.glob(File.join(ROOT, "reviews/MIN_000*")).empty? &&
             authority.dig("stop_boundary", "do_not_begin").include?("MIN:000–022 in this approval packet") &&
             migration.dig("audit", "next_review_packet_begun") == false &&
             migration.dig("audit", "gate4_started") == false &&
             migration.dig("audit", "translator_implementation_started") == false)

report = +"# MAT:200–222 Canonization Validation\n\n"
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
report << "\n**#{failures.empty? ? "MAT:200–222 CANONICAL — NEXT BLOCK NOT BEGUN" : "CANONIZATION VALIDATION FAILED"}**\n"
File.write(File.join(ROOT, "reports/MAT_200_222_canonization_validation.md"), report)

puts "Checks passed: #{checks.count { |item| item[2] }}"
puts "Checks failed: #{failures.length}"
puts "Canonical: #{canonical_ids.length}; provisional: #{provisional_ids.length}"
puts "Generation assertions: #{atoms.length * 8}"
failures.each { |failure| warn failure }
exit(failures.empty? ? 0 : 1)
