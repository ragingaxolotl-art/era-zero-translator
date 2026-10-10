#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "CON:100–122"
NEXT_RANGE = "CON:200–222"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "CON_100_122"
OVERLAY_VERSION = "1.0.8"
EXPECTED_BEFORE = { canonical: 117, provisional: 207, reviewed: 81, chunks: 23 }.freeze
EXPECTED_AFTER = { canonical: 126, provisional: 198, reviewed: 90, chunks: 22 }.freeze
RECOMMENDATION_PATH = "reviews/#{STEM}_recommended_spec.yaml"
SCORED_PATH = "reviews/#{STEM}_scored_candidates.yaml"
REVIEW_PATH = "reviews/#{STEM}_peer_review.md"
VALIDATION_PATH = "reviews/#{STEM}_validation.md"
COLLISION_PATH = "reviews/#{STEM}_collision_report.md"
STRESS_PATH = "reviews/#{STEM}_stress_tests.yaml"
MIGRATION_PATH = "migrations/#{STEM}_semantic_approval.yaml"
APPROVAL_RECORD_PATH = "reviews/#{STEM}_approval_record.md"
FIXED_FIELDS = %w[
  family address universal_slot harmonic_signature_semitones family_onset
  local_compact_root canonical_transliteration formal_carrier note_path_semitones
].freeze

def load_yaml(path)
  EraZeroValidation.load_yaml(path)
end

def write_yaml(path, document)
  EraZeroValidation.write(path, YAML.dump(document))
end

def by_id(document)
  document.fetch("atoms").to_h { |record| [record.fetch("canonical_id"), record] }
end

def status_ranges(records, status)
  EraZeroValidation::FAMILIES.keys.flat_map do |family|
    layers = (0..2).select do |layer|
      [0, 1, 2].product([0, 1, 2]).all? do |second, third|
        records.fetch("#{family}:#{layer}#{second}#{third}")["status"] == status
      end
    end
    next [] if layers.empty?
    if layers.each_cons(2).all? { |left, right| right == left + 1 }
      ["#{family}:#{layers.first}00–#{layers.last}22"]
    else
      layers.map { |layer| "#{family}:#{layer}00–#{layer}22" }
    end
  end
end

validation = File.read(File.join(ROOT, VALIDATION_PATH), encoding: "UTF-8")
raise("#{RANGE} review validation has not passed") unless
  validation.include?("Status: **PASS — READY FOR APPROVAL**") &&
    validation.include?("Checks failed: **0**") &&
    validation.include?("PACKET CONTRACT SATISFIED")

pre_regression = File.read(File.join(ROOT, "reports/current_state_regression.md"), encoding: "UTF-8")
raise("pre-approval current-state regression has not passed") unless
  pre_regression.include?("Status: **PASS — CURRENT AUTHORITY AND TRANSLATOR BOUNDARIES VERIFIED**") &&
    pre_regression.include?("Checks failed: **0**") &&
    pre_regression.include?("Canonical roots: **117**")

recommended = load_yaml(RECOMMENDATION_PATH)
scored = load_yaml(SCORED_PATH)
stress = load_yaml(STRESS_PATH)
raise("recommendation is not pending delegated approval") unless
  recommended.dig("metadata", "status") == "recommended_pending_delegated_approval" &&
    recommended.fetch("roots").none? { |root| root["canonicalized"] }
raise("scored candidates are not pending approval") unless
  scored.dig("metadata", "status") == "review_complete_pending_preapproval_validation" &&
    scored.fetch("roots").none? { |root| root["canonicalized"] }

recommendations = recommended.fetch("roots").to_h do |root|
  [root.dig("fixed_generated_fields", "canonical_id"), root]
end
raise("unexpected recommendation scope") unless recommendations.keys == IDS

atoms_doc = load_yaml("lexicon/atoms.yaml")
all_doc = load_yaml("lexicon/all_atoms.yaml")
provisional_doc = load_yaml("lexicon/provisional_atoms.yaml")
source_doc = load_yaml("lexicon/completed_atoms.yaml")
reviewed_doc = load_yaml("lexicon/reviewed_canonical_atoms.yaml")
atoms = by_id(atoms_doc)
all_atoms = by_id(all_doc)
provisional = by_id(provisional_doc)
source_snapshot = Marshal.load(Marshal.dump(source_doc))
reviewed_snapshot = Marshal.load(Marshal.dump(reviewed_doc))

raise("unexpected reviewed-root baseline") unless reviewed_doc.fetch("atoms").length == EXPECTED_BEFORE.fetch(:reviewed)
raise("unexpected canonical baseline") unless atoms.values.count { |record| record["status"] == "canonical" } == EXPECTED_BEFORE.fetch(:canonical)
raise("unexpected provisional baseline") unless provisional.length == EXPECTED_BEFORE.fetch(:provisional)

IDS.each do |id|
  [atoms, all_atoms, provisional].each do |records|
    raise("#{id} is not provisional") unless records.fetch(id)["status"] == "provisional_pending_detailed_semantic_review"
  end
  expected = EraZeroValidation.packet_fixed_projection(atoms.fetch(id))
  raise("fixed packet fields changed for #{id}") unless recommendations.fetch(id).fetch("fixed_generated_fields") == expected
end

fixed_before = [atoms, all_atoms].to_h do |records|
  [records.object_id, IDS.to_h { |id| [id, Marshal.load(Marshal.dump(records.fetch(id).slice(*FIXED_FIELDS)))] }]
end

[atoms, all_atoms].each do |records|
  IDS.each do |id|
    record = records.fetch(id)
    root = recommendations.fetch(id)
    prior = provisional.fetch(id)
    record["title"] = root.fetch("proposed_title")
    record["core_definition"] = root.fetch("invariant_definition")
    record["translation_candidates"] = [root.fetch("proposed_title")]
    record["distinctions_and_exclusions"] = root.fetch("excluded_meanings")
    record["neighbor_contrasts"] = root.fetch("nearest_neighbors")
    record["status"] = "canonical"
    record["approval_effect"] = "CANONICAL BY EXPLICIT USER-DELEGATED APPROVAL AFTER DETAILED ADVERSARIAL REVIEW."
    record["semantic_origin"] = "Detailed CON:100–122 expression/reception/distribution winner approved under the user's explicit delegation."
    record["canonical_version"] = "#{OVERLAY_VERSION}-delegated-semantic-overlay"
    record["review_history"] = {
      "withdrawn_broad_gate3_promotion" => WITHDRAWAL,
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
      "approval_basis" => "Explicit user delegation to approve reviewed roots after reusable validation and full authority regression.",
      "meaning_change_from_phase2_proposal" => root.fetch("proposed_title") != prior["title"] || root.fetch("invariant_definition") != prior["core_definition"],
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

[atoms, all_atoms].each do |records|
  IDS.each do |id|
    raise("fixed-field mutation in #{id}") unless records.fetch(id).slice(*FIXED_FIELDS) == fixed_before.fetch(records.object_id).fetch(id)
  end
end
raise("source-canonical mutation") unless source_doc == source_snapshot
raise("previously reviewed ledger mutated before append") unless reviewed_doc == reviewed_snapshot

canonical_count = atoms.values.count { |record| record["status"] == "canonical" }
provisional_count = atoms.values.count { |record| record["status"] == "provisional_pending_detailed_semantic_review" }
remaining_chunks = provisional_count / 9
reviewed_count = reviewed_doc.fetch("atoms").length + IDS.length
raise("unexpected post-approval inventory") unless
  canonical_count == EXPECTED_AFTER.fetch(:canonical) &&
    provisional_count == EXPECTED_AFTER.fetch(:provisional) &&
    remaining_chunks == EXPECTED_AFTER.fetch(:chunks) &&
    reviewed_count == EXPECTED_AFTER.fetch(:reviewed)

atoms_doc["metadata"]["semantic_authority_status"] = "mixed_#{canonical_count}_canonical_#{provisional_count}_provisional"
atoms_doc["metadata"]["canonical_semantic_roots"] = canonical_count
atoms_doc["metadata"]["provisional_semantic_roots"] = provisional_count
atoms_doc["metadata"]["selective_review_approval_status"] = "MOV:100–222, MAT:000–222, MIN:000–222, and CON:000–122 canonical through detailed selective approvals"
all_doc["metadata"]["canonical_count"] = canonical_count
all_doc["metadata"]["provisional_count"] = provisional_count
all_doc["metadata"]["semantic_status"] = "mixed_#{canonical_count}_canonical_and_#{provisional_count}_provisional"
all_doc["metadata"]["selective_review_approval_status"] = "Ten reviewed nine-root packets canonical"

provisional_doc["atoms"].reject! { |record| IDS.include?(record["canonical_id"]) }
raise("provisional complement count mismatch") unless provisional_doc["atoms"].length == provisional_count
provisional_doc["metadata"]["title"] = "Era Zero #{provisional_count} generated addresses — provisional semantic candidates"
provisional_doc["metadata"]["count"] = provisional_count
provisional_doc["metadata"]["canonical_baseline_count"] = canonical_count
provisional_doc["metadata"]["approved_removed_ranges"] = %w[
  MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122 MAT:200–222
  MIN:000–022 MIN:100–122 MIN:200–222 CON:000–022 CON:100–122
]

write_yaml("lexicon/atoms.yaml", atoms_doc)
write_yaml("lexicon/all_atoms.yaml", all_doc)
write_yaml("lexicon/provisional_atoms.yaml", provisional_doc)

reviewed_ids = reviewed_doc.fetch("atoms").map { |record| record["canonical_id"] }.to_set
IDS.each { |id| reviewed_doc["atoms"] << atoms.fetch(id) unless reviewed_ids.include?(id) }
order = atoms_doc.fetch("atoms").each_with_index.to_h { |record, index| [record["canonical_id"], index] }
reviewed_doc["atoms"].sort_by! { |record| order.fetch(record["canonical_id"]) }
reviewed_doc["metadata"]["count"] = reviewed_count
reviewed_doc["metadata"]["ranges"] = %w[
  MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122 MAT:200–222
  MIN:000–022 MIN:100–122 MIN:200–222 CON:000–022 CON:100–122
]
reviewed_doc["metadata"]["semantic_overlay_version"] = OVERLAY_VERSION
reviewed_doc["metadata"]["latest_approval_record"] = MIGRATION_PATH
write_yaml("lexicon/reviewed_canonical_atoms.yaml", reviewed_doc)

authority = load_yaml("lexicon/semantic_authority.yaml")
raise("approval already recorded") if authority.fetch("approved_review_packets").any? { |packet| packet["range"] == RANGE }
authority["metadata"]["current_status"] = "#{canonical_count} canonical roots; #{provisional_count} provisional roots; no completed review packet awaiting decision"
authority["metadata"]["selective_review_approval"] = "MOV:100–222, MAT:000–222, MIN:000–222, and CON:000–122 canonical through detailed selective approvals"
authority["metadata"]["last_review_update"] = "2026-08-02"
authority["semantic_inventory"]["canonical_roots"] = canonical_count
authority["semantic_inventory"]["provisional_roots"] = provisional_count
authority["semantic_inventory"]["canonical_ranges"] = status_ranges(atoms, "canonical")
authority["semantic_inventory"]["provisional_ranges"] = status_ranges(atoms, "provisional_pending_detailed_semantic_review")
authority.keys.grep(/\Aprovisional_for_\d+_addresses\z/).each { |key| authority.delete(key) }
authority["provisional_for_#{provisional_count}_addresses"] = ["semantic_title", "invariant_definition", "translation_candidates"]
authority["approved_review_packets"] << {
  "range" => RANGE,
  "status" => "canonical_by_explicit_user_delegation_after_detailed_review",
  "canonicalized" => true,
  "generated_fields_changed" => false
}
authority["review_packets_pending_user_decision"] = []
authority["last_completed_review_packet"] = { "range" => RANGE, "status" => "canonical_by_delegated_approval", "canonicalized" => true }
authority["next_review_packet"] = { "range" => NEXT_RANGE, "status" => "not_begun", "canonicalized" => false }
authority["semantic_review_progress"] = {
  "canonical_review_chunks" => 10,
  "reviewed_pending_decision_chunks" => 0,
  "unreviewed_chunks" => remaining_chunks,
  "reviewed_pending_decision_roots" => 0,
  "unreviewed_roots" => provisional_count
}
authority["stop_boundary"] = { "do_not_begin" => ["#{NEXT_RANGE} in this approval packet", "any later root block", "Gate 4", "translator implementation"] }
write_yaml("lexicon/semantic_authority.yaml", authority)

version = load_yaml("spec/version.yaml")
version["semantic_authority_status"] = "#{canonical_count}_canonical_#{provisional_count}_provisional"
version["canonical_semantic_roots"] = canonical_count
version["provisional_semantic_roots"] = provisional_count
version["active_review_packet"] = nil
version["last_completed_review_packet"] = RANGE
version["next_semantic_review_packet"] = NEXT_RANGE
version["review_packets_pending_user_decision"] = []
version["unreviewed_semantic_roots"] = provisional_count
version["unreviewed_nine_root_chunks"] = remaining_chunks
version["selective_semantic_overlay"] = "MOV:100–222, MAT:000–222, MIN:000–222, and CON:000–122"
version["selective_semantic_overlay_record"] = MIGRATION_PATH
write_yaml("spec/version.yaml", version)

canonical = load_yaml("spec/canonical_spec.yaml")
canonical["metadata"]["semantic_authority_status"] = "architecture fixed; #{canonical_count} canonical roots; #{provisional_count} provisional roots"
canonical["lexicon"]["completed_count"] = canonical_count
canonical["lexicon"]["remaining_count"] = provisional_count
canonical_ids = canonical.dig("lexicon", "completed_atoms").map { |record| record["canonical_id"] }.to_set
IDS.each { |id| canonical["lexicon"]["completed_atoms"] << atoms.fetch(id) unless canonical_ids.include?(id) }
canonical["lexicon"]["completed_atoms"].sort_by! { |record| order.fetch(record["canonical_id"]) }
canonical["lexicon"]["canonical_sources"] = {
  "source_developed_36" => "lexicon/completed_atoms.yaml",
  "review_approved_90" => "lexicon/reviewed_canonical_atoms.yaml"
}
write_yaml("spec/canonical_spec.yaml", canonical)

phase2 = load_yaml("spec/phase2_provisional_spec.yaml")
phase2["metadata"]["status"] = "#{provisional_count}_provisional_meanings_pending_review"
phase2["scope"]["canonical_meanings"] = canonical_count
phase2["scope"]["provisional_meanings"] = provisional_count
phase2["scope"]["remaining_review_chunks"] = remaining_chunks
phase2["scope"]["reviewed_pending_decision_chunks"] = 0
phase2["scope"]["reviewed_pending_decision_meanings"] = 0
phase2["scope"]["unreviewed_meanings"] = provisional_count
phase2["semantic_constraints"].keys.grep(/\Acanonical_\d+_are_immutable/).each { |key| phase2["semantic_constraints"].delete(key) }
phase2["semantic_constraints"]["canonical_#{canonical_count}_are_immutable_without_versioned_migration"] = true
phase2["review_chunks"].each { |chunk| chunk["status"] = "canonical_by_reviewed_selective_approval" if chunk["range"] == RANGE }
write_yaml("spec/phase2_provisional_spec.yaml", phase2)

standard = load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
standard["metadata"]["status"] = "architecture_fixed_#{canonical_count}_canonical_#{provisional_count}_provisional"
standard["metadata"]["approval_scope"] = "Architecture, 36 source-developed roots, and 90 roots canonized after detailed review"
standard["metadata"]["review_progress"] = "Ten nine-root review packets canonical; #{NEXT_RANGE} is next and not begun"
standard["authority"]["review_approved_roots"] = "MOV:100–222, MAT:000–222, MIN:000–222, and CON:000–122 are canonical through explicit or delegated approval after detailed adversarial review."
standard["authority"]["reviewed_provisional_roots"] = "No completed review packet remains pending user decision."
standard["authority"]["phase2_semantics"] = "The remaining #{provisional_count} meanings are PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW."
standard["authority"]["downstream_dependency_policy"] = "No downstream layer may depend on the #{provisional_count} provisional meanings."
standard["authority"]["change_control"] = "All #{canonical_count} canonical meanings require explicit versioned migration for any future change."
standard["inventory"]["canonical_roots"] = canonical_count
standard["inventory"]["provisional_roots"] = provisional_count
standard["inventory"]["canonical_chunks"] = canonical_count / 9
standard["inventory"]["provisional_review_chunks"] = remaining_chunks
standard["inventory"]["reviewed_pending_decision_roots"] = 0
standard["inventory"]["unreviewed_roots"] = provisional_count
standard["inventory"]["reviewed_pending_decision_chunks"] = 0
standard["inventory"]["unreviewed_review_chunks"] = remaining_chunks
standard["deferred_post_core_layers"].map! { |item| item.include?(RANGE) ? item.gsub(RANGE, NEXT_RANGE) : item }
standard["canonical_review_chunks"].each do |chunk|
  next unless chunk["range"] == RANGE
  chunk["status"] = "canonical_by_reviewed_selective_approval"
  chunk["selective_approval_record"] = MIGRATION_PATH
end
write_yaml("spec/era_zero_core_standard_1.0.0.yaml", standard)

readiness = load_yaml("spec/translator_readiness.yaml")
readiness["current_inventory"]["canonical_meanings"] = canonical_count
readiness["current_inventory"]["provisional_meanings"] = provisional_count
readiness["current_inventory"]["reviewed_pending_user_decision"] = { "roots" => 0, "packets" => [] }
readiness["current_inventory"]["unreviewed"] = { "roots" => provisional_count, "nine_root_chunks" => remaining_chunks }
readiness["safe_now"]["maximum_semantic_scope"] = "#{canonical_count} canonical roots"
readiness["next_semantic_chunk_after_pending_decisions"] = NEXT_RANGE
write_yaml("spec/translator_readiness.yaml", readiness)

recommended["metadata"]["status"] = "approved_and_canonical_by_delegated_authority"
recommended["metadata"]["roots_canonicalized"] = IDS
recommended["metadata"]["approval_record"] = MIGRATION_PATH
recommended["approval_checklist"]["canonicalized"] = true
recommended["roots"].each { |root| root["proposal_status"] = "canonical_by_delegated_approval"; root["canonicalized"] = true }
write_yaml(RECOMMENDATION_PATH, recommended)

scored["metadata"]["status"] = "approved_and_canonical_by_delegated_authority"
scored["metadata"]["roots_canonicalized"] = IDS
scored["metadata"]["approval_record"] = MIGRATION_PATH
scored["roots"].each { |root| root["canonicalized"] = true }
write_yaml(SCORED_PATH, scored)

migration = {
  "metadata" => {
    "title" => "#{RANGE} delegated semantic approval",
    "status" => "applied",
    "architecture_version" => "1.0",
    "semantic_overlay_version" => OVERLAY_VERSION,
    "authority" => "Explicit user delegation to approve reviewed roots",
    "broad_gate3_history" => WITHDRAWAL,
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
    record = atoms.fetch(id)
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

approval = +"# CON:100–122 Delegated Semantic Approval\n\n"
approval << "Status: **APPLIED — NINE ROOTS CANONICAL**\n\n"
approval << "The user delegated authority to approve reviewed roots and requested the largest next block that could be completed well. The packet compared five architectures per root, scored 45 candidates across 360 criterion values, ran #{stress.fetch("tests").length} English routing tests, passed 17 reusable packet checks, and passed the complete pre-approval authority regression. `#{RANGE}` is approved as semantic overlay #{OVERLAY_VERSION}.\n\n"
IDS.each do |id|
  record = atoms.fetch(id)
  approval << "- `#{id}` — **#{record["title"]}**: #{record["core_definition"]}\n"
end
approval << "\nThe approved layer owns participant-addressed communicative exchange processes: source expression, target reception, and shared distribution, each completed, active, or nonactualized. It excludes content, physical propagation, comprehension, channel lifecycle, protocol, scheduling, and connection relationships.\n\n"
approval << "No generated field, source-canonical meaning, or previously reviewed meaning changed. Era Zero now contains **#{canonical_count} canonical roots** and **#{provisional_count} provisional roots in #{remaining_chunks} nine-root chunks**. The broad Gate 3 approval remains withdrawn. `#{NEXT_RANGE}`, Gate 4, and translator implementation were not begun.\n"
EraZeroValidation.write(APPROVAL_RECORD_PATH, approval)

status = <<~MARKDOWN
  # Era Zero Semantic Authority Status

  Current authority: **#{canonical_count} CANONICAL ROOTS / #{provisional_count} PROVISIONAL ROOTS**

  The earlier broad Gate 3 promotion remains **#{WITHDRAWAL}**. Later selective approvals are distinct root-level authority actions and do not reinstate that broad promotion.

  ## Fixed architecture

  - Era Zero Core Architecture **1.0** remains fixed.
  - All 324 addresses retain their deterministic family, address, universal slot, harmonic signature, family onset, local compact root, formal carrier, and relative note path.
  - Lexical `1x2` denotes a nonactualized process and does not encode intention, planning, scheduling, queueing, permission, probability, or future time.
  - Runtime `[2]/num` remains a separate token-status operator.

  ## Canonical semantic authority

  - The original **36 source-developed roots** remain canonical and unchanged: `LIF:000–222` and `MOV:000–022`.
  - The **#{reviewed_count} roots approved after detailed semantic review** are canonical: `MOV:100–222`, `MAT:000–222`, `MIN:000–222`, and `CON:000–122`.
  - `MOV:100–122` was approved directly by the user. The other nine reviewed packets were approved under the user's explicit delegation.
  - Future changes to any of the #{canonical_count} canonical meanings require an explicit versioned migration.

  The canonical Connection family through `CON:122` now has two clean layers:

  - `CON:0xx` — communicative loci: source endpoints, target endpoints, and shared channels;
  - `CON:1xx` — communicative exchange processes: source expression, target reception, and shared distribution, each completed, active, or nonactualized.

  Source expression completion does not entail target reception; reception does not entail comprehension; shared distribution does not entail uptake by every endpoint. Content, physical carriers, cognition, topology, protocol, scheduling, and future relationship meanings remain outside these invariants.

  ## Provisional semantic authority

  The remaining **#{provisional_count} titles and definitions in #{remaining_chunks} nine-root chunks** are **PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW**. No compound dictionary, English concept index, etymology layer, semantic IR, grammar implementation, renderer, or translator may depend on them.

  ## Active review and stop boundary

  - Reviewed packets pending decision: **none**.
  - Last completed packet: `#{RANGE}`, canonical after delegated approval.
  - Next review packet: `#{NEXT_RANGE}`, **not begun**.
  - Not begun in this packet: `#{NEXT_RANGE}`, any later root block, Gate 4, compound architecture, or translator implementation.

  ## Translator readiness

  The broad translator remains blocked by the #{provisional_count} provisional meanings and unfinished compound, sense, IR, grammar, renderer, and decoder layers.

  A restricted developer renderer may operate only on the #{canonical_count} explicit canonical IDs and must reject provisional roots and unapproved compounds.

  Machine-readable authority: `lexicon/semantic_authority.yaml`.
  Latest selective approval record: `#{MIGRATION_PATH}`.
  Withdrawal history: `gate3_withdrawal_record.md`.
MARKDOWN
EraZeroValidation.write("semantic_authority_status.md", status)

roadmap_path = File.join(ROOT, "reports/translator_readiness_roadmap.md")
roadmap = File.read(roadmap_path, encoding: "UTF-8")
roadmap.gsub!("117 canonical roots", "126 canonical roots")
roadmap.gsub!("117 meanings are canonical", "126 meanings are canonical")
roadmap.gsub!("207 meanings remain provisional in 23 nine-root chunks", "198 meanings remain provisional in 22 nine-root chunks")
roadmap.gsub!("117 canonical; 207 provisional", "126 canonical; 198 provisional")
roadmap.gsub!("the 117 explicit canonical IDs", "the 126 explicit canonical IDs")
roadmap.gsub!("render only the 117 canonical roots", "render only the 126 canonical roots")
roadmap.gsub!("After approval of `CON:000–022`:", "After approval of `CON:100–122`:")
roadmap.gsub!("`CON:100–122` is next and has not been begun", "`CON:200–222` is next and has not been begun")
roadmap.sub!(/1\. `CON:100–222` in two nine-root chunks;/, "1. `CON:200–222` in one nine-root chunk;")
EraZeroValidation.write("reports/translator_readiness_roadmap.md", roadmap)

infrastructure_path = File.join(ROOT, "reports/validation_infrastructure.md")
infrastructure = File.read(infrastructure_path, encoding: "UTF-8")
infrastructure.gsub!("seven effective selective-approval migrations and all 81 promoted roots", "eight effective selective-approval migrations and all 90 promoted roots")
infrastructure.gsub!("117-root canonical set and 207-root provisional complement", "126-root canonical set and 198-root provisional complement")
EraZeroValidation.write("reports/validation_infrastructure.md", infrastructure)

puts "Applied #{RANGE} delegated approval: #{canonical_count} canonical / #{provisional_count} provisional."
