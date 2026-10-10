#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MIN:100 MIN:101 MIN:102
  MIN:110 MIN:111 MIN:112
  MIN:120 MIN:121 MIN:122
].freeze
RANGE = "MIN:100–122"
NEXT_RANGE = "MIN:200–222"
RECOMMENDATION_PATH = "reviews/MIN_100_122_recommended_spec.yaml"
SCORED_PATH = "reviews/MIN_100_122_scored_candidates.yaml"
REVIEW_PATH = "reviews/MIN_100_122_peer_review.md"
VALIDATION_PATH = "reviews/MIN_100_122_validation.md"
COLLISION_PATH = "reviews/MIN_100_122_collision_report.md"
STRESS_PATH = "reviews/MIN_100_122_stress_tests.yaml"
MIGRATION_PATH = "migrations/MIN_100_122_semantic_approval.yaml"
APPROVAL_RECORD_PATH = "reviews/MIN_100_122_approval_record.md"
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
raise("MIN:100–122 validation is not ready") unless
  validation.include?("Status: **PASS — READY FOR DELEGATED APPROVAL**") &&
    validation.include?("Checks failed: **0**") &&
    validation.rstrip.end_with?("**REVIEW VALIDATED — NO ROOT CANONICALIZED BY THIS CHECK**")

recommended = load_yaml(RECOMMENDATION_PATH)
scored = load_yaml(SCORED_PATH)
raise("Recommendation is not pending approval") unless
  recommended.dig("metadata", "status") == "recommended_pending_delegated_approval" &&
    recommended.fetch("roots").none? { |root| root["canonicalized"] }
raise("Scored review is not pending approval") unless
  scored.dig("metadata", "status") == "review_complete_pending_preapproval_validation" &&
    scored.fetch("roots").none? { |root| root["canonicalized"] }

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
raise("Expected 54 previously reviewed roots") unless reviewed_snapshot.length == 54

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
    record["neighbor_contrasts"] = root.fetch("nearest_neighbors")
    record["status"] = "canonical"
    record["approval_effect"] =
      "CANONICAL BY EXPLICIT USER-DELEGATED APPROVAL AFTER DETAILED ADVERSARIAL REVIEW."
    record["semantic_origin"] =
      "Detailed MIN:100–122 peer-review winner approved under the user's explicit delegation."
    record["canonical_version"] = "1.0.5-delegated-semantic-overlay"
    record["review_history"] = {
      "withdrawn_broad_gate3_promotion" =>
        "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION",
      "detailed_peer_review" => REVIEW_PATH,
      "scored_candidates" => SCORED_PATH,
      "validation" => VALIDATION_PATH,
      "recommendation" => RECOMMENDATION_PATH,
      "collision_report" => COLLISION_PATH,
      "stress_tests" => STRESS_PATH,
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

canonical_count = 99
provisional_count = 225
remaining_chunks = 25
reviewed_count = 63
atoms["metadata"]["semantic_authority_status"] = "mixed_99_canonical_225_provisional"
atoms["metadata"]["canonical_semantic_roots"] = canonical_count
atoms["metadata"]["provisional_semantic_roots"] = provisional_count
atoms["metadata"]["selective_review_approval_status"] =
  "MOV:100–222, MAT:000–222, and MIN:000–122 canonical through detailed selective approvals"
all_atoms["metadata"]["canonical_count"] = canonical_count
all_atoms["metadata"]["provisional_count"] = provisional_count
all_atoms["metadata"]["semantic_status"] = "mixed_99_canonical_and_225_provisional"
all_atoms["metadata"]["selective_review_approval_status"] =
  "Seven reviewed nine-root packets canonical"

provisional["atoms"].reject! { |record| IDS.include?(record["canonical_id"]) }
raise("Unexpected provisional count") unless provisional["atoms"].length == provisional_count
provisional["metadata"]["title"] =
  "Era Zero 225 generated addresses — provisional semantic candidates"
provisional["metadata"]["count"] = provisional_count
provisional["metadata"]["canonical_baseline_count"] = canonical_count
provisional["metadata"]["approved_removed_ranges"] =
  %w[
    MOV:100–122 MOV:200–222
    MAT:000–022 MAT:100–122 MAT:200–222
    MIN:000–022 MIN:100–122
  ]

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
  %w[
    MOV:100–122 MOV:200–222
    MAT:000–022 MAT:100–122 MAT:200–222
    MIN:000–022 MIN:100–122
  ]
reviewed["metadata"]["semantic_overlay_version"] = "1.0.5"
reviewed["metadata"]["latest_approval_record"] = MIGRATION_PATH
raise("Unexpected reviewed canonical count") unless reviewed["atoms"].length == reviewed_count
write_yaml("lexicon/reviewed_canonical_atoms.yaml", reviewed)

authority = load_yaml("lexicon/semantic_authority.yaml")
authority["metadata"]["current_status"] =
  "99 canonical roots; 225 provisional roots; no completed review packet awaiting decision"
authority["metadata"]["selective_review_approval"] =
  "MOV:100–222, MAT:000–222, and MIN:000–122 canonical through detailed selective approvals"
authority["metadata"]["last_review_update"] = "2026-07-29"
authority["semantic_inventory"]["canonical_roots"] = canonical_count
authority["semantic_inventory"]["provisional_roots"] = provisional_count
authority["semantic_inventory"]["canonical_ranges"] =
  ["LIF:000–222", "MOV:000–222", "MAT:000–222", "MIN:000–122"]
authority["semantic_inventory"]["provisional_ranges"] =
  ["MIN:200–222", "CON:000–222", "STR:000–222", "WRN:000–222",
   "REP:000–222", "LOG:000–222", "DAT:000–222", "CRE:000–222",
   "ORI:000–222"]
authority.keys.grep(/\Aprovisional_for_\d+_addresses\z/).each { |key| authority.delete(key) }
authority["provisional_for_225_addresses"] =
  ["semantic_title", "invariant_definition", "translation_candidates"]
raise("MIN approval already recorded") if
  authority.fetch("approved_review_packets").any? { |packet| packet["range"] == RANGE }
authority["approved_review_packets"] << {
  "range" => RANGE,
  "status" => "canonical_by_explicit_user_delegation_after_detailed_review",
  "canonicalized" => true,
  "generated_fields_changed" => false
}
authority["review_packets_pending_user_decision"] = []
authority["last_completed_review_packet"] = {
  "range" => RANGE,
  "status" => "canonical_by_delegated_approval",
  "canonicalized" => true
}
authority["next_review_packet"] = {
  "range" => NEXT_RANGE,
  "status" => "not_begun",
  "canonicalized" => false
}
authority["semantic_review_progress"] = {
  "canonical_review_chunks" => 7,
  "reviewed_pending_decision_chunks" => 0,
  "unreviewed_chunks" => remaining_chunks,
  "reviewed_pending_decision_roots" => 0,
  "unreviewed_roots" => provisional_count
}
authority["stop_boundary"] = {
  "do_not_begin" => [
    "#{NEXT_RANGE} in this approval packet",
    "any later root block",
    "Gate 4",
    "translator implementation"
  ]
}
write_yaml("lexicon/semantic_authority.yaml", authority)

version = load_yaml("spec/version.yaml")
version["semantic_authority_status"] = "99_canonical_225_provisional"
version["canonical_semantic_roots"] = canonical_count
version["provisional_semantic_roots"] = provisional_count
version["active_review_packet"] = nil
version["last_completed_review_packet"] = RANGE
version["next_semantic_review_packet"] = NEXT_RANGE
version["review_packets_pending_user_decision"] = []
version["unreviewed_semantic_roots"] = provisional_count
version["unreviewed_nine_root_chunks"] = remaining_chunks
version["selective_semantic_overlay"] =
  "MOV:100–222, MAT:000–222, and MIN:000–122"
version["selective_semantic_overlay_record"] = MIGRATION_PATH
write_yaml("spec/version.yaml", version)

canonical = load_yaml("spec/canonical_spec.yaml")
canonical["metadata"]["semantic_authority_status"] =
  "architecture fixed; 99 canonical roots; 225 provisional roots"
canonical["lexicon"]["completed_count"] = canonical_count
canonical["lexicon"]["remaining_count"] = provisional_count
canonical_ids = canonical["lexicon"]["completed_atoms"].map { |record| record["canonical_id"] }
IDS.each do |id|
  canonical["lexicon"]["completed_atoms"] << record_for(atoms, id) unless canonical_ids.include?(id)
end
canonical["lexicon"]["completed_atoms"].sort_by! { |record| order.fetch(record["canonical_id"]) }
canonical["lexicon"]["canonical_sources"] = {
  "source_developed_36" => "lexicon/completed_atoms.yaml",
  "review_approved_63" => "lexicon/reviewed_canonical_atoms.yaml"
}
write_yaml("spec/canonical_spec.yaml", canonical)

phase2 = load_yaml("spec/phase2_provisional_spec.yaml")
phase2["metadata"]["status"] = "225_provisional_meanings_pending_review"
phase2["scope"]["canonical_meanings"] = canonical_count
phase2["scope"]["provisional_meanings"] = provisional_count
phase2["scope"]["remaining_review_chunks"] = remaining_chunks
phase2["scope"]["reviewed_pending_decision_chunks"] = 0
phase2["scope"]["reviewed_pending_decision_meanings"] = 0
phase2["scope"]["unreviewed_meanings"] = provisional_count
phase2["semantic_constraints"].keys.grep(/\Acanonical_\d+_are_immutable/).each do |key|
  phase2["semantic_constraints"].delete(key)
end
phase2["semantic_constraints"]["canonical_99_are_immutable_without_versioned_migration"] = true
phase2["review_chunks"].each do |chunk|
  chunk["status"] = "canonical_by_reviewed_selective_approval" if chunk["range"] == RANGE
end
write_yaml("spec/phase2_provisional_spec.yaml", phase2)

standard = load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
standard["metadata"]["status"] = "architecture_fixed_99_canonical_225_provisional"
standard["metadata"]["approval_scope"] =
  "Architecture, 36 source-developed roots, and 63 roots canonized after detailed review"
standard["metadata"]["review_progress"] =
  "Seven nine-root review packets canonical; #{NEXT_RANGE} is next and not begun"
standard["authority"]["review_approved_roots"] =
  "MOV:100–222, MAT:000–222, and MIN:000–122 are canonical through explicit or delegated approval after detailed adversarial review."
standard["authority"]["reviewed_provisional_roots"] =
  "No completed review packet remains pending user decision."
standard["authority"]["phase2_semantics"] =
  "The remaining 225 meanings are PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW."
standard["authority"]["downstream_dependency_policy"] =
  "No downstream layer may depend on the 225 provisional meanings."
standard["authority"]["change_control"] =
  "All 99 canonical meanings require explicit versioned migration for any future change."
standard["inventory"]["canonical_roots"] = canonical_count
standard["inventory"]["provisional_roots"] = provisional_count
standard["inventory"]["canonical_chunks"] = 11
standard["inventory"]["provisional_review_chunks"] = remaining_chunks
standard["inventory"]["reviewed_pending_decision_roots"] = 0
standard["inventory"]["unreviewed_roots"] = provisional_count
standard["inventory"]["reviewed_pending_decision_chunks"] = 0
standard["inventory"]["unreviewed_review_chunks"] = remaining_chunks
standard["deferred_post_core_layers"].map! do |item|
  item.start_with?("MIN:100–222 and every later provisional root block") ?
    "MIN:200–222 and every later provisional root block pending review" : item
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
  "nine_root_chunks" => remaining_chunks
}
readiness["safe_now"]["maximum_semantic_scope"] = "99 canonical roots"
readiness["next_semantic_chunk_after_pending_decisions"] = NEXT_RANGE
write_yaml("spec/translator_readiness.yaml", readiness)

recommended["metadata"]["status"] = "approved_and_canonical_by_delegated_authority"
recommended["metadata"]["roots_canonicalized"] = IDS
recommended["metadata"]["approval_record"] = MIGRATION_PATH
recommended["approval_checklist"]["canonicalized"] = true
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
    "title" => "MIN:100–122 delegated semantic approval",
    "status" => "applied",
    "architecture_version" => "1.0",
    "semantic_overlay_version" => "1.0.5",
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
    "collision_report" => COLLISION_PATH,
    "stress_tests" => STRESS_PATH
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
    "unreviewed_chunks_after" => remaining_chunks,
    "future_change_policy" => "explicit versioned migration required",
    "next_review_packet" => NEXT_RANGE,
    "next_review_packet_begun" => false,
    "gate4_started" => false,
    "translator_implementation_started" => false
  }
}
write_yaml(MIGRATION_PATH, migration)

approval = +"# MIN:100–122 Delegated Semantic Approval\n\n"
approval << "Status: **APPLIED — NINE ROOTS CANONICAL**\n\n"
approval << "The user explicitly delegated authority to approve reviewed roots and requested "
approval << "the next block. The packet challenged the nine provisional meanings against "
approval << "four alternative architectures per root, scored 45 candidates across 360 "
approval << "criterion values, ran 51 English coverage tests, and passed 24 independent "
approval << "pre-approval checks plus all 2,592 deterministic generation assertions. "
approval << "`MIN:100–122` is therefore approved as a selective semantic overlay.\n\n"
IDS.each do |id|
  record = record_for(atoms, id)
  approval << "- `#{id}` — **#{record["title"]}**: #{record["core_definition"]}\n"
end
approval << "\nThe approved architecture owns cognitive representational revision by scope "
approval << "(self-model, target model, shared schema) and phase (completed, active, "
approval << "nonactualized). It does not make attention, recall, inference, learning, "
approval << "decision, communication, truth, correction, planning, scheduling, or physical "
approval << "change part of the atom.\n\n"
approval << "No generated field, source-canonical meaning, or previously reviewed meaning "
approval << "changed. Era Zero now contains **99 canonical roots** and **225 provisional "
approval << "roots in 25 nine-root chunks**. The broad Gate 3 approval remains withdrawn. "
approval << "`#{NEXT_RANGE}`, Gate 4, and translator implementation were not begun.\n"
File.write(File.join(ROOT, APPROVAL_RECORD_PATH), approval)

status = <<~MARKDOWN
  # Era Zero Semantic Authority Status

  Current authority: **99 CANONICAL ROOTS / 225 PROVISIONAL ROOTS**

  The earlier broad Gate 3 promotion remains **WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION**. The later selective approvals are distinct, root-level authority actions after detailed review and do not reinstate that broad promotion.

  ## Fixed architecture

  - Era Zero Core Architecture **1.0** remains fixed.
  - All 324 addresses retain their deterministic family, address, universal slot, harmonic signature, family onset, local compact root, formal carrier, and relative note path.
  - For any lexical address `1x2`, the third trit denotes a **nonactualized process**: the family-domain process is not presently active or completed, and its realization is dormant, potential, or unresolved.
  - Lexical `1x2` does not encode specification, intention, planning, schedule, queue, permission, readiness, probability, future time, or certainty.
  - Runtime `[2]/num` remains a separate token-status operator.

  ## Canonical semantic authority

  - The original **36 source-developed roots** remain canonical and unchanged: `LIF:000–222` and `MOV:000–022`.
  - The **63 roots approved after detailed semantic review** are canonical: `MOV:100–222`, `MAT:000–222`, and `MIN:000–122`.
  - `MOV:100–122` was approved directly by the user. The other six reviewed packets were approved under the user's explicit delegation to approve reviewed roots.
  - Future changes to any of the 99 canonical meanings require an explicit versioned migration.
  - `MIN:000–022` owns cognitive representations by scope and lexical expression.
  - `MIN:100–122` owns cognitive representational revision. Its second trit selects self-model, target model, or shared cognitive schema; its third selects completed, active, or nonactualized revision.
  - The Mind process layer does not absorb attention, recall, inference, learning as a whole, decision, communication, truth, correction, planning, scheduling, or physical change. Those meanings require later Mind review, another family, grammar, or explicit compounds.

  ## Provisional semantic authority

  The remaining **225 titles and definitions in 25 nine-root chunks** are **PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW**. No compound dictionary, English concept index, etymology layer, semantic IR, grammar implementation, renderer, or translator may depend on them.

  ## Active review and stop boundary

  - Reviewed packets pending decision: **none**.
  - Last completed packet: `MIN:100–122`, canonical after delegated approval.
  - Next review packet: `MIN:200–222`, **not begun**.
  - Not begun in this packet: `MIN:200–222`, any later root block, Gate 4, compound architecture, or translator implementation.

  ## Translator readiness

  The broad translator remains blocked by the 225 provisional meanings, the unfinished compound and English-sense layer, the absence of a versioned utterance IR and executable grammar, and the missing deterministic renderer/decoder.

  A restricted developer renderer may operate only on the 99 explicit canonical IDs and must reject provisional roots and unapproved compounds. See `reports/translator_readiness_roadmap.md`.

  Machine-readable authority: `lexicon/semantic_authority.yaml`.
  Latest selective approval record: `migrations/MIN_100_122_semantic_approval.yaml`.
  Withdrawal history: `gate3_withdrawal_record.md`.
MARKDOWN
File.write(File.join(ROOT, "semantic_authority_status.md"), status)

roadmap_path = File.join(ROOT, "reports/translator_readiness_roadmap.md")
roadmap = File.read(roadmap_path)
roadmap.gsub!("90 canonical roots", "99 canonical roots")
roadmap.gsub!("90 meanings are canonical", "99 meanings are canonical")
roadmap.gsub!("234 meanings remain provisional in 26 nine-root chunks",
              "225 meanings remain provisional in 25 nine-root chunks")
roadmap.gsub!("`MIN:100–122` is next and has not been begun",
              "`MIN:200–222` is next and has not been begun")
roadmap.gsub!("90 canonical; 234 provisional", "99 canonical; 225 provisional")
roadmap.gsub!("the 90 explicit canonical IDs", "the 99 explicit canonical IDs")
roadmap.sub!(
  /The next semantic sequence is:\n\n1\. `MIN:100–122`;\n2\. `MIN:200–222`;/,
  "The next semantic sequence is:\n\n1. `MIN:200–222`;"
)
roadmap.gsub!(
  "1. `MIN:200–222`;\n3. the three nine-root layers",
  "1. `MIN:200–222`;\n2. the three nine-root layers"
)
roadmap.sub!("After approval of `MIN:000–022`:", "After approval of `MIN:100–122`:")
File.write(roadmap_path, roadmap)

puts "Applied MIN:100–122 delegated approval: 99 canonical / 225 provisional."
