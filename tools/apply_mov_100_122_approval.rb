#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MOV:100 MOV:101 MOV:102
  MOV:110 MOV:111 MOV:112
  MOV:120 MOV:121 MOV:122
].freeze

APPROVED = {
  "MOV:100" => [
    "completed source departure",
    "Completion of a mover's displacement away from a source position."
  ],
  "MOV:101" => [
    "active source departure",
    "Ongoing displacement of a mover away from a source position."
  ],
  "MOV:102" => [
    "potential source departure",
    "A potential displacement away from a source position that is not presently active or completed."
  ],
  "MOV:110" => [
    "completed target arrival",
    "Completion of a mover's displacement to a target position."
  ],
  "MOV:111" => [
    "active target approach",
    "Ongoing displacement of a mover toward a target position."
  ],
  "MOV:112" => [
    "potential target approach",
    "A potential displacement toward a target position that is not presently active or completed."
  ],
  "MOV:120" => [
    "completed shared-frame movement",
    "Completion of a mover's change of position relative to a shared or environmental reference frame."
  ],
  "MOV:121" => [
    "active shared-frame movement",
    "Ongoing change of a mover's position relative to a shared or environmental reference frame."
  ],
  "MOV:122" => [
    "potential shared-frame movement",
    "A potential change of a mover's position relative to a shared or environmental reference frame that is not presently active or completed."
  ]
}.freeze

FIXED_FIELDS = %w[
  family address universal_slot harmonic_signature_semitones family_onset
  local_compact_root canonical_transliteration formal_carrier
  note_path_semitones
].freeze

PROCESS_1X2_RULE = {
  "scope" => "all lexical addresses of the form 1x2",
  "status" => "canonical_architecture_clarification",
  "rule" => "The third lexical trit contributes a nonactualized process: a family-domain process that is not presently active or completed and whose realization is dormant, potential, or unresolved.",
  "does_not_encode" => %w[
    specification intention planning schedule queue permission readiness
    probability future_time certainty
  ],
  "runtime_distinction" => "Runtime [2]/num qualifies the current status of a token of the selected lexeme; it does not select the lexical nonactualized-process concept.",
  "migration_policy" => "Future changes require an explicit versioned migration."
}.freeze

def load_yaml(path)
  YAML.load_file(File.join(ROOT, path))
end

def write_yaml(path, data)
  File.write(File.join(ROOT, path), YAML.dump(data))
end

def record_for(data, id)
  data.fetch("atoms").find { |record| record["canonical_id"] == id } ||
    raise("missing #{id}")
end

def update_atom!(record)
  id = record.fetch("canonical_id")
  title, definition = APPROVED.fetch(id)
  record["title"] = title
  record["core_definition"] = definition
  record["translation_candidates"] = [title]
  record["distinctions_and_exclusions"] = [
    "The root denotes positional displacement in the Motion domain; it does not itself encode intention, planning, scheduling, queuing, permission, readiness, probability, certainty, or future time.",
    "The third lexical trit is part of the permanent lexeme; a following runtime state [0], [1], or [2]/num independently qualifies a token of that lexeme.",
    "Physical embodiment, force, payload, communication, data transfer, structural change, creation, mental change, and ontological transition require another-family root or a compound.",
    "Route traversal is not atomic in this block. Express it compositionally with shared-frame movement and MOV:020 when an established route is asserted."
  ]
  record["neighbor_contrasts"] =
    case id
    when /\AMOV:10/ then %w[MOV:100 MOV:101 MOV:102 MOV:000 MOV:001 MOV:002]
    when /\AMOV:11/ then %w[MOV:110 MOV:111 MOV:112 MOV:010 MOV:011 MOV:012]
    else %w[MOV:120 MOV:121 MOV:122 MOV:020 MOV:021 MOV:022]
    end.reject { |neighbor| neighbor == id }
  record["status"] = "canonical"
  record["approval_effect"] = "CANONICAL BY EXPLICIT USER APPROVAL AFTER DETAILED PEER REVIEW AND FINAL ADVERSARIAL CHALLENGE."
  record["semantic_origin"] = "Final meaning explicitly approved by the user after detailed semantic review; deterministic generated fields are unchanged."
  record["canonical_version"] = "1.0.1-semantic-overlay"
  record["review_history"] = {
    "withdrawn_broad_gate3_promotion" => "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION",
    "detailed_peer_review" => "reviews/MOV_100_122_peer_review.md",
    "final_adversarial_challenge" => "reviews/MOV_100_122_final_challenge.md",
    "selective_approval_record" => "reviews/MOV_100_122_approval_record.md"
  }
  record["canonization"] = {
    "standard" => "Era Zero Core Architecture 1.0 selective semantic overlay",
    "approval_basis" => "Explicit user approval of the final challenge meanings and the universal 1x2 architecture clarification.",
    "meaning_change_from_phase2_proposal" => true,
    "source_proposal_file" => "lexicon/provisional_atoms.yaml",
    "approval_status" => "EXPLICITLY APPROVED AND CANONICAL",
    "audit_history_only" => false,
    "downstream_implementation_occurred" => false,
    "future_change_policy" => "versioned migration required"
  }
  record["authority"] = {
    "semantic_status" => "canonical",
    "approval_status" => "explicit_user_approval_after_detailed_review",
    "downstream_dependency_permitted" => true
  }
end

atoms = load_yaml("lexicon/atoms.yaml")
all_atoms = load_yaml("lexicon/all_atoms.yaml")
provisional = load_yaml("lexicon/provisional_atoms.yaml")

fixed_before = {}
[atoms, all_atoms, provisional].each_with_index do |data, index|
  IDS.each do |id|
    fixed_before[[index, id]] = record_for(data, id).slice(*FIXED_FIELDS)
  end
end

[atoms, all_atoms].each do |data|
  IDS.each { |id| update_atom!(record_for(data, id)) }
end

atoms["metadata"]["semantic_authority_status"] = "mixed_45_canonical_279_provisional"
atoms["metadata"]["canonical_semantic_roots"] = 45
atoms["metadata"]["provisional_semantic_roots"] = 279
atoms["metadata"]["selective_review_approval_status"] =
  "MOV:100–122 EXPLICITLY APPROVED AND CANONICAL"
atoms["metadata"]["change_policy"] =
  "Never change a canonical meaning silently; use an explicit versioned migration. Provisional meanings require detailed review and explicit user approval."

all_atoms["metadata"]["canonical_count"] = 45
all_atoms["metadata"]["provisional_count"] = 279
all_atoms["metadata"]["semantic_status"] = "mixed_45_canonical_and_279_provisional"
all_atoms["metadata"]["selective_review_approval_status"] =
  "MOV:100–122 EXPLICITLY APPROVED AND CANONICAL"

provisional["atoms"].reject! { |record| IDS.include?(record["canonical_id"]) }
provisional["metadata"]["title"] =
  "Era Zero 279 generated addresses — provisional semantic candidates"
provisional["metadata"]["count"] = 279
provisional["metadata"]["canonical_baseline_count"] = 45
provisional["metadata"]["approved_removed_range"] = "MOV:100–122"

[atoms, all_atoms].each_with_index do |data, index|
  IDS.each do |id|
    after = record_for(data, id).slice(*FIXED_FIELDS)
    raise("fixed-field mutation in #{id}") unless after == fixed_before[[index, id]]
  end
end

write_yaml("lexicon/atoms.yaml", atoms)
write_yaml("lexicon/all_atoms.yaml", all_atoms)
write_yaml("lexicon/provisional_atoms.yaml", provisional)

reviewed = {
  "metadata" => {
    "title" => "Era Zero canonical roots approved after detailed semantic review",
    "status" => "canonical",
    "count" => 9,
    "range" => "MOV:100–122",
    "architecture_version" => "1.0",
    "semantic_overlay_version" => "1.0.1",
    "approval_record" => "reviews/MOV_100_122_approval_record.md",
    "change_policy" => "Future semantic changes require an explicit versioned migration."
  },
  "architecture_clarification" => PROCESS_1X2_RULE,
  "atoms" => IDS.map { |id| record_for(atoms, id) }
}
write_yaml("lexicon/reviewed_canonical_atoms.yaml", reviewed)

authority = load_yaml("lexicon/semantic_authority.yaml")
authority["metadata"]["current_status"] =
  "45 canonical roots; 279 provisional roots; broad Gate 3 withdrawal preserved"
authority["metadata"]["selective_review_approval"] =
  "MOV:100–122 EXPLICITLY APPROVED AND CANONICAL"
authority["architecture"]["process_1x2_clarification"] = PROCESS_1X2_RULE
authority["semantic_inventory"]["canonical_roots"] = 45
authority["semantic_inventory"]["provisional_roots"] = 279
authority["semantic_inventory"]["canonical_ranges"] = [
  "LIF:000–222",
  "MOV:000–022",
  "MOV:100–122"
]
authority["semantic_inventory"]["provisional_ranges"] = [
  "MOV:200–222",
  "MAT:000–222",
  "MIN:000–222",
  "CON:000–222",
  "STR:000–222",
  "WRN:000–222",
  "REP:000–222",
  "LOG:000–222",
  "DAT:000–222",
  "CRE:000–222",
  "ORI:000–222"
]
authority.delete("provisional_for_288_addresses")
authority["provisional_for_279_addresses"] = [
  "semantic_title",
  "invariant_definition",
  "translation_candidates"
]
authority["approved_review_packets"] = [
  {
    "range" => "MOV:100–122",
    "status" => "canonical_by_explicit_user_approval",
    "canonicalized" => true,
    "generated_fields_changed" => false
  }
]
authority["active_review_packet"] = {
  "range" => "MOV:200–222",
  "status" => "peer_review_complete_pending_user_decision",
  "canonicalized" => false
}
authority["stop_boundary"] = {
  "do_not_begin" => [
    "MAT:000–022",
    "any other root block",
    "Gate 4",
    "compound architecture"
  ]
}
write_yaml("lexicon/semantic_authority.yaml", authority)

version = load_yaml("spec/version.yaml")
version["semantic_authority_status"] = "45_canonical_279_provisional"
version["canonical_semantic_roots"] = 45
version["provisional_semantic_roots"] = 279
version["selective_semantic_overlay"] = "MOV:100–122"
version["selective_semantic_overlay_record"] =
  "migrations/MOV_100_122_semantic_approval.yaml"
version["active_review_packet"] = "MOV:200–222"
version["next_gate_authorized"] = false
write_yaml("spec/version.yaml", version)

canonical = load_yaml("spec/canonical_spec.yaml")
canonical["metadata"]["semantic_authority_status"] =
  "architecture fixed; 45 canonical roots; 279 provisional roots"
canonical["atomic_address"]["process_1x2_clarification"] = PROCESS_1X2_RULE
canonical["lexicon"]["completed_count"] = 45
canonical["lexicon"]["remaining_count"] = 279
canonical_ids = canonical["lexicon"]["completed_atoms"].map { |record| record["canonical_id"] }
IDS.each do |id|
  canonical["lexicon"]["completed_atoms"] << record_for(atoms, id) unless canonical_ids.include?(id)
end
canonical["lexicon"]["canonical_sources"] = {
  "source_developed_36" => "lexicon/completed_atoms.yaml",
  "review_approved_9" => "lexicon/reviewed_canonical_atoms.yaml"
}
write_yaml("spec/canonical_spec.yaml", canonical)

phase2 = load_yaml("spec/phase2_provisional_spec.yaml")
phase2["metadata"]["status"] = "279_provisional_meanings_pending_review"
phase2["metadata"]["reviewed_canonical_atom_source"] =
  "lexicon/reviewed_canonical_atoms.yaml"
phase2["scope"]["canonical_meanings"] = 45
phase2["scope"]["provisional_meanings"] = 279
phase2["scope"]["remaining_review_chunks"] = 31
phase2["semantic_constraints"]["canonical_45_are_immutable_without_versioned_migration"] = true
phase2["review_chunks"].each do |chunk|
  case chunk["range"]
  when "MOV:100–122"
    chunk["status"] = "canonical_by_explicit_user_approval"
  when "MOV:200–222"
    chunk["status"] = "peer_review_complete_pending_user_decision"
  end
end
write_yaml("spec/phase2_provisional_spec.yaml", phase2)

standard = load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
standard["metadata"]["title"] =
  "Era Zero Core Architecture 1.0 with selective reviewed semantic overlay"
standard["metadata"]["status"] =
  "architecture_fixed_45_canonical_279_provisional"
standard["metadata"]["approval_scope"] =
  "Architecture, 36 source-developed roots, and 9 explicitly reviewed MOV roots"
standard["metadata"]["selective_review_approval"] =
  "MOV:100–122 EXPLICITLY APPROVED AND CANONICAL"
standard["authority"]["source_canonical_roots"] =
  "LIF:000–222 and MOV:000–022 retain their approved source meanings unchanged."
standard["authority"]["review_approved_roots"] =
  "MOV:100–122 are canonical by explicit user approval after detailed peer review and final adversarial challenge."
standard["authority"]["phase2_semantics"] =
  "The remaining 279 meanings are PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW."
standard["authority"]["downstream_dependency_policy"] =
  "No downstream layer may depend on the 279 provisional meanings; dependencies on canonical roots remain subject to the current stop boundary."
standard["authority"]["change_control"] =
  "All 45 canonical meanings require explicit versioned migration for any future change."
standard["authority"]["process_1x2_clarification"] = PROCESS_1X2_RULE
standard["inventory"]["canonical_roots"] = 45
standard["inventory"]["provisional_roots"] = 279
standard["inventory"]["canonical_chunks"] = 5
standard["inventory"]["provisional_review_chunks"] = 31
standard["deferred_post_core_layers"] =
  standard["deferred_post_core_layers"].reject { |item| item.start_with?("MOV:200–222") }
standard["deferred_post_core_layers"].unshift("MAT:000–022 and every root block after MOV:200–222")
standard["canonical_review_chunks"].each do |chunk|
  case chunk["range"]
  when "MOV:100–122"
    chunk["status"] = "canonical_by_explicit_user_approval"
    chunk["selective_approval_record"] =
      "migrations/MOV_100_122_semantic_approval.yaml"
  when "MOV:200–222"
    chunk["status"] = "peer_review_complete_pending_user_decision"
  end
end
write_yaml("spec/era_zero_core_standard_1.0.0.yaml", standard)

decisions = load_yaml("extraction/user_decisions.yaml")
decisions["decisions"] << {
  "kind" => "explicit_approval_and_architecture_clarification",
  "decision" => "Canonize the final-challenge MOV:100–122 meanings and the universal nonactualized-process interpretation for lexical addresses 1x2.",
  "effect" => "Promotes exactly nine reviewed roots to canonical status, preserves their generated fields, rejects scheduling/intention/readiness semantics, and requires versioned migration for future changes."
}
decisions["decisions"] << {
  "kind" => "review_authorization_with_stop_boundary",
  "decision" => "Perform a peer review of MOV:200–222 only and do not canonize that block.",
  "effect" => "Authorizes the six-file review packet while prohibiting MAT, other root blocks, compounds, and Gate 4."
}
decisions["metadata"]["count"] = decisions["decisions"].length
write_yaml("extraction/user_decisions.yaml", decisions)

challenge = load_yaml("reviews/MOV_100_122_final_challenge.yaml")
challenge["metadata"]["status"] = "approved_and_canonicalized_by_explicit_user_direction"
challenge["metadata"]["overall_conclusion"] = "APPROVED AND CANONICAL"
challenge["metadata"]["canonicalized"] = true
challenge["authority"]["architecture_clarification_requires_user_approval"] = false
challenge["authority"]["architecture_clarification_status"] =
  "approved_and_canonical"
challenge["authority"]["roots_canonicalized"] = IDS
challenge["authority"]["canonical_lexicon_updated"] = true
challenge["authority"]["approval_record"] =
  "reviews/MOV_100_122_approval_record.md"
challenge["authority"]["mov_200_222_started"] = true
write_yaml("reviews/MOV_100_122_final_challenge.yaml", challenge)

migration = {
  "metadata" => {
    "title" => "MOV:100–122 selective semantic approval and canonization",
    "status" => "applied",
    "architecture_version" => "1.0",
    "semantic_overlay_version" => "1.0.1",
    "broad_gate3_history" => "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION",
    "generated_fields_changed" => false
  },
  "architecture_clarification" => PROCESS_1X2_RULE,
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
    "route_traversal_status" => "reserved for later composition using shared-frame movement plus MOV:020",
    "excluded_process_semantics" => %w[
      schedule queue intention permission readiness probability
    ],
    "future_change_policy" => "explicit versioned migration required",
    "downstream_implementation_begun" => false
  }
}
write_yaml("migrations/MOV_100_122_semantic_approval.yaml", migration)

puts "Applied MOV:100–122 approval: 45 canonical, 279 provisional."
