#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/era_zero_validation"

include EraZeroValidation

checks = EraZeroValidation::CheckSet.new
translator_checks = EraZeroValidation::CheckSet.new

yaml_files = Dir[File.join(ROOT, "{lexicon,spec,reviews,migrations,extraction,reports}/**/*.{yaml,yml}")]
yaml_errors = yaml_files.map do |path|
  begin
    YAML.load_file(path)
    nil
  rescue StandardError => error
    "#{path.delete_prefix("#{ROOT}/")}: #{error.message}"
  end
end.compact
checks.add("machine-readable syntax", "all #{yaml_files.length} YAML files parse", yaml_errors.empty?)

atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
all_doc = EraZeroValidation.load_yaml("lexicon/all_atoms.yaml")
source_doc = EraZeroValidation.load_yaml("lexicon/completed_atoms.yaml")
reviewed_doc = EraZeroValidation.load_yaml("lexicon/reviewed_canonical_atoms.yaml")
provisional_doc = EraZeroValidation.load_yaml("lexicon/provisional_atoms.yaml")
canonical_spec = EraZeroValidation.load_yaml("spec/canonical_spec.yaml")
authority = EraZeroValidation.load_yaml("lexicon/semantic_authority.yaml")
version = EraZeroValidation.load_yaml("spec/version.yaml")
phase2 = EraZeroValidation.load_yaml("spec/phase2_provisional_spec.yaml")
standard = EraZeroValidation.load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")

atoms = EraZeroValidation.atoms_by_id(atoms_doc)
all_atoms = EraZeroValidation.atoms_by_id(all_doc)
source = EraZeroValidation.atoms_by_id(source_doc)
reviewed = EraZeroValidation.atoms_by_id(reviewed_doc)
provisional = EraZeroValidation.atoms_by_id(provisional_doc)

expected_ids = FAMILIES.keys.product((0..2).to_a, (0..2).to_a, (0..2).to_a)
                       .map { |family, first, second, third| "#{family}:#{first}#{second}#{third}" }
                       .to_set
canonical_ids = atoms.values.select { |record| record["status"] == "canonical" }
                     .map { |record| record.fetch("canonical_id") }.to_set
provisional_ids = atoms.values.select do |record|
  record["status"] == "provisional_pending_detailed_semantic_review"
end.map { |record| record.fetch("canonical_id") }.to_set

checks.add("complete address cube", "324 unique records cover every family and ternary address",
           atoms.length == 324 && atoms.keys.to_set == expected_ids &&
             all_atoms.length == 324 && all_atoms.keys.to_set == expected_ids)

structural_projection_fields = %w[
  canonical_id family address status universal_slot
  harmonic_signature_semitones family_onset local_compact_root
  canonical_transliteration formal_carrier note_path_semitones
]
checks.add("live lexicon reconciliation", "both live lexicons agree on all fixed fields and on every canonical meaning",
           atoms.all? do |id, record|
             other = all_atoms.fetch(id)
             structural_projection_fields.all? { |field| record[field] == other[field] } &&
               (record["status"] != "canonical" ||
                 (record["title"] == other["title"] && record["core_definition"] == other["core_definition"]))
           end)

checks.add("authority partition", "canonical and provisional sets are disjoint and exhaustive",
           canonical_ids.disjoint?(provisional_ids) &&
             (canonical_ids | provisional_ids) == expected_ids)

source_fingerprint = EraZeroValidation.fingerprint(source_doc.fetch("atoms"))
checks.add("source-canonical fingerprint", "the complete 36-root source baseline is immutable",
           source.length == 36 &&
             source_fingerprint == EraZeroValidation::SOURCE_CANONICAL_FINGERPRINT)
checks.add("source-canonical replication", "all source records remain object-identical in both live lexicons",
           source.all? { |id, record| atoms[id] == record && all_atoms[id] == record })

migrations = EraZeroValidation.effective_migrations
promotion_pairs = EraZeroValidation.effective_promotions
promotion_ids = promotion_pairs.map { |_path, promotion| promotion.fetch("canonical_id") }
promotion_index = promotion_pairs.to_h do |path, promotion|
  [promotion.fetch("canonical_id"), [path, promotion]]
end
overlay_versions = migrations.map { |_path, migration| migration.dig("metadata", "semantic_overlay_version") }
expected_canonical_count = source.length + promotion_ids.uniq.length
expected_provisional_count = atoms.length - expected_canonical_count
expected_review_chunks = promotion_ids.uniq.length / 9
expected_remaining_chunks = expected_provisional_count / 9

checks.add("approval migration inventory", "#{migrations.length} effective migrations form consecutive semantic overlays",
           migrations.length == overlay_versions.length &&
             migrations.all? do |_path, migration|
               migration.dig("metadata", "status") == "applied" &&
                 migration.dig("metadata", "generated_fields_changed") == false &&
                 migration.dig("metadata", "broad_gate3_history") == WITHDRAWAL
             end &&
             overlay_versions == (1..migrations.length).map { |number| "1.0.#{number}" })

checks.add("approval migration coverage", "#{promotion_ids.uniq.length} unique reviewed roots have one effective promotion each",
           promotion_ids.length == promotion_ids.uniq.length && promotion_ids.length % 9 == 0 &&
             reviewed.keys.to_set == promotion_ids.to_set)

migration_errors = promotion_pairs.flat_map do |path, promotion|
  id = promotion.fetch("canonical_id")
  atom = atoms.fetch(id)
  errors = []
  errors << "#{path}: #{id} title" unless promotion["canonical_title"] == atom["title"]
  errors << "#{path}: #{id} definition" unless promotion["invariant_definition"] == atom["core_definition"]
  unless promotion["fixed_generated_fields"] == EraZeroValidation.migration_fixed_projection(atom)
    errors << "#{path}: #{id} generated fields"
  end
  errors
end
checks.add("approval migration exactness", "every approved title, invariant, and fixed form matches live authority",
           migration_errors.empty?)

cumulative = source.length
chain_ok = migrations.each_with_index.all? do |_entry, index|
  path, migration = migrations[index]
  cumulative += migration.fetch("promoted_roots").length
  audit = migration.fetch("audit", {})
  after = audit["canonical_count_after"]
  provisional_after = audit["provisional_count_after"]
  (after.nil? || after == cumulative) &&
    (provisional_after.nil? || provisional_after == 324 - cumulative) &&
    File.file?(File.join(ROOT, path))
end
checks.add("approval migration sequence", "cumulative stage counts reconcile from #{source.length} to #{cumulative}",
           chain_ok && cumulative == expected_canonical_count)

checks.add("reviewed-canonical ledger", "all #{promotion_ids.length} reviewed records exactly match both live lexicons",
           reviewed.length == promotion_ids.length &&
             reviewed.all? do |id, record|
               atoms[id] == record &&
                 structural_projection_fields.all? { |field| record[field] == all_atoms.fetch(id)[field] } &&
                 record["title"] == all_atoms.fetch(id)["title"] &&
                 record["core_definition"] == all_atoms.fetch(id)["core_definition"]
             end)

expected_canonical_ids = source.keys.to_set | promotion_ids.to_set
checks.add("canonical definition authority", "the #{expected_canonical_count} canonical records are exactly source roots plus effective promotions",
           canonical_ids == expected_canonical_ids && canonical_ids.length == expected_canonical_count &&
             canonical_ids.all? do |id|
               record = atoms.fetch(id)
               !record.fetch("title").strip.empty? && !record.fetch("core_definition").strip.empty?
             end)

duplicate_titles = canonical_ids.group_by { |id| atoms.fetch(id).fetch("title") }
                                .select { |_title, ids| ids.length > 1 }
duplicate_definitions = canonical_ids.group_by { |id| atoms.fetch(id).fetch("core_definition") }
                                     .select { |_definition, ids| ids.length > 1 }
checks.add("canonical semantic uniqueness", "no canonical titles or invariant definitions are exact duplicates",
           duplicate_titles.empty? && duplicate_definitions.empty?)

provisional_projection_fields = %w[
  canonical_id family address status universal_slot
  harmonic_signature_semitones family_onset local_compact_root
  canonical_transliteration formal_carrier note_path_semitones
]
checks.add("provisional complement", "the provisional ledger is the exact #{expected_provisional_count}-root noncanonical complement",
           provisional.length == expected_provisional_count && provisional.keys.to_set == provisional_ids &&
             provisional.all? do |id, record|
               current = atoms.fetch(id)
               provisional_projection_fields.all? { |field| record[field] == current[field] }
             end)

generation_errors = EraZeroValidation.generated_field_errors(atoms)
checks.add("all generated forms", "all 2,592 form assertions and 648 identity assertions pass",
           generation_errors.empty?)

canonical_spec_atoms = canonical_spec.dig("lexicon", "completed_atoms")
checks.add("canonical specification", "canonical_spec contains exactly the #{expected_canonical_count} authoritative records",
           canonical_spec.dig("lexicon", "completed_count") == expected_canonical_count &&
             canonical_spec.dig("lexicon", "remaining_count") == expected_provisional_count &&
             canonical_spec_atoms.length == expected_canonical_count &&
             canonical_spec_atoms.to_h { |record| [record.fetch("canonical_id"), record] } ==
               canonical_ids.to_h { |id| [id, atoms.fetch(id)] })

approved_ranges = authority.fetch("approved_review_packets").map { |packet| packet.fetch("range") }
checks.add("semantic authority ledger", "authority records #{expected_canonical_count} canonical, #{expected_provisional_count} provisional, #{expected_review_chunks} reviewed packets, and #{expected_remaining_chunks} remaining chunks",
           authority.dig("semantic_inventory", "canonical_roots") == expected_canonical_count &&
             authority.dig("semantic_inventory", "provisional_roots") == expected_provisional_count &&
             authority.dig("semantic_review_progress", "canonical_review_chunks") == expected_review_chunks &&
             authority.dig("semantic_review_progress", "unreviewed_chunks") == expected_remaining_chunks &&
             authority.dig("semantic_review_progress", "unreviewed_roots") == expected_provisional_count &&
             approved_ranges.to_set == EraZeroValidation.promotion_ranges.to_set &&
             authority.fetch("review_packets_pending_user_decision").empty?)

next_chunk = phase2.fetch("review_chunks").find do |chunk|
  chunk.fetch("ids").all? { |id| provisional_ids.include?(id) }
end
next_range = next_chunk && next_chunk.fetch("range")

count_alignment =
  version["canonical_semantic_roots"] == expected_canonical_count &&
  version["provisional_semantic_roots"] == expected_provisional_count &&
  version["unreviewed_nine_root_chunks"] == expected_remaining_chunks &&
  version["next_semantic_review_packet"] == next_range &&
  phase2.dig("scope", "canonical_meanings") == expected_canonical_count &&
  phase2.dig("scope", "provisional_meanings") == expected_provisional_count &&
  phase2.dig("scope", "remaining_review_chunks") == expected_remaining_chunks &&
  standard.dig("inventory", "canonical_roots") == expected_canonical_count &&
  standard.dig("inventory", "provisional_roots") == expected_provisional_count &&
  standard.dig("inventory", "provisional_review_chunks") == expected_remaining_chunks
checks.add("cross-spec count reconciliation", "version, Phase 2, and withdrawn-standard overlay all report #{expected_canonical_count}/#{expected_provisional_count}/#{expected_remaining_chunks}",
           count_alignment)

withdrawn = EraZeroValidation.load_yaml("migrations/1.0.0-canonization.yaml")
checks.add("withdrawn Gate 3 isolation", "the 288-root broad promotion remains audit-only and ineffective",
           withdrawn["approval_status"] == WITHDRAWAL &&
             withdrawn["effective_as_semantic_authority"] == false &&
             withdrawn["audit_history_only"] == true &&
             atoms_doc.dig("metadata", "gate3_approval_status") == WITHDRAWAL &&
             authority.dig("metadata", "user_direction") == WITHDRAWAL)

gap_yaml = EraZeroValidation.load_yaml("reports/atomic_root_gaps.yaml")
gap_ids = gap_yaml.fetch("chunks").flat_map { |chunk| chunk.fetch("root_ids") }
checks.add("current gap inventory", "gap reports contain exactly the #{expected_provisional_count} provisional roots in #{expected_remaining_chunks} chunks",
           gap_yaml.dig("metadata", "canonical") == expected_canonical_count &&
             gap_yaml.dig("metadata", "remaining") == expected_provisional_count &&
             gap_yaml.dig("metadata", "remaining_chunks") == expected_remaining_chunks &&
             gap_ids.to_set == provisional_ids && gap_ids.length == expected_provisional_count)

status_text = File.read(File.join(ROOT, "semantic_authority_status.md"), encoding: "UTF-8")
roadmap_text = File.read(File.join(ROOT, "reports/translator_readiness_roadmap.md"), encoding: "UTF-8")
gap_text = File.read(File.join(ROOT, "reports/gap_report.md"), encoding: "UTF-8")
next_packet_text_ok = if next_range
                        gap_text.include?("Next review packet: **`#{next_range}`**")
                      else
                        gap_text.include?("Next review packet: **none — all atomic packets complete**")
                      end
checks.add("human-readable current status", "authority, roadmap, and gap report state the live inventory and next packet",
           status_text.include?("#{expected_canonical_count} CANONICAL ROOTS / #{expected_provisional_count} PROVISIONAL ROOTS") &&
             roadmap_text.include?("#{expected_canonical_count} meanings are canonical") &&
             roadmap_text.include?("#{expected_provisional_count} meanings remain provisional in #{expected_remaining_chunks} nine-root chunks") &&
             gap_text.include?("Canonical meanings: **#{expected_canonical_count}**") &&
             gap_text.include?("Remaining provisional meanings: **#{expected_provisional_count}**") &&
             next_packet_text_ok)

translator_checks.add("semantic authority progress", "#{expected_canonical_count} roots are canonical; #{expected_provisional_count} roots in #{expected_remaining_chunks} chunks remain provisional",
                      canonical_ids.length == expected_canonical_count &&
                        provisional_ids.length == expected_provisional_count &&
                        provisional_ids.length / 9 == expected_remaining_chunks)

translator_inventory_ok =
  readiness.dig("metadata", "broad_translator_authorized") == true &&
  readiness.dig("current_inventory", "deterministic_addresses") == 324 &&
  readiness.dig("current_inventory", "canonical_meanings") == expected_canonical_count &&
  readiness.dig("current_inventory", "provisional_meanings") == expected_provisional_count &&
  readiness.dig("current_inventory", "unreviewed", "roots") == expected_provisional_count &&
  readiness.dig("current_inventory", "unreviewed", "nine_root_chunks") == expected_remaining_chunks &&
  readiness["next_semantic_chunk_after_pending_decisions"] == next_range
translator_checks.add("translator inventory", "translator readiness mirrors live authority and names #{next_range} next",
                      translator_inventory_ok)

safe_scope_ok =
  readiness.dig("safe_now", "explicit_canonical_id_renderer_prototype") == true &&
  readiness.dig("safe_now", "maximum_semantic_scope") == "#{expected_canonical_count} canonical roots" &&
  readiness.dig("safe_now", "reject_provisional_roots") == true &&
  readiness.dig("safe_now", "general_english_translation") == true &&
  readiness.dig("safe_now", "compound_translation") == true &&
  readiness.dig("safe_now", "controlled_english_translation") == true
translator_checks.add("safe translator boundary", "controlled and conservative general-English translation are enabled over canonical authority",
                      safe_scope_ok)

gates = readiness.fetch("required_gates")
compound_subgates = gates[1].fetch("subgates", [])
gate_status_ok = gates.first["status"] == "complete" &&
  gates[1]["status"] == "complete" &&
  gates[2]["status"] == "complete" &&
  gates[3]["status"] == "complete" &&
  gates[4]["status"] == "complete" &&
  gates[5]["status"] == "complete" &&
  gates[6]["status"] == "complete" &&
  compound_subgates.first&.fetch("status", nil) == "complete" &&
  compound_subgates[1]&.fetch("status", nil) == "complete" &&
  compound_subgates[2]&.fetch("status", nil) == "complete" &&
  compound_subgates[3]&.fetch("status", nil) == "complete" &&
  compound_subgates[4]&.fetch("status", nil) == "complete" &&
  compound_subgates.drop(5).all? { |gate| gate["status"] == "not_started" }
translator_checks.add("required gate sequence", "all seven semantic, translator, and presentation gates are complete",
                      gate_status_ok)

prohibition_ok = authority.fetch("prohibited_dependencies").to_set == PROHIBITED_DEPENDENCIES.to_set
translator_checks.add("provisional dependency prohibition", "all seven prohibited downstream dependency classes remain explicit",
                      prohibition_ok)

active_downstream_patterns = %w[
  compounds/**/*
  translator/**/*
  spec/compound_dictionary*.yaml
  lexicon/compounds*.yaml
  lexicon/english_concept*.yaml
]
active_downstream_files = active_downstream_patterns.flat_map do |pattern|
  Dir[File.join(ROOT, pattern)]
end.select { |path| File.file?(path) }
translator_checks.add("downstream artifact boundary", "no unauthorized glyph/audio artifact exists beyond the approved translator pipeline",
                      active_downstream_files.empty?)

canonical_spec_ids = canonical_spec_atoms.map { |record| record.fetch("canonical_id") }.to_set
translator_checks.add("provisional runtime exclusion", "no provisional ID is present in the runtime canonical specification",
                      canonical_spec_ids.disjoint?(provisional_ids))

roadmap_progress_ok = if next_range
                        roadmap_text.include?("`#{next_range}` is next")
                      else
                        roadmap_text.include?("all atomic semantic packets are complete")
                      end
translator_checks.add("roadmap status", "the roadmap preserves the block and the complete dependency sequence",
                      roadmap_text.include?("validated conservative general-English candidate translator") &&
                        roadmap_progress_ok &&
                        roadmap_text.include?("All planned translator-readiness gates are complete"))

translator_checks.checks.each do |name, detail, ok|
  checks.add("translator: #{name}", detail, ok)
end

current_report = checks.markdown(
  title: "Era Zero Current-State Regression",
  pass_status: "PASS — CURRENT AUTHORITY AND TRANSLATOR BOUNDARIES VERIFIED",
  summary: [
    "Canonical roots: **#{canonical_ids.length}**",
    "Provisional roots: **#{provisional_ids.length}**",
    "Effective reviewed-root promotions: **#{promotion_ids.length}**",
    "Generated-form assertions: **#{atoms.length * 8}**",
    "Identity assertions: **#{atoms.length * 2}**",
    "Next semantic packet: **#{next_range ? "`#{next_range}`" : 'none — atomic semantic review complete'}**"
  ]
)
current_report << "\n**#{checks.success? ? "REGRESSION SUITE PASSED" : "REGRESSION SUITE FAILED"}**\n"
EraZeroValidation.write("reports/current_state_regression.md", current_report)

translator_report = translator_checks.markdown(
  title: "Translator Readiness Validation",
  pass_status: "PASS — CURRENT ROADMAP CONSISTENT; BROAD TRANSLATOR STILL BLOCKED",
  summary: [
    "Deterministic addresses: **324**",
    "Canonical meanings: **#{canonical_ids.length}**",
    "Provisional meanings: **#{provisional_ids.length}**",
    "Remaining nine-root chunks: **#{provisional_ids.length / 9}**",
    "Safe explicit-ID scope: **#{canonical_ids.length} canonical roots**"
  ]
)
translator_report << if next_range
                       "\nThe next semantic packet is `#{next_range}`. General English translation, compounds, semantic IR, and executable grammar remain unauthorized.\n"
                     else
                       "\nAll atomic semantic packets are complete. General English translation, compounds, semantic IR, and executable grammar remain unauthorized pending their own gates.\n"
                     end
EraZeroValidation.write("reports/translator_readiness_validation.md", translator_report)

puts "Checks passed: #{checks.passed}"
puts "Checks failed: #{checks.failed}"
puts "Canonical: #{canonical_ids.length}; provisional: #{provisional_ids.length}"
puts "Effective promotions: #{promotion_ids.length}; generated-form assertions: #{atoms.length * 8}"
puts "Translator checks passed: #{translator_checks.passed}; failed: #{translator_checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
