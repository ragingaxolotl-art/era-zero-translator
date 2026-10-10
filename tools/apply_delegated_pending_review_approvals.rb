#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
PACKETS = [
  {
    "range" => "MOV:200–222",
    "recommendation" => "reviews/MOV_200_222_recommended_spec.yaml",
    "review" => "reviews/MOV_200_222_peer_review.md",
    "validation" => "reviews/MOV_200_222_validation.md"
  },
  {
    "range" => "MAT:000–022",
    "recommendation" => "reviews/MAT_000_022_recommended_spec.yaml",
    "review" => "reviews/MAT_000_022_peer_review.md",
    "validation" => "reviews/MAT_000_022_validation.md"
  },
  {
    "range" => "MAT:100–122",
    "recommendation" => "reviews/MAT_100_122_recommended_spec.yaml",
    "review" => "reviews/MAT_100_122_peer_review.md",
    "validation" => "reviews/MAT_100_122_validation.md"
  }
].freeze
FIXED_FIELDS = %w[
  family address universal_slot harmonic_signature_semitones family_onset
  local_compact_root canonical_transliteration formal_carrier note_path_semitones
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

def recommendation_title(root)
  root["proposed_title"] || root["recommended_title"] || root["canonical_title"] ||
    raise("Recommendation title missing for #{root.dig("fixed_generated_fields", "canonical_id")}")
end

def recommendation_definition(root)
  root["invariant_definition"] || root["recommended_invariant_definition"] ||
    raise("Recommendation definition missing for #{root.dig("fixed_generated_fields", "canonical_id")}")
end

recommendations = {}
packet_by_id = {}
PACKETS.each do |packet|
  validation = File.read(File.join(ROOT, packet["validation"]))
  raise("#{packet["range"]} validation is not ready") unless validation.rstrip.end_with?("**READY FOR USER APPROVAL**")

  document = load_yaml(packet["recommendation"])
  raise("#{packet["range"]} recommendation is not pending approval") unless
    document.dig("metadata", "status") == "ready_for_user_approval_not_canonical"

  document.fetch("roots").each do |root|
    id = root.dig("fixed_generated_fields", "canonical_id") ||
      raise("Missing canonical ID in #{packet["recommendation"]}")
    raise("Duplicate recommendation for #{id}") if recommendations.key?(id)
    recommendations[id] = {
      "title" => recommendation_title(root),
      "definition" => recommendation_definition(root),
      "root" => root
    }
    packet_by_id[id] = packet
  end
end

ids = recommendations.keys
raise("Expected 27 approved roots, got #{ids.length}") unless ids.length == 27

atoms = load_yaml("lexicon/atoms.yaml")
all_atoms = load_yaml("lexicon/all_atoms.yaml")
provisional = load_yaml("lexicon/provisional_atoms.yaml")
source = load_yaml("lexicon/completed_atoms.yaml")
source_snapshot = Marshal.load(Marshal.dump(source))

fixed_before = {}
[atoms, all_atoms, provisional].each_with_index do |document, index|
  ids.each do |id|
    record = record_for(document, id)
    raise("#{id} is not provisional before approval") unless record["status"] == "provisional_pending_detailed_semantic_review"
    fixed_before[[index, id]] = record.slice(*FIXED_FIELDS)
    copied = recommendations.dig(id, "root", "fixed_generated_fields")
    expected = {
      "canonical_id" => id,
      "family" => record["family"],
      "address" => record["address"],
      "universal_slot" => record["universal_slot"],
      "family_onset" => record["family_onset"],
      "family_qualified_transliteration" => record["canonical_transliteration"],
      "local_compact_root" => record["local_compact_root"],
      "formal_carrier" => record["formal_carrier"],
      "harmonic_signature_semitones" => record["harmonic_signature_semitones"],
      "relative_note_path_semitones" => record["note_path_semitones"]
    }
    required_copied_fields = %w[
      canonical_id universal_slot family_qualified_transliteration
      local_compact_root formal_carrier harmonic_signature_semitones
      relative_note_path_semitones
    ]
    raise("Incomplete generated fields for #{id}") unless
      required_copied_fields.all? { |field| copied.key?(field) }
    raise("Generated-field mismatch for #{id}") unless
      copied.all? { |field, value| expected[field] == value }
  end
end

[atoms, all_atoms].each do |document|
  ids.each do |id|
    record = record_for(document, id)
    recommendation = recommendations.fetch(id)
    packet = packet_by_id.fetch(id)
    root = recommendation.fetch("root")
    record["title"] = recommendation.fetch("title")
    record["core_definition"] = recommendation.fetch("definition")
    record["translation_candidates"] = [recommendation.fetch("title")]
    record["distinctions_and_exclusions"] =
      root["excluded_meanings"] ||
      root["semantic_boundaries"] ||
      ["Use the detailed review packet for permanent inclusion and exclusion boundaries."]
    neighbors = root["nearest_neighbors"] || root["nearest_mat_contrasts"] || root["nearest_motion_contrasts"]
    record["neighbor_contrasts"] =
      case neighbors
      when Hash then neighbors.values.flatten.grep(/\A[A-Z]{3}:\d{3}\z/).uniq
      when Array then neighbors
      else []
      end
    record["status"] = "canonical"
    record["approval_effect"] =
      "CANONICAL BY EXPLICIT USER-DELEGATED APPROVAL AFTER DETAILED ADVERSARIAL REVIEW."
    record["semantic_origin"] =
      "Detailed peer-review recommendation approved under the user's explicit delegation to approve reviewed roots."
    record["canonical_version"] = "1.0.2-delegated-semantic-overlay"
    record["review_history"] = {
      "withdrawn_broad_gate3_promotion" => "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION",
      "detailed_peer_review" => packet.fetch("review"),
      "validation" => packet.fetch("validation"),
      "recommendation" => packet.fetch("recommendation"),
      "delegated_approval_migration" => "migrations/2026-07-29_pending_review_packets_approval.yaml"
    }
    record["canonization"] = {
      "standard" => "Era Zero Core Architecture 1.0 selective semantic overlay",
      "approval_basis" => "Explicit user delegation: approve reviewed roots and proceed to the next block.",
      "meaning_change_from_phase2_proposal" =>
        recommendation.fetch("title") != record_for(provisional, id)["title"] ||
        recommendation.fetch("definition") != record_for(provisional, id)["core_definition"],
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
  ids.each do |id|
    raise("Fixed-field mutation in #{id}") unless
      record_for(document, id).slice(*FIXED_FIELDS) == fixed_before[[index, id]]
  end
end
raise("Source-canonical record mutation") unless source == source_snapshot

canonical_count = 72
provisional_count = 252
atoms["metadata"]["semantic_authority_status"] = "mixed_72_canonical_252_provisional"
atoms["metadata"]["canonical_semantic_roots"] = canonical_count
atoms["metadata"]["provisional_semantic_roots"] = provisional_count
atoms["metadata"]["selective_review_approval_status"] =
  "MOV:200–222, MAT:000–022, and MAT:100–122 canonical by delegated approval"
all_atoms["metadata"]["canonical_count"] = canonical_count
all_atoms["metadata"]["provisional_count"] = provisional_count
all_atoms["metadata"]["semantic_status"] = "mixed_72_canonical_and_252_provisional"
all_atoms["metadata"]["selective_review_approval_status"] =
  "Four reviewed nine-root packets canonical"

provisional["atoms"].reject! { |record| ids.include?(record["canonical_id"]) }
raise("Unexpected provisional count") unless provisional["atoms"].length == provisional_count
provisional["metadata"]["title"] =
  "Era Zero 252 generated addresses — provisional semantic candidates"
provisional["metadata"]["count"] = provisional_count
provisional["metadata"]["canonical_baseline_count"] = canonical_count
provisional["metadata"]["approved_removed_ranges"] =
  %w[MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122]

write_yaml("lexicon/atoms.yaml", atoms)
write_yaml("lexicon/all_atoms.yaml", all_atoms)
write_yaml("lexicon/provisional_atoms.yaml", provisional)

reviewed = load_yaml("lexicon/reviewed_canonical_atoms.yaml")
reviewed_ids = reviewed.fetch("atoms").map { |record| record["canonical_id"] }
ids.each do |id|
  reviewed["atoms"] << record_for(atoms, id) unless reviewed_ids.include?(id)
end
reviewed["atoms"].sort_by! { |record| atoms.fetch("atoms").index { |candidate| candidate["canonical_id"] == record["canonical_id"] } }
reviewed["metadata"]["title"] =
  "Era Zero canonical roots approved after detailed semantic review"
reviewed["metadata"]["status"] = "canonical"
reviewed["metadata"]["count"] = reviewed["atoms"].length
reviewed["metadata"]["ranges"] =
  %w[MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122]
reviewed["metadata"]["semantic_overlay_version"] = "1.0.2"
reviewed["metadata"]["latest_approval_record"] =
  "migrations/2026-07-29_pending_review_packets_approval.yaml"
raise("Unexpected reviewed-canonical count") unless reviewed["atoms"].length == 36
write_yaml("lexicon/reviewed_canonical_atoms.yaml", reviewed)

authority = load_yaml("lexicon/semantic_authority.yaml")
authority["metadata"]["current_status"] =
  "72 canonical roots; 252 provisional roots; no completed review packets awaiting decision"
authority["metadata"]["last_review_update"] = "2026-07-29"
authority["metadata"]["selective_review_approval"] =
  "MOV:100–222 and MAT:000–122 canonical through reviewed selective approvals"
authority["semantic_inventory"]["canonical_roots"] = canonical_count
authority["semantic_inventory"]["provisional_roots"] = provisional_count
authority["semantic_inventory"]["canonical_ranges"] =
  ["LIF:000–222", "MOV:000–222", "MAT:000–122"]
authority["semantic_inventory"]["provisional_ranges"] =
  ["MAT:200–222", "MIN:000–222", "CON:000–222", "STR:000–222",
   "WRN:000–222", "REP:000–222", "LOG:000–222", "DAT:000–222",
   "CRE:000–222", "ORI:000–222"]
authority.delete("provisional_for_279_addresses")
authority["provisional_for_252_addresses"] =
  ["semantic_title", "invariant_definition", "translation_candidates"]
authority["approved_review_packets"] = [
  {
    "range" => "MOV:100–122",
    "status" => "canonical_by_explicit_user_approval",
    "canonicalized" => true,
    "generated_fields_changed" => false
  }
] + PACKETS.map do |packet|
  {
    "range" => packet.fetch("range"),
    "status" => "canonical_by_explicit_user_delegation_after_detailed_review",
    "canonicalized" => true,
    "generated_fields_changed" => false
  }
end
authority["review_packets_pending_user_decision"] = []
authority["active_review_packet"] = {
  "range" => "MAT:200–222",
  "status" => "authorized_for_detailed_review",
  "canonicalized" => false
}
authority["semantic_review_progress"] = {
  "canonical_review_chunks" => 4,
  "reviewed_pending_decision_chunks" => 0,
  "unreviewed_chunks" => 28,
  "reviewed_pending_decision_roots" => 0,
  "unreviewed_roots" => 252
}
authority["stop_boundary"] = {
  "do_not_begin" => ["any block after MAT:200–222", "Gate 4", "translator implementation"]
}
write_yaml("lexicon/semantic_authority.yaml", authority)

version = load_yaml("spec/version.yaml")
version["semantic_authority_status"] = "72_canonical_252_provisional"
version["canonical_semantic_roots"] = canonical_count
version["provisional_semantic_roots"] = provisional_count
version["active_review_packet"] = "MAT:200–222"
version["review_packets_pending_user_decision"] = []
version["unreviewed_semantic_roots"] = 252
version["unreviewed_nine_root_chunks"] = 28
version["selective_semantic_overlay"] =
  "MOV:100–222 and MAT:000–122"
version["selective_semantic_overlay_record"] =
  "migrations/2026-07-29_pending_review_packets_approval.yaml"
write_yaml("spec/version.yaml", version)

canonical = load_yaml("spec/canonical_spec.yaml")
canonical["metadata"]["semantic_authority_status"] =
  "architecture fixed; 72 canonical roots; 252 provisional roots"
canonical["lexicon"]["completed_count"] = canonical_count
canonical["lexicon"]["remaining_count"] = provisional_count
canonical_ids = canonical["lexicon"]["completed_atoms"].map { |record| record["canonical_id"] }
ids.each do |id|
  canonical["lexicon"]["completed_atoms"] << record_for(atoms, id) unless canonical_ids.include?(id)
end
canonical["lexicon"]["completed_atoms"].sort_by! do |record|
  atoms.fetch("atoms").index { |candidate| candidate["canonical_id"] == record["canonical_id"] }
end
canonical["lexicon"]["canonical_sources"] = {
  "source_developed_36" => "lexicon/completed_atoms.yaml",
  "review_approved_36" => "lexicon/reviewed_canonical_atoms.yaml"
}
write_yaml("spec/canonical_spec.yaml", canonical)

phase2 = load_yaml("spec/phase2_provisional_spec.yaml")
phase2["metadata"]["status"] = "252_provisional_meanings_pending_review"
phase2["scope"]["canonical_meanings"] = canonical_count
phase2["scope"]["provisional_meanings"] = provisional_count
phase2["scope"]["remaining_review_chunks"] = 28
phase2["scope"]["reviewed_pending_decision_chunks"] = 0
phase2["scope"]["reviewed_pending_decision_meanings"] = 0
phase2["scope"]["unreviewed_meanings"] = 252
phase2["semantic_constraints"]["canonical_72_are_immutable_without_versioned_migration"] = true
phase2["review_chunks"].each do |chunk|
  if %w[MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122].include?(chunk["range"])
    chunk["status"] = "canonical_by_reviewed_selective_approval"
  end
end
write_yaml("spec/phase2_provisional_spec.yaml", phase2)

standard = load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
standard["metadata"]["status"] = "architecture_fixed_72_canonical_252_provisional"
standard["metadata"]["approval_scope"] =
  "Architecture, 36 source-developed roots, and 36 roots canonized after detailed review"
standard["metadata"]["review_progress"] =
  "Four nine-root review packets canonical; MAT:200–222 authorized next"
standard["authority"]["review_approved_roots"] =
  "MOV:100–222 and MAT:000–122 are canonical through explicit or delegated user approval after detailed adversarial review."
standard["authority"]["reviewed_provisional_roots"] =
  "No completed review packet remains pending user decision."
standard["authority"]["phase2_semantics"] =
  "The remaining 252 meanings are PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW."
standard["authority"]["downstream_dependency_policy"] =
  "No downstream layer may depend on the 252 provisional meanings."
standard["authority"]["change_control"] =
  "All 72 canonical meanings require explicit versioned migration for any future change."
standard["inventory"]["canonical_roots"] = canonical_count
standard["inventory"]["provisional_roots"] = provisional_count
standard["inventory"]["canonical_chunks"] = 8
standard["inventory"]["provisional_review_chunks"] = 28
standard["inventory"]["reviewed_pending_decision_roots"] = 0
standard["inventory"]["unreviewed_roots"] = 252
standard["inventory"]["reviewed_pending_decision_chunks"] = 0
standard["inventory"]["unreviewed_review_chunks"] = 28
standard["deferred_post_core_layers"].map! do |item|
  item == "MAT:200–222 and every later root block" ?
    "MAT:200–222 and every later root block pending review" : item
end
standard["canonical_review_chunks"].each do |chunk|
  if %w[MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122].include?(chunk["range"])
    chunk["status"] = "canonical_by_reviewed_selective_approval"
    chunk["selective_approval_record"] =
      chunk["range"] == "MOV:100–122" ?
        "migrations/MOV_100_122_semantic_approval.yaml" :
        "migrations/2026-07-29_pending_review_packets_approval.yaml"
  end
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
  "roots" => 252,
  "nine_root_chunks" => 28
}
readiness["safe_now"]["maximum_semantic_scope"] = "72 canonical roots"
readiness["next_semantic_chunk_after_pending_decisions"] = "MAT:200–222"
write_yaml("spec/translator_readiness.yaml", readiness)

decisions = load_yaml("extraction/user_decisions.yaml")
decision = {
  "kind" => "delegated_semantic_approval_and_next_chunk_authorization",
  "decision" => "The assistant may approve reviewed roots and should proceed with the next roots.",
  "effect" => "Approves the three completed pending packets after final audit and authorizes detailed review and approval of MAT:200–222, while leaving Gate 4 and translator implementation deferred."
}
unless decisions["decisions"].any? { |item| item["kind"] == decision["kind"] }
  decisions["decisions"] << decision
end
decisions["metadata"]["count"] = decisions["decisions"].length
write_yaml("extraction/user_decisions.yaml", decisions)

migration = {
  "metadata" => {
    "title" => "Delegated approval of three completed semantic review packets",
    "status" => "applied",
    "architecture_version" => "1.0",
    "semantic_overlay_version" => "1.0.2",
    "authority" => "Explicit user delegation to approve reviewed roots",
    "broad_gate3_history" => "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION",
    "generated_fields_changed" => false
  },
  "approved_packets" => PACKETS.map { |packet| packet.slice("range", "recommendation", "review", "validation") },
  "promoted_roots" => ids.map do |id|
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
    "future_change_policy" => "explicit versioned migration required",
    "gate4_started" => false,
    "translator_implementation_started" => false
  }
}
write_yaml("migrations/2026-07-29_pending_review_packets_approval.yaml", migration)

record = +"# Delegated Approval — Completed Semantic Review Packets\n\n"
record << "Status: **APPLIED — CANONICAL SELECTIVE OVERLAY**\n\n"
record << "The user explicitly delegated approval of reviewed roots and directed work to continue. After confirming each packet's passing validation and fixed generated fields, the following ranges were canonized:\n\n"
PACKETS.each { |packet| record << "- `#{packet["range"]}`\n" }
record << "\nThis promotes 27 roots. Together with the 36 source-developed roots and the previously approved `MOV:100–122` packet, Era Zero now has **72 canonical roots and 252 provisional roots**.\n\n"
record << "The withdrawn broad Gate 3 promotion remains audit history and is not reinstated. No generated family, address, universal slot, onset, compact root, carrier, harmony, or note path changed. Future changes require a versioned migration.\n"
File.write(File.join(ROOT, "reviews/2026-07-29_pending_review_packets_approval.md"), record)

puts "Applied delegated approval to 27 roots: 72 canonical / 252 provisional."
