#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "DAT:200–222"
NEXT_RANGE = "CRE:000–022"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "DAT_200_222"
OVERLAY_VERSION = "1.0.24"
BEFORE = { canonical: 261, provisional: 63, reviewed: 225, chunks: 7 }.freeze
AFTER = { canonical: 270, provisional: 54, reviewed: 234, chunks: 6 }.freeze
RECOMMENDATION = "reviews/#{STEM}_recommended_spec.yaml"
SCORED = "reviews/#{STEM}_scored_candidates.yaml"
STRESS = "reviews/#{STEM}_stress_tests.yaml"
REVIEW = "reviews/#{STEM}_peer_review.md"
VALIDATION = "reviews/#{STEM}_validation.md"
COLLISION = "reviews/#{STEM}_collision_report.md"
SOUNDNESS = "reviews/DAT_000_222_soundness_audit.md"
MIGRATION = "migrations/#{STEM}_semantic_approval.yaml"
APPROVAL_RECORD = "reviews/#{STEM}_approval_record.md"
FIXED_FIELDS = %w[family address universal_slot harmonic_signature_semitones family_onset local_compact_root canonical_transliteration formal_carrier note_path_semitones].freeze

def load_yaml(path)
  EraZeroValidation.load_yaml(path)
end

def write_yaml(path, value)
  EraZeroValidation.write(path, YAML.dump(value))
end

def by_id(document)
  document.fetch("atoms").to_h { |record| [record.fetch("canonical_id"), record] }
end

def status_ranges(records, status)
  EraZeroValidation::FAMILIES.keys.flat_map do |family|
    layers = (0..2).select do |layer|
      [0, 1, 2].product([0, 1, 2]).all? { |second, third| records.fetch("#{family}:#{layer}#{second}#{third}")["status"] == status }
    end
    next [] if layers.empty?
    if layers.each_cons(2).all? { |left, right| right == left + 1 }
      ["#{family}:#{layers.first}00–#{layers.last}22"]
    else
      layers.map { |layer| "#{family}:#{layer}00–#{layer}22" }
    end
  end
end

packet_validation = File.read(File.join(ROOT, VALIDATION), encoding: "UTF-8")
raise("packet validation has not passed") unless packet_validation.include?("PASS — READY FOR APPROVAL") && packet_validation.include?("Checks failed: **0**")
soundness_text = File.read(File.join(ROOT, SOUNDNESS), encoding: "UTF-8")
raise("DAT:000–222 full-family soundness has not passed") unless soundness_text.include?("PASS — DAT:200–222 READY FOR DELEGATED APPROVAL") && soundness_text.include?("Checks failed: **0**")
regression_text = File.read(File.join(ROOT, "reports/current_state_regression.md"), encoding: "UTF-8")
raise("pre-approval regression has not passed") unless regression_text.include?("PASS — CURRENT AUTHORITY AND TRANSLATOR BOUNDARIES VERIFIED") && regression_text.include?("Canonical roots: **261**") && regression_text.include?("Checks failed: **0**")

recommended = load_yaml(RECOMMENDATION)
scored = load_yaml(SCORED)
stress = load_yaml(STRESS)
raise("recommendation is not pending") unless recommended.dig("metadata", "status") == "recommended_pending_delegated_approval"
raise("candidate record is not pending") unless scored.dig("metadata", "status") == "review_complete_pending_preapproval_validation"
proposals = recommended.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
raise("unexpected packet scope") unless proposals.keys == IDS

atoms_doc = load_yaml("lexicon/atoms.yaml")
all_doc = load_yaml("lexicon/all_atoms.yaml")
provisional_doc = load_yaml("lexicon/provisional_atoms.yaml")
source_doc = load_yaml("lexicon/completed_atoms.yaml")
reviewed_doc = load_yaml("lexicon/reviewed_canonical_atoms.yaml")
atoms = by_id(atoms_doc)
all_atoms = by_id(all_doc)
provisional = by_id(provisional_doc)
source_fingerprint = EraZeroValidation.fingerprint(source_doc.fetch("atoms"))
reviewed_before = Marshal.load(Marshal.dump(reviewed_doc))

raise("source baseline changed") unless source_fingerprint == EraZeroValidation::SOURCE_CANONICAL_FINGERPRINT
raise("canonical baseline mismatch") unless atoms.values.count { |record| record["status"] == "canonical" } == BEFORE.fetch(:canonical)
raise("provisional baseline mismatch") unless provisional.length == BEFORE.fetch(:provisional)
raise("reviewed baseline mismatch") unless reviewed_doc.fetch("atoms").length == BEFORE.fetch(:reviewed)
IDS.each do |id|
  [atoms, all_atoms, provisional].each { |records| raise("#{id} is not provisional") unless records.fetch(id)["status"] == "provisional_pending_detailed_semantic_review" }
  raise("fixed packet fields changed for #{id}") unless proposals.fetch(id).fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atoms.fetch(id))
end

fixed_before = [atoms, all_atoms].to_h do |records|
  [records.object_id, IDS.to_h { |id| [id, Marshal.load(Marshal.dump(records.fetch(id).slice(*FIXED_FIELDS)))] }]
end

[atoms, all_atoms].each do |records|
  IDS.each do |id|
    record = records.fetch(id)
    proposal = proposals.fetch(id)
    old = provisional.fetch(id)
    record["title"] = proposal.fetch("proposed_title")
    record["core_definition"] = proposal.fetch("invariant_definition")
    record["translation_candidates"] = [proposal.fetch("proposed_title")]
    record["distinctions_and_exclusions"] = proposal.fetch("excluded_meanings")
    record["neighbor_contrasts"] = proposal.fetch("nearest_neighbors")
    record["status"] = "canonical"
    record["approval_effect"] = "CANONICAL BY EXPLICIT USER-DELEGATED APPROVAL AFTER DETAILED ADVERSARIAL REVIEW."
    record["semantic_origin"] = "Detailed DAT:200–222 information-process affordance winner approved under explicit user delegation."
    record["canonical_version"] = "#{OVERLAY_VERSION}-delegated-semantic-overlay"
    record["review_history"] = {
      "withdrawn_broad_gate3_promotion" => WITHDRAWAL, "detailed_peer_review" => REVIEW,
      "scored_candidates" => SCORED, "validation" => VALIDATION, "data_full_family_soundness" => SOUNDNESS,
      "recommendation" => RECOMMENDATION, "collision_report" => COLLISION, "stress_tests" => STRESS,
      "delegated_approval_migration" => MIGRATION
    }
    record["canonization"] = {
      "standard" => "Era Zero Core Architecture 1.0 selective semantic overlay",
      "approval_basis" => "Explicit user delegation after reusable packet validation, complete Data-family soundness validation, and full authority regression.",
      "meaning_change_from_phase2_proposal" => proposal.fetch("proposed_title") != old["title"] || proposal.fetch("invariant_definition") != old["core_definition"],
      "source_proposal_file" => "lexicon/provisional_atoms.yaml", "approval_status" => "USER-DELEGATED APPROVAL — CANONICAL",
      "audit_history_only" => false, "downstream_implementation_occurred" => false,
      "future_change_policy" => "versioned migration required"
    }
    record["authority"] = { "semantic_status" => "canonical", "approval_status" => "explicit_user_delegation_after_detailed_review", "downstream_dependency_permitted" => true }
  end
end

[atoms, all_atoms].each do |records|
  IDS.each { |id| raise("fixed-field mutation in #{id}") unless records.fetch(id).slice(*FIXED_FIELDS) == fixed_before.fetch(records.object_id).fetch(id) }
end
raise("source-canonical mutation") unless EraZeroValidation.fingerprint(source_doc.fetch("atoms")) == source_fingerprint
raise("previous reviewed ledger mutated before append") unless reviewed_doc == reviewed_before

canonical_count = atoms.values.count { |record| record["status"] == "canonical" }
provisional_count = atoms.values.count { |record| record["status"] == "provisional_pending_detailed_semantic_review" }
reviewed_count = reviewed_doc.fetch("atoms").length + IDS.length
remaining_chunks = provisional_count / 9
raise("post-approval counts mismatch") unless [canonical_count, provisional_count, reviewed_count, remaining_chunks] == AFTER.values_at(:canonical, :provisional, :reviewed, :chunks)

overlay_label = "MOV:100–222, MAT:000–222, MIN:000–222, CON:000–222, STR:000–222, WRN:000–222, REP:000–222, LOG:000–222, and DAT:000–222"
atoms_doc["metadata"]["semantic_authority_status"] = "mixed_#{canonical_count}_canonical_#{provisional_count}_provisional"
atoms_doc["metadata"]["canonical_semantic_roots"] = canonical_count
atoms_doc["metadata"]["provisional_semantic_roots"] = provisional_count
atoms_doc["metadata"]["selective_review_approval_status"] = "#{overlay_label} canonical through detailed selective approvals"
all_doc["metadata"]["canonical_count"] = canonical_count
all_doc["metadata"]["provisional_count"] = provisional_count
all_doc["metadata"]["semantic_status"] = "mixed_#{canonical_count}_canonical_and_#{provisional_count}_provisional"
all_doc["metadata"]["selective_review_approval_status"] = "Twenty-six reviewed nine-root packets canonical"
provisional_doc["atoms"].reject! { |record| IDS.include?(record["canonical_id"]) }
provisional_doc["metadata"]["title"] = "Era Zero #{provisional_count} generated addresses — provisional semantic candidates"
provisional_doc["metadata"]["count"] = provisional_count
provisional_doc["metadata"]["canonical_baseline_count"] = canonical_count
provisional_doc["metadata"]["approved_removed_ranges"] << RANGE unless provisional_doc["metadata"]["approved_removed_ranges"].include?(RANGE)
raise("provisional complement mismatch") unless provisional_doc["atoms"].length == provisional_count
write_yaml("lexicon/atoms.yaml", atoms_doc)
write_yaml("lexicon/all_atoms.yaml", all_doc)
write_yaml("lexicon/provisional_atoms.yaml", provisional_doc)

order = atoms_doc.fetch("atoms").each_with_index.to_h { |record, index| [record["canonical_id"], index] }
reviewed_ids = reviewed_doc.fetch("atoms").map { |record| record["canonical_id"] }.to_set
IDS.each { |id| reviewed_doc["atoms"] << atoms.fetch(id) unless reviewed_ids.include?(id) }
reviewed_doc["atoms"].sort_by! { |record| order.fetch(record["canonical_id"]) }
reviewed_doc["metadata"]["count"] = reviewed_count
reviewed_doc["metadata"]["ranges"] << RANGE unless reviewed_doc["metadata"]["ranges"].include?(RANGE)
reviewed_doc["metadata"]["semantic_overlay_version"] = OVERLAY_VERSION
reviewed_doc["metadata"]["latest_approval_record"] = MIGRATION
write_yaml("lexicon/reviewed_canonical_atoms.yaml", reviewed_doc)

authority = load_yaml("lexicon/semantic_authority.yaml")
raise("approval already recorded") if authority.fetch("approved_review_packets").any? { |packet| packet["range"] == RANGE }
authority["metadata"]["current_status"] = "#{canonical_count} canonical roots; #{provisional_count} provisional roots; no completed review packet awaiting decision"
authority["metadata"]["selective_review_approval"] = "#{overlay_label} canonical through detailed selective approvals"
authority["metadata"]["last_review_update"] = "2026-10-08"
authority["semantic_inventory"]["canonical_roots"] = canonical_count
authority["semantic_inventory"]["provisional_roots"] = provisional_count
authority["semantic_inventory"]["canonical_ranges"] = status_ranges(atoms, "canonical")
authority["semantic_inventory"]["provisional_ranges"] = status_ranges(atoms, "provisional_pending_detailed_semantic_review")
authority.keys.grep(/\Aprovisional_for_\d+_addresses\z/).each { |key| authority.delete(key) }
authority["provisional_for_#{provisional_count}_addresses"] = ["semantic_title", "invariant_definition", "translation_candidates"]
authority["approved_review_packets"] << { "range" => RANGE, "status" => "canonical_by_explicit_user_delegation_after_detailed_review", "canonicalized" => true, "generated_fields_changed" => false }
authority["review_packets_pending_user_decision"] = []
authority["last_completed_review_packet"] = { "range" => RANGE, "status" => "canonical_by_delegated_approval", "canonicalized" => true }
authority["next_review_packet"] = { "range" => NEXT_RANGE, "status" => "not_begun", "canonicalized" => false }
authority["semantic_review_progress"] = { "canonical_review_chunks" => 26, "reviewed_pending_decision_chunks" => 0, "unreviewed_chunks" => remaining_chunks, "reviewed_pending_decision_roots" => 0, "unreviewed_roots" => provisional_count }
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
version["selective_semantic_overlay"] = overlay_label
version["selective_semantic_overlay_record"] = MIGRATION
write_yaml("spec/version.yaml", version)

canonical = load_yaml("spec/canonical_spec.yaml")
canonical["metadata"]["semantic_authority_status"] = "architecture fixed; #{canonical_count} canonical roots; #{provisional_count} provisional roots"
canonical["lexicon"]["completed_count"] = canonical_count
canonical["lexicon"]["remaining_count"] = provisional_count
canonical_ids = canonical.dig("lexicon", "completed_atoms").map { |record| record["canonical_id"] }.to_set
IDS.each { |id| canonical["lexicon"]["completed_atoms"] << atoms.fetch(id) unless canonical_ids.include?(id) }
canonical["lexicon"]["completed_atoms"].sort_by! { |record| order.fetch(record["canonical_id"]) }
canonical["lexicon"]["canonical_sources"] = { "source_developed_36" => "lexicon/completed_atoms.yaml", "review_approved_234" => "lexicon/reviewed_canonical_atoms.yaml" }
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
standard["metadata"]["approval_scope"] = "Architecture, 36 source-developed roots, and 234 roots canonized after detailed review"
standard["metadata"]["review_progress"] = "Twenty-six nine-root review packets canonical; #{NEXT_RANGE} is next and not begun"
standard["authority"]["review_approved_roots"] = "#{overlay_label} are canonical through explicit or delegated approval after detailed adversarial review."
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
standard["deferred_post_core_layers"].map! { |item| item.include?("DAT:200–222") ? item.gsub("DAT:200–222", "CRE:000–222") : item }
standard["canonical_review_chunks"].each do |chunk|
  next unless chunk["range"] == RANGE
  chunk["status"] = "canonical_by_reviewed_selective_approval"
  chunk["selective_approval_record"] = MIGRATION
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
recommended["metadata"]["approval_record"] = MIGRATION
recommended["approval_checklist"]["canonicalized"] = true
recommended["roots"].each { |root| root["proposal_status"] = "canonical_by_delegated_approval"; root["canonicalized"] = true }
write_yaml(RECOMMENDATION, recommended)
scored["metadata"]["status"] = "approved_and_canonical_by_delegated_authority"
scored["metadata"]["roots_canonicalized"] = IDS
scored["metadata"]["approval_record"] = MIGRATION
scored["roots"].each { |root| root["canonicalized"] = true }
write_yaml(SCORED, scored)

migration = {
  "metadata" => { "title" => "#{RANGE} delegated semantic approval", "status" => "applied", "architecture_version" => "1.0", "semantic_overlay_version" => OVERLAY_VERSION, "authority" => "Explicit user delegation to approve reviewed roots", "broad_gate3_history" => WITHDRAWAL, "generated_fields_changed" => false },
  "approved_packet" => { "range" => RANGE, "recommendation" => RECOMMENDATION, "review" => REVIEW, "validation" => VALIDATION, "soundness" => SOUNDNESS, "collision_report" => COLLISION, "stress_tests" => STRESS },
  "promoted_roots" => IDS.map do |id|
    record = atoms.fetch(id)
    { "canonical_id" => id, "canonical_title" => record["title"], "invariant_definition" => record["core_definition"], "fixed_generated_fields" => record.slice(*FIXED_FIELDS) }
  end,
  "audit" => { "source_canonical_roots_changed" => false, "previous_review_approved_roots_changed" => false, "canonical_count_after" => canonical_count, "provisional_count_after" => provisional_count, "unreviewed_chunks_after" => remaining_chunks, "future_change_policy" => "explicit versioned migration required", "next_review_packet" => NEXT_RANGE, "next_review_packet_begun" => false, "gate4_started" => false, "translator_implementation_started" => false }
}
write_yaml(MIGRATION, migration)

approval = +"# DAT:200–222 Delegated Semantic Approval\n\nStatus: **APPLIED — NINE ROOTS CANONICAL**\n\n"
approval << "The user supplied standing delegated authority for all remaining semantic batches, with nine-root approval boundaries and a full-family audit after each three batches. This packet challenged five architectures per root, scored 45 candidates across 360 criterion values, routed #{stress.fetch('tests').length} English concepts, passed 17 reusable packet checks, passed all 24 complete Data-family soundness checks, and passed the complete pre-approval regression. `#{RANGE}` is approved as semantic overlay #{OVERLAY_VERSION}.\n\n"
IDS.each { |id| approval << "- `#{id}` — **#{atoms.fetch(id)['title']}**: #{atoms.fetch(id)['core_definition']}\n" }
approval << "\nThe approved layer owns substrate-neutral information-process affordances: internal data transformability within one entity, one source context's transferability relation to one distinct target, and systemic data synchronizability across multiple participants, each separated into persistent, operative, and latent status. It excludes information-entity identity, actual processes, physical carriers, access, permission, integrity, provenance, reference resolution, algorithms, resources, quality, acknowledgment, scheduling, probability, and modality.\n\nNo generated field, source-canonical meaning, or previously reviewed meaning changed. Era Zero now contains **#{canonical_count} canonical roots** and **#{provisional_count} provisional roots in #{remaining_chunks} nine-root chunks**. The broad Gate 3 approval remains withdrawn. `#{NEXT_RANGE}`, Gate 4, and translator implementation were not begun.\n"
EraZeroValidation.write(APPROVAL_RECORD, approval)

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
  - The **#{reviewed_count} roots approved after detailed semantic review** are canonical: `MOV:100–222`, `MAT:000–222`, `MIN:000–222`, `CON:000–222`, `STR:000–222`, `WRN:000–222`, `REP:000–222`, `LOG:000–222`, and `DAT:000–222`.
  - `MOV:100–122` was approved directly by the user. The other twenty-five reviewed packets were approved under the user's explicit delegation.
  - Future changes to any of the #{canonical_count} canonical meanings require an explicit versioned migration.

  `WRN:000–022` is the canonical adverse-condition entity layer:

  - `WRN:000–002` — persistent, manifest, or latent intrinsic faults;
  - `WRN:010–012` — persistent, manifest, or dormant external hazards;
  - `WRN:020–022` — persistent, manifest, or latent correlated distributed faults.

  The persistent member preserves one adverse-condition identity and may co-occur with its manifest or dormant sibling. Manifest and dormant are mutually exclusive for the same condition at one reference time. None silently encodes the bearer, physical mechanism, evidence, belief, warning signal, formal invalidity, severity, probability, attack or propagation process, vulnerability or exposure relation, response, or repair.

  `WRN:100–122` is the canonical adverse-transformation process layer:

  - `WRN:100–102` — completed, active, or nonactualized internally originating degradation;
  - `WRN:110–112` — completed, active, or nonactualized one-source target impairment;
  - `WRN:120–122` — completed, active, or nonactualized correlated systemic propagation.

  The process layer asserts only adverse transformation and its inward, target, or systemic scope. It does not silently encode physical mechanics, diagnosis, evidence, warning messages, containment, response, repair, blame, severity, probability, planning, schedules, or continuing vulnerability/exposure relations. Lexical `1x2` is nonactualized; runtime `[2]/num` remains assertion-level uncertainty.

  `WRN:200–222` is the canonical adverse-affordance layer:

  - `WRN:200–202` — persistent, operative, or latent internal susceptibility;
  - `WRN:210–212` — persistent, operative, or latent source-target exposure;
  - `WRN:220–222` — persistent, operative, or latent systemic propagation pathways.

  Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time. The layer does not silently encode an existing fault or hazard, an actual adverse process, mechanics, evidence, observer knowledge, protection, repair, severity, probability, planning, schedules, or general possibility. Lexical latency remains distinct from runtime `[2]/num` uncertainty.

  `REP:000–022` is the canonical restoration-condition entity layer:

  - `REP:000–002` — persistent, manifest, or dormant internal restoration conditions;
  - `REP:010–012` — persistent, manifest, or dormant target restoration conditions;
  - `REP:020–022` — persistent, manifest, or dormant shared restoration conditions.

  The persistent member preserves one restoration-condition identity and may co-occur with its manifest or dormant sibling. Manifest and dormant are mutually exclusive for the same condition at one reference time. The layer does not silently encode domain-specific health or integrity, absence of fault, a baseline record, an acceptance rule, restoration activity, recoverability, resources, scheduling, or causation. Lexical dormancy remains distinct from runtime `[2]/num` uncertainty.

  `REP:100–122` is the canonical restorative-transformation process layer:

  - `REP:100–102` — completed, active, or nonactualized internally originating restoration;
  - `REP:110–112` — completed, active, or nonactualized one-source target restoration;
  - `REP:120–122` — completed, active, or nonactualized coordinated systemic restoration.

  The process layer moves toward realizing canonical `REP:0xx` restoration conditions. It does not silently encode domain mechanics, generic improvement, maintenance, validation, records or checkpoints, replacement, reconstruction, neutral coordination, resources, recoverability, probability, planning, schedules, or persistence of the result. Lexical `1x2` remains nonactualized and distinct from runtime `[2]/num` uncertainty.

  `REP:200–222` is the canonical restorative-affordance layer:

  - `REP:200–202` — persistent, operative, or latent internal recoverability;
  - `REP:210–212` — persistent, operative, or latent source-target restorative relations;
  - `REP:220–222` — persistent, operative, or latent systemic restoration pathways.

  Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time. The layer does not silently encode a restoration condition, an actual restorative process, physical or domain mechanics, observer evidence, protection, maintenance, service assignment, backup resources, probability, planning, schedules, or generic possibility. Lexical latency remains distinct from runtime `[2]/num` uncertainty.

  `LOG:000–022` is the canonical formal-constraint entity layer:

  - `LOG:000–002` — persistent, operative, or dormant internal formal criteria;
  - `LOG:010–012` — persistent, operative, or dormant target-directed formal constraints;
  - `LOG:020–022` — persistent, operative, or dormant shared formal regimes.

  Persistent rule identity may co-occur with operative or dormant status; operative and dormant are mutually exclusive for the same rule at one reference time. An operative rule limits admissible states but does not entail satisfaction, violation, evaluation, proof, execution, or enforcement. The layer does not silently encode proposition truth, represented data, belief, authority, physical mechanism, applicability, consequence, time, or modality. Lexical dormancy remains distinct from runtime `[2]/num` uncertainty.

  `LOG:100–122` is the canonical formal-evaluation process layer:

  - `LOG:100–102` — completed, active, or nonactualized internal formal evaluations;
  - `LOG:110–112` — completed, active, or nonactualized target constraint applications;
  - `LOG:120–122` — completed, active, or nonactualized systemic regime evaluations.

  The process layer determines admissibility under a separately typed canonical `LOG:0xx` constraint. Its inward column evaluates one entity under an internal criterion; its outward column applies one specified constraint to one distinct target; its systemic column coordinates joint evaluation of multiple participants under one shared regime. Completion entails only that an admissibility result was determined, never acceptance, rejection, truth, correctness, persistence, storage, authority, or enforcement. The layer does not silently encode data, algorithms, cognition, physical change, communication, scheduling, probability, or modality. Lexical `1x2` remains nonactualized and distinct from runtime `[2]/num` uncertainty.

  `LOG:200–222` is the canonical formal-evaluation-affordance layer:

  - `LOG:200–202` — persistent, operative, or latent internal formal evaluability;
  - `LOG:210–212` — persistent, operative, or latent constraint-target applicability;
  - `LOG:220–222` — persistent, operative, or latent systemic joint-evaluability.

  The affordance layer states only typed enablement for the corresponding canonical `LOG:1xx` evaluation. Its inward column concerns one entity under an internal criterion; its outward column preserves one specified constraint and one distinct target; its systemic column requires multiple participants to be jointly evaluable under one shared regime. Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time. The layer does not silently encode decidability or computability guarantees, entailment, consistency, permission, algorithms, resources, data, actual evaluation, results, observer knowledge, time, probability, or unrestricted modality. Lexical latency remains distinct from runtime `[2]/num` uncertainty.

  `DAT:000–022` is the canonical information-entity layer:

  - `DAT:000–002` — persistent, manifest, or dormant internal data;
  - `DAT:010–012` — persistent, manifest, or dormant target references;
  - `DAT:020–022` — persistent, manifest, or dormant shared datasets.

  Persistent information-object identity may co-occur with manifest or dormant status; manifest and dormant are mutually exclusive for the same object at one reference time. An internal datum is maintained within one entity, a target reference denotes one distinct referent, and a shared dataset is one coordinated collection across multiple participants. The layer does not silently encode physical medium, access, observation, belief, truth, transmission, delivery, processing, mutation, provenance, ownership, authority, time, probability, or modality. Lexical dormancy remains distinct from runtime `[2]/num` uncertainty.

  `DAT:100–122` is the canonical information-state process layer:

  - `DAT:100–102` — completed, active, or nonactualized internal data transformations;
  - `DAT:110–112` — completed, active, or nonactualized target data transfers;
  - `DAT:120–122` — completed, active, or nonactualized systemic data synchronizations.

  The process layer changes represented information rather than naming the information entity or its carrier. Its inward column transforms information while it remains within one entity; its outward column transfers bounded information from one source context to one distinct target; its systemic column coordinates information-state alignment across multiple participants under one shared criterion. Completion does not entail fidelity, persistence, acknowledgment, communication uptake, understanding, physical transport, or success under an external rule. The layer does not silently encode codecs, storage media, participant intent, cognition, formal evaluation, creation, restoration, scheduling, probability, or modality. Lexical `1x2` remains nonactualized and distinct from runtime `[2]/num` uncertainty.

  `DAT:200–222` is the canonical information-process-affordance layer:

  - `DAT:200–202` — persistent, operative, or latent internal data transformability;
  - `DAT:210–212` — persistent, operative, or latent source-target data transferability;
  - `DAT:220–222` — persistent, operative, or latent systemic data synchronizability.

  The affordance layer states only typed enablement for the corresponding canonical `DAT:1xx` processes. Its inward column concerns represented information within one entity; its outward column preserves one source context and one distinct target; its systemic column requires multiple participants whose information states can be aligned under one criterion. Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time. The layer does not silently encode access, permission, retrievability, reference resolution, integrity, provenance, consistency, physical carriers, channels, algorithms, resources, actual processing, results, observer knowledge, time, probability, or unrestricted modality. Lexical latency remains distinct from runtime `[2]/num` uncertainty.

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
  Latest selective approval record: `#{MIGRATION}`.
  Withdrawal history: `gate3_withdrawal_record.md`.
MARKDOWN
EraZeroValidation.write("semantic_authority_status.md", status)

roadmap_path = File.join(ROOT, "reports/translator_readiness_roadmap.md")
roadmap = File.read(roadmap_path, encoding: "UTF-8")
roadmap.gsub!("261 canonical roots", "270 canonical roots")
roadmap.gsub!("261 meanings are canonical", "270 meanings are canonical")
roadmap.gsub!("63 meanings remain provisional in 7 nine-root chunks", "54 meanings remain provisional in 6 nine-root chunks")
roadmap.gsub!("261 canonical; 63 provisional", "270 canonical; 54 provisional")
roadmap.gsub!("render only the 261 canonical roots", "render only the 270 canonical roots")
roadmap.gsub!("After approval of `DAT:100–122`:", "After approval of `DAT:200–222` and its full-family audit:")
roadmap.gsub!("`DAT:200–222` is next and has not been begun", "`CRE:000–022` is next and has not been begun")
roadmap.gsub!("the remaining one nine-root layer for DAT, `DAT:200–222`;", "the three nine-root layers for CRE, beginning with `CRE:000–022`;")
EraZeroValidation.write("reports/translator_readiness_roadmap.md", roadmap)

infrastructure_path = File.join(ROOT, "reports/validation_infrastructure.md")
infrastructure = File.read(infrastructure_path, encoding: "UTF-8")
infrastructure.gsub!("twenty-three effective selective-approval migrations and all 225 promoted roots", "twenty-four effective selective-approval migrations and all 234 promoted roots")
infrastructure.gsub!("261-root canonical set and 63-root provisional complement", "270-root canonical set and 54-root provisional complement")
EraZeroValidation.write("reports/validation_infrastructure.md", infrastructure)

puts "Applied #{RANGE} delegated approval: #{canonical_count} canonical / #{provisional_count} provisional."
