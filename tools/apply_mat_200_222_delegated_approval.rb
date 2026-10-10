#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MAT:200 MAT:201 MAT:202
  MAT:210 MAT:211 MAT:212
  MAT:220 MAT:221 MAT:222
].freeze
RANGE = "MAT:200–222"
RECOMMENDATION_PATH = "reviews/MAT_200_222_recommended_spec.yaml"
SCORED_PATH = "reviews/MAT_200_222_scored_candidates.yaml"
REVIEW_PATH = "reviews/MAT_200_222_peer_review.md"
VALIDATION_PATH = "reviews/MAT_200_222_validation.md"
MIGRATION_PATH = "migrations/MAT_200_222_semantic_approval.yaml"
APPROVAL_RECORD_PATH = "reviews/MAT_200_222_approval_record.md"
FIXED_FIELDS = %w[
  family address universal_slot harmonic_signature_semitones family_onset
  local_compact_root canonical_transliteration formal_carrier note_path_semitones
].freeze
AUTHORITY_FIELDS = %w[
  canonical_id title core_definition status family address universal_slot
  harmonic_signature_semitones family_onset local_compact_root
  canonical_transliteration formal_carrier note_path_semitones
].freeze

def load_yaml(path)
  YAML.load_file(File.join(ROOT, path))
end

def write_yaml(path, value)
  File.write(File.join(ROOT, path), YAML.dump(value))
end

def record_for(document, id)
  document.fetch("atoms").find { |record| record["canonical_id"] == id } ||
    raise("Missing #{id}")
end

def authority_projection(record)
  record.slice(*AUTHORITY_FIELDS)
end

validation = File.read(File.join(ROOT, VALIDATION_PATH))
raise("MAT:200–222 validation is not ready") unless
  validation.rstrip.end_with?("**READY FOR DELEGATED APPROVAL**")

recommended = load_yaml(RECOMMENDATION_PATH)
scored = load_yaml(SCORED_PATH)
raise("Recommendation is not pending delegated approval") unless
  recommended.dig("metadata", "status") == "ready_for_delegated_approval_not_yet_canonical" &&
    recommended.dig("metadata", "delegated_approval_authorized") == true &&
    recommended.dig("metadata", "roots_canonicalized") == []
raise("Scored review is not pending delegated approval") unless
  scored.dig("metadata", "status") == "ready_for_delegated_approval_not_yet_canonical" &&
    scored.dig("metadata", "delegated_approval_authorized") == true

recommendations = recommended.fetch("roots").to_h do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  [id, root]
end
raise("Unexpected recommendation scope") unless recommendations.keys.sort == IDS.sort

atoms = load_yaml("lexicon/atoms.yaml")
all_atoms = load_yaml("lexicon/all_atoms.yaml")
provisional = load_yaml("lexicon/provisional_atoms.yaml")
source = load_yaml("lexicon/completed_atoms.yaml")
reviewed = load_yaml("lexicon/reviewed_canonical_atoms.yaml")

source_snapshot = Marshal.load(Marshal.dump(source))
reviewed_snapshot = reviewed.fetch("atoms").to_h do |record|
  [record.fetch("canonical_id"), authority_projection(record)]
end
raise("Expected 36 previously reviewed roots") unless reviewed_snapshot.length == 36

fixed_before = {}
[atoms, all_atoms, provisional].each_with_index do |document, index|
  IDS.each do |id|
    record = record_for(document, id)
    raise("#{id} is not provisional before approval") unless
      record["status"] == "provisional_pending_detailed_semantic_review"
    fixed_before[[index, id]] = record.slice(*FIXED_FIELDS)
    copied = recommendations.fetch(id).fetch("fixed_generated_fields")
    expected = {
      "canonical_id" => id,
      "universal_slot" => record["universal_slot"],
      "family_qualified_transliteration" => record["canonical_transliteration"],
      "local_compact_root" => record["local_compact_root"],
      "formal_carrier" => record["formal_carrier"],
      "harmonic_signature_semitones" => record["harmonic_signature_semitones"],
      "relative_note_path_semitones" => record["note_path_semitones"]
    }
    raise("Generated-field mismatch for #{id}") unless copied == expected
  end
end

[atoms, all_atoms].each do |document|
  IDS.each do |id|
    record = record_for(document, id)
    root = recommendations.fetch(id)
    prior = record_for(provisional, id)
    record["title"] = root.fetch("proposed_title")
    record["core_definition"] = root.fetch("invariant_definition")
    record["translation_candidates"] = [root.fetch("proposed_title")]
    record["distinctions_and_exclusions"] = root.fetch("excluded_meanings")
    record["neighbor_contrasts"] =
      root.fetch("nearest_neighbors").values.flatten.grep(/\A[A-Z]{3}:\d{3}\z/).uniq
    record["status"] = "canonical"
    record["approval_effect"] =
      "CANONICAL BY EXPLICIT USER-DELEGATED APPROVAL AFTER DETAILED ADVERSARIAL REVIEW."
    record["semantic_origin"] =
      "Detailed MAT:200–222 peer-review winner approved under the user's explicit delegation."
    record["canonical_version"] = "1.0.3-delegated-semantic-overlay"
    record["review_history"] = {
      "withdrawn_broad_gate3_promotion" =>
        "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION",
      "detailed_peer_review" => REVIEW_PATH,
      "scored_candidates" => SCORED_PATH,
      "validation" => VALIDATION_PATH,
      "recommendation" => RECOMMENDATION_PATH,
      "delegated_approval_migration" => MIGRATION_PATH
    }
    record["canonization"] = {
      "standard" => "Era Zero Core Architecture 1.0 selective semantic overlay",
      "approval_basis" =>
        "Explicit user delegation to approve reviewed roots after independent validation.",
      "meaning_change_from_phase2_proposal" =>
        root.fetch("proposed_title") != prior["title"] ||
        root.fetch("invariant_definition") != prior["core_definition"],
      "source_proposal_file" => "lexicon/provisional_atoms.yaml",
      "approval_status" => "USER-DELEGATED APPROVAL — CANONICAL",
      "audit_history_only" => false,
      "downstream_implementation_occurred" => false,
      "future_change_policy" => "versioned migration required"
    }
    record["authority"] = {
      "semantic_status" => "canonical",
      "approval_status" => "explicit_user_delegation_after_detailed_review",
      "downstream_dependency_permitted" => true
    }
  end
end

[atoms, all_atoms].each_with_index do |document, index|
  IDS.each do |id|
    raise("Fixed-field mutation in #{id}") unless
      record_for(document, id).slice(*FIXED_FIELDS) == fixed_before[[index, id]]
  end
end
raise("Source-canonical mutation") unless source == source_snapshot
reviewed_snapshot.each do |id, projection|
  raise("Previously reviewed canonical mutation in #{id}") unless
    authority_projection(record_for(atoms, id)) == projection &&
      authority_projection(record_for(all_atoms, id)) == projection
end

canonical_count = 81
provisional_count = 243
atoms["metadata"]["semantic_authority_status"] = "mixed_81_canonical_243_provisional"
atoms["metadata"]["canonical_semantic_roots"] = canonical_count
atoms["metadata"]["provisional_semantic_roots"] = provisional_count
atoms["metadata"]["selective_review_approval_status"] =
  "MOV:100–222 and MAT:000–222 canonical through detailed selective approvals"
all_atoms["metadata"]["canonical_count"] = canonical_count
all_atoms["metadata"]["provisional_count"] = provisional_count
all_atoms["metadata"]["semantic_status"] = "mixed_81_canonical_and_243_provisional"
all_atoms["metadata"]["selective_review_approval_status"] =
  "Five reviewed nine-root packets canonical"

provisional["atoms"].reject! { |record| IDS.include?(record["canonical_id"]) }
raise("Unexpected provisional count") unless provisional["atoms"].length == provisional_count
provisional["metadata"]["title"] =
  "Era Zero 243 generated addresses — provisional semantic candidates"
provisional["metadata"]["count"] = provisional_count
provisional["metadata"]["canonical_baseline_count"] = canonical_count
provisional["metadata"]["approved_removed_ranges"] =
  %w[MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122 MAT:200–222]

write_yaml("lexicon/atoms.yaml", atoms)
write_yaml("lexicon/all_atoms.yaml", all_atoms)
write_yaml("lexicon/provisional_atoms.yaml", provisional)

existing_reviewed_ids = reviewed.fetch("atoms").map { |record| record["canonical_id"] }
IDS.each do |id|
  reviewed["atoms"] << record_for(atoms, id) unless existing_reviewed_ids.include?(id)
end
order = atoms.fetch("atoms").each_with_index.to_h { |record, index| [record["canonical_id"], index] }
reviewed["atoms"].sort_by! { |record| order.fetch(record["canonical_id"]) }
reviewed["metadata"]["count"] = reviewed["atoms"].length
reviewed["metadata"]["ranges"] =
  %w[MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122 MAT:200–222]
reviewed["metadata"]["semantic_overlay_version"] = "1.0.3"
reviewed["metadata"]["latest_approval_record"] = MIGRATION_PATH
raise("Unexpected reviewed canonical count") unless reviewed["atoms"].length == 45
write_yaml("lexicon/reviewed_canonical_atoms.yaml", reviewed)

authority = load_yaml("lexicon/semantic_authority.yaml")
authority["metadata"]["current_status"] =
  "81 canonical roots; 243 provisional roots; no completed review packet awaiting decision"
authority["metadata"]["selective_review_approval"] =
  "MOV:100–222 and MAT:000–222 canonical through detailed selective approvals"
authority["metadata"]["last_review_update"] = "2026-07-29"
authority["semantic_inventory"]["canonical_roots"] = canonical_count
authority["semantic_inventory"]["provisional_roots"] = provisional_count
authority["semantic_inventory"]["canonical_ranges"] =
  ["LIF:000–222", "MOV:000–222", "MAT:000–222"]
authority["semantic_inventory"]["provisional_ranges"] =
  ["MIN:000–222", "CON:000–222", "STR:000–222", "WRN:000–222",
   "REP:000–222", "LOG:000–222", "DAT:000–222", "CRE:000–222",
   "ORI:000–222"]
authority.keys.grep(/\Aprovisional_for_\d+_addresses\z/).each { |key| authority.delete(key) }
authority["provisional_for_243_addresses"] =
  ["semantic_title", "invariant_definition", "translation_candidates"]
authority["approved_review_packets"] << {
  "range" => RANGE,
  "status" => "canonical_by_explicit_user_delegation_after_detailed_review",
  "canonicalized" => true,
  "generated_fields_changed" => false
}
authority["review_packets_pending_user_decision"] = []
authority.delete("active_review_packet")
authority["last_completed_review_packet"] = {
  "range" => RANGE,
  "status" => "canonical_by_delegated_approval",
  "canonicalized" => true
}
authority["next_review_packet"] = {
  "range" => "MIN:000–022",
  "status" => "not_begun",
  "canonicalized" => false
}
authority["semantic_review_progress"] = {
  "canonical_review_chunks" => 5,
  "reviewed_pending_decision_chunks" => 0,
  "unreviewed_chunks" => 27,
  "reviewed_pending_decision_roots" => 0,
  "unreviewed_roots" => 243
}
authority["stop_boundary"] = {
  "do_not_begin" => [
    "MIN:000–022 in this approval packet",
    "any later root block",
    "Gate 4",
    "translator implementation"
  ]
}
write_yaml("lexicon/semantic_authority.yaml", authority)

version = load_yaml("spec/version.yaml")
version["semantic_authority_status"] = "81_canonical_243_provisional"
version["canonical_semantic_roots"] = canonical_count
version["provisional_semantic_roots"] = provisional_count
version["active_review_packet"] = nil
version["last_completed_review_packet"] = RANGE
version["next_semantic_review_packet"] = "MIN:000–022"
version["review_packets_pending_user_decision"] = []
version["unreviewed_semantic_roots"] = provisional_count
version["unreviewed_nine_root_chunks"] = 27
version["selective_semantic_overlay"] = "MOV:100–222 and MAT:000–222"
version["selective_semantic_overlay_record"] = MIGRATION_PATH
write_yaml("spec/version.yaml", version)

canonical = load_yaml("spec/canonical_spec.yaml")
canonical["metadata"]["semantic_authority_status"] =
  "architecture fixed; 81 canonical roots; 243 provisional roots"
canonical["lexicon"]["completed_count"] = canonical_count
canonical["lexicon"]["remaining_count"] = provisional_count
canonical_ids = canonical["lexicon"]["completed_atoms"].map { |record| record["canonical_id"] }
IDS.each do |id|
  canonical["lexicon"]["completed_atoms"] << record_for(atoms, id) unless canonical_ids.include?(id)
end
canonical["lexicon"]["completed_atoms"].sort_by! { |record| order.fetch(record["canonical_id"]) }
canonical["lexicon"]["canonical_sources"] = {
  "source_developed_36" => "lexicon/completed_atoms.yaml",
  "review_approved_45" => "lexicon/reviewed_canonical_atoms.yaml"
}
write_yaml("spec/canonical_spec.yaml", canonical)

phase2 = load_yaml("spec/phase2_provisional_spec.yaml")
phase2["metadata"]["status"] = "243_provisional_meanings_pending_review"
phase2["scope"]["canonical_meanings"] = canonical_count
phase2["scope"]["provisional_meanings"] = provisional_count
phase2["scope"]["remaining_review_chunks"] = 27
phase2["scope"]["reviewed_pending_decision_chunks"] = 0
phase2["scope"]["reviewed_pending_decision_meanings"] = 0
phase2["scope"]["unreviewed_meanings"] = provisional_count
phase2["semantic_constraints"].keys.grep(/\Acanonical_\d+_are_immutable/).each do |key|
  phase2["semantic_constraints"].delete(key)
end
phase2["semantic_constraints"]["canonical_81_are_immutable_without_versioned_migration"] = true
phase2["review_chunks"].each do |chunk|
  chunk["status"] = "canonical_by_reviewed_selective_approval" if chunk["range"] == RANGE
end
write_yaml("spec/phase2_provisional_spec.yaml", phase2)

standard = load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
standard["metadata"]["status"] = "architecture_fixed_81_canonical_243_provisional"
standard["metadata"]["approval_scope"] =
  "Architecture, 36 source-developed roots, and 45 roots canonized after detailed review"
standard["metadata"]["review_progress"] =
  "Five nine-root review packets canonical; MIN:000–022 is next and not begun"
standard["authority"]["review_approved_roots"] =
  "MOV:100–222 and MAT:000–222 are canonical through explicit or delegated approval after detailed adversarial review."
standard["authority"]["reviewed_provisional_roots"] =
  "No completed review packet remains pending user decision."
standard["authority"]["phase2_semantics"] =
  "The remaining 243 meanings are PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW."
standard["authority"]["downstream_dependency_policy"] =
  "No downstream layer may depend on the 243 provisional meanings."
standard["authority"]["change_control"] =
  "All 81 canonical meanings require explicit versioned migration for any future change."
standard["inventory"]["canonical_roots"] = canonical_count
standard["inventory"]["provisional_roots"] = provisional_count
standard["inventory"]["canonical_chunks"] = 9
standard["inventory"]["provisional_review_chunks"] = 27
standard["inventory"]["reviewed_pending_decision_roots"] = 0
standard["inventory"]["unreviewed_roots"] = provisional_count
standard["inventory"]["reviewed_pending_decision_chunks"] = 0
standard["inventory"]["unreviewed_review_chunks"] = 27
standard["deferred_post_core_layers"].map! do |item|
  item.start_with?("MAT:200–222 and every later root block") ?
    "MIN:000–222 and every later provisional root block pending review" : item
end
standard["canonical_review_chunks"].each do |chunk|
  next unless chunk["range"] == RANGE

  chunk["status"] = "canonical_by_reviewed_selective_approval"
  chunk["selective_approval_record"] = MIGRATION_PATH
end
write_yaml("spec/era_zero_core_standard_1.0.0.yaml", standard)

readiness = load_yaml("spec/translator_readiness.yaml")
readiness["current_inventory"]["canonical_meanings"] = canonical_count
readiness["current_inventory"]["provisional_meanings"] = provisional_count
readiness["current_inventory"]["reviewed_pending_user_decision"] = {
  "roots" => 0,
  "packets" => []
}
readiness["current_inventory"]["unreviewed"] = {
  "roots" => provisional_count,
  "nine_root_chunks" => 27
}
readiness["safe_now"]["maximum_semantic_scope"] = "81 canonical roots"
readiness["next_semantic_chunk_after_pending_decisions"] = "MIN:000–022"
write_yaml("spec/translator_readiness.yaml", readiness)

recommended["metadata"]["status"] = "approved_and_canonical_by_delegated_authority"
recommended["metadata"]["roots_canonicalized"] = IDS
recommended["metadata"]["approval_record"] = MIGRATION_PATH
recommended["roots"].each do |root|
  root["proposal_status"] = "canonical_by_delegated_approval"
  root["canonicalized"] = true
end
write_yaml(RECOMMENDATION_PATH, recommended)

scored["metadata"]["status"] = "approved_and_canonical_by_delegated_authority"
scored["metadata"]["roots_canonicalized"] = IDS
scored["metadata"]["approval_record"] = MIGRATION_PATH
scored["roots"].each { |root| root["canonicalized"] = true }
write_yaml(SCORED_PATH, scored)

migration = {
  "metadata" => {
    "title" => "MAT:200–222 delegated semantic approval",
    "status" => "applied",
    "architecture_version" => "1.0",
    "semantic_overlay_version" => "1.0.3",
    "authority" => "Explicit user delegation to approve reviewed roots",
    "broad_gate3_history" =>
      "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION",
    "generated_fields_changed" => false
  },
  "approved_packet" => {
    "range" => RANGE,
    "recommendation" => RECOMMENDATION_PATH,
    "review" => REVIEW_PATH,
    "validation" => VALIDATION_PATH,
    "collision_report" => "reviews/MAT_200_222_collision_report.md",
    "stress_tests" => "reviews/MAT_200_222_stress_tests.yaml"
  },
  "promoted_roots" => IDS.map do |id|
    record = record_for(atoms, id)
    {
      "canonical_id" => id,
      "canonical_title" => record["title"],
      "invariant_definition" => record["core_definition"],
      "fixed_generated_fields" => record.slice(*FIXED_FIELDS)
    }
  end,
  "audit" => {
    "source_canonical_roots_changed" => false,
    "previous_review_approved_roots_changed" => false,
    "canonical_count_after" => canonical_count,
    "provisional_count_after" => provisional_count,
    "unreviewed_chunks_after" => 27,
    "future_change_policy" => "explicit versioned migration required",
    "next_review_packet" => "MIN:000–022",
    "next_review_packet_begun" => false,
    "gate4_started" => false,
    "translator_implementation_started" => false
  }
}
write_yaml(MIGRATION_PATH, migration)

approval = +"# MAT:200–222 Delegated Semantic Approval\n\n"
approval << "Status: **APPLIED — NINE ROOTS CANONICAL**\n\n"
approval << "The user explicitly delegated authority to approve reviewed roots. "
approval << "After an adversarial four-candidate review and an independent validation "
approval << "of 21 controls, 2,592 generated-field assertions, and 85 stress tests, "
approval << "`MAT:200–222` was approved as a selective semantic overlay.\n\n"
IDS.each do |id|
  record = record_for(atoms, id)
  approval << "- `#{id}` — **#{record["title"]}**: #{record["core_definition"]}\n"
end
approval << "\nNo generated field, source-canonical meaning, or previously reviewed "
approval << "meaning changed. Era Zero now contains **81 canonical roots** and "
approval << "**243 provisional roots in 27 nine-root chunks**. The broad Gate 3 "
approval << "approval remains withdrawn. `MIN:000–022`, Gate 4, and translator implementation "
approval << "were not begun.\n"
File.write(File.join(ROOT, APPROVAL_RECORD_PATH), approval)

puts "Applied MAT:200–222 delegated approval: 81 canonical / 243 provisional."
