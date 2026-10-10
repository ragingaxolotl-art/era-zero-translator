#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "STR:000–022"
NEXT_RANGE = "STR:100–122"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "STR_000_022"
OVERLAY_VERSION = "1.0.10"
BEFORE = { canonical: 135, provisional: 189, reviewed: 99, chunks: 21 }.freeze
AFTER = { canonical: 144, provisional: 180, reviewed: 108, chunks: 20 }.freeze
RECOMMENDATION = "reviews/#{STEM}_recommended_spec.yaml"
SCORED = "reviews/#{STEM}_scored_candidates.yaml"
STRESS = "reviews/#{STEM}_stress_tests.yaml"
REVIEW = "reviews/#{STEM}_peer_review.md"
VALIDATION = "reviews/#{STEM}_validation.md"
COLLISION = "reviews/#{STEM}_collision_report.md"
SOUNDNESS = "reviews/#{STEM}_soundness_audit.md"
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

validation_text = File.read(File.join(ROOT, VALIDATION), encoding: "UTF-8")
raise("packet validation has not passed") unless validation_text.include?("PASS — READY FOR APPROVAL") && validation_text.include?("Checks failed: **0**")
soundness_text = File.read(File.join(ROOT, SOUNDNESS), encoding: "UTF-8")
raise("Structure soundness has not passed") unless soundness_text.include?("PASS — READY FOR DELEGATED APPROVAL") && soundness_text.include?("Checks failed: **0**")
regression_text = File.read(File.join(ROOT, "reports/current_state_regression.md"), encoding: "UTF-8")
raise("pre-approval regression has not passed") unless regression_text.include?("PASS — CURRENT AUTHORITY AND TRANSLATOR BOUNDARIES VERIFIED") && regression_text.include?("Canonical roots: **135**") && regression_text.include?("Checks failed: **0**")

recommended = load_yaml(RECOMMENDATION)
scored = load_yaml(SCORED)
stress = load_yaml(STRESS)
raise("recommendation is not pending approval") unless recommended.dig("metadata", "status") == "recommended_pending_delegated_approval"
raise("candidate record is not pending approval") unless scored.dig("metadata", "status") == "review_complete_pending_preapproval_validation"
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
    record["semantic_origin"] = "Detailed STR:000–022 structural-loci-and-arrangements winner approved under explicit user delegation."
    record["canonical_version"] = "#{OVERLAY_VERSION}-delegated-semantic-overlay"
    record["review_history"] = { "withdrawn_broad_gate3_promotion" => WITHDRAWAL, "detailed_peer_review" => REVIEW, "scored_candidates" => SCORED, "validation" => VALIDATION, "structural_soundness" => SOUNDNESS, "recommendation" => RECOMMENDATION, "collision_report" => COLLISION, "stress_tests" => STRESS, "delegated_approval_migration" => MIGRATION }
    record["canonization"] = {
      "standard" => "Era Zero Core Architecture 1.0 selective semantic overlay",
      "approval_basis" => "Explicit user delegation after reusable packet validation, structural entity-layer soundness validation, and full authority regression.",
      "meaning_change_from_phase2_proposal" => proposal.fetch("proposed_title") != old["title"] || proposal.fetch("invariant_definition") != old["core_definition"],
      "source_proposal_file" => "lexicon/provisional_atoms.yaml",
      "approval_status" => "USER-DELEGATED APPROVAL — CANONICAL",
      "audit_history_only" => false,
      "downstream_implementation_occurred" => false,
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

overlay_label = "MOV:100–222, MAT:000–222, MIN:000–222, CON:000–222, and STR:000–022"
atoms_doc["metadata"]["semantic_authority_status"] = "mixed_#{canonical_count}_canonical_#{provisional_count}_provisional"
atoms_doc["metadata"]["canonical_semantic_roots"] = canonical_count
atoms_doc["metadata"]["provisional_semantic_roots"] = provisional_count
atoms_doc["metadata"]["selective_review_approval_status"] = "#{overlay_label} canonical through detailed selective approvals"
all_doc["metadata"]["canonical_count"] = canonical_count
all_doc["metadata"]["provisional_count"] = provisional_count
all_doc["metadata"]["semantic_status"] = "mixed_#{canonical_count}_canonical_and_#{provisional_count}_provisional"
all_doc["metadata"]["selective_review_approval_status"] = "Twelve reviewed nine-root packets canonical"

provisional_doc["atoms"].reject! { |record| IDS.include?(record["canonical_id"]) }
provisional_doc["metadata"]["title"] = "Era Zero #{provisional_count} generated addresses — provisional semantic candidates"
provisional_doc["metadata"]["count"] = provisional_count
provisional_doc["metadata"]["canonical_baseline_count"] = canonical_count
provisional_doc["metadata"]["approved_removed_ranges"] = %w[MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122 MAT:200–222 MIN:000–022 MIN:100–122 MIN:200–222 CON:000–022 CON:100–122 CON:200–222 STR:000–022]
raise("provisional complement mismatch") unless provisional_doc["atoms"].length == provisional_count
write_yaml("lexicon/atoms.yaml", atoms_doc)
write_yaml("lexicon/all_atoms.yaml", all_doc)
write_yaml("lexicon/provisional_atoms.yaml", provisional_doc)

order = atoms_doc.fetch("atoms").each_with_index.to_h { |record, index| [record["canonical_id"], index] }
reviewed_ids = reviewed_doc.fetch("atoms").map { |record| record["canonical_id"] }.to_set
IDS.each { |id| reviewed_doc["atoms"] << atoms.fetch(id) unless reviewed_ids.include?(id) }
reviewed_doc["atoms"].sort_by! { |record| order.fetch(record["canonical_id"]) }
reviewed_doc["metadata"]["count"] = reviewed_count
reviewed_doc["metadata"]["ranges"] = %w[MOV:100–122 MOV:200–222 MAT:000–022 MAT:100–122 MAT:200–222 MIN:000–022 MIN:100–122 MIN:200–222 CON:000–022 CON:100–122 CON:200–222 STR:000–022]
reviewed_doc["metadata"]["semantic_overlay_version"] = OVERLAY_VERSION
reviewed_doc["metadata"]["latest_approval_record"] = MIGRATION
write_yaml("lexicon/reviewed_canonical_atoms.yaml", reviewed_doc)

authority = load_yaml("lexicon/semantic_authority.yaml")
raise("approval already recorded") if authority.fetch("approved_review_packets").any? { |packet| packet["range"] == RANGE }
authority["metadata"]["current_status"] = "#{canonical_count} canonical roots; #{provisional_count} provisional roots; no completed review packet awaiting decision"
authority["metadata"]["selective_review_approval"] = "#{overlay_label} canonical through detailed selective approvals"
authority["metadata"]["last_review_update"] = "2026-08-03"
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
authority["semantic_review_progress"] = { "canonical_review_chunks" => 12, "reviewed_pending_decision_chunks" => 0, "unreviewed_chunks" => remaining_chunks, "reviewed_pending_decision_roots" => 0, "unreviewed_roots" => provisional_count }
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
canonical["lexicon"]["canonical_sources"] = { "source_developed_36" => "lexicon/completed_atoms.yaml", "review_approved_108" => "lexicon/reviewed_canonical_atoms.yaml" }
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
standard["metadata"]["approval_scope"] = "Architecture, 36 source-developed roots, and 108 roots canonized after detailed review"
standard["metadata"]["review_progress"] = "Twelve nine-root review packets canonical; #{NEXT_RANGE} is next and not begun"
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
standard["deferred_post_core_layers"].map! { |item| item.include?("STR:000–222") ? item.gsub("STR:000–222", "STR:100–222") : item }
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

approval = +"# STR:000–022 Delegated Semantic Approval\n\nStatus: **APPLIED — NINE ROOTS CANONICAL**\n\n"
approval << "The user delegated authority to approve reviewed roots and requested the next block. The packet compared five architectures per root, scored 45 candidates across 360 criterion values, routed #{stress.fetch('tests').length} English concepts, passed 17 reusable packet checks, passed 18 structural soundness checks, and passed the complete pre-approval authority regression. `#{RANGE}` is approved as semantic overlay #{OVERLAY_VERSION}.\n\n"
IDS.each { |id| approval << "- `#{id}` — **#{atoms.fetch(id)['title']}**: #{atoms.fetch(id)['core_definition']}\n" }
approval << "\nThe approved layer owns substrate-neutral constituent positions, outward structural interfaces, and composite part–whole arrangements. It excludes occupants, matter, coordinates, functions, rules, records, construction processes, support/containment relations, institutions, and plans.\n\nNo generated field, source-canonical meaning, or previously reviewed meaning changed. Era Zero now contains **#{canonical_count} canonical roots** and **#{provisional_count} provisional roots in #{remaining_chunks} nine-root chunks**. The broad Gate 3 approval remains withdrawn. `#{NEXT_RANGE}`, Gate 4, and translator implementation were not begun.\n"
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
  - The **#{reviewed_count} roots approved after detailed semantic review** are canonical: `MOV:100–222`, `MAT:000–222`, `MIN:000–222`, `CON:000–222`, and `STR:000–022`.
  - `MOV:100–122` was approved directly by the user. The other eleven reviewed packets were approved under the user's explicit delegation.
  - Future changes to any of the #{canonical_count} canonical meanings require an explicit versioned migration.

  `STR:000–022` is the canonical structural entity/condition layer:

  - `STR:000–002` — persistent, occupied, or vacant constituent positions;
  - `STR:010–012` — persistent, engaged, or unengaged structural interfaces;
  - `STR:020–022` — persistent, instantiated, or dormant composite arrangements.

  A structural position is not its occupant; an interface is not a communication endpoint or attachment relation; and an arrangement is not a blueprint, institution, function, or construction process. Vacancy, disengagement, and dormancy do not imply damage, reservation, planning, or future use.

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
roadmap.gsub!("135 canonical roots", "144 canonical roots")
roadmap.gsub!("135 meanings are canonical", "144 meanings are canonical")
roadmap.gsub!("189 meanings remain provisional in 21 nine-root chunks", "180 meanings remain provisional in 20 nine-root chunks")
roadmap.gsub!("135 canonical; 189 provisional", "144 canonical; 180 provisional")
roadmap.gsub!("the 135 explicit canonical IDs", "the 144 explicit canonical IDs")
roadmap.gsub!("render only the 135 canonical roots", "render only the 144 canonical roots")
roadmap.gsub!("After approval of `CON:200–222`:", "After approval of `STR:000–022`:")
roadmap.gsub!("`STR:000–022` is next and has not been begun", "`STR:100–122` is next and has not been begun")
roadmap.gsub!("1. the three nine-root layers for STR, WRN, REP, LOG, DAT, CRE, and ORI, beginning with `STR:000–022`.", "1. the two remaining nine-root layers for STR, beginning with `STR:100–122`;\n2. the three nine-root layers for WRN, REP, LOG, DAT, CRE, and ORI.")
EraZeroValidation.write("reports/translator_readiness_roadmap.md", roadmap)

infrastructure_path = File.join(ROOT, "reports/validation_infrastructure.md")
infrastructure = File.read(infrastructure_path, encoding: "UTF-8")
infrastructure.gsub!("nine effective selective-approval migrations and all 99 promoted roots", "ten effective selective-approval migrations and all 108 promoted roots")
infrastructure.gsub!("135-root canonical set and 189-root provisional complement", "144-root canonical set and 180-root provisional complement")
EraZeroValidation.write("reports/validation_infrastructure.md", infrastructure)

puts "Applied #{RANGE} delegated approval: #{canonical_count} canonical / #{provisional_count} provisional."
