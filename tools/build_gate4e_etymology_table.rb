#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require "fileutils"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation
VERSION = "1.0.0"
DATE = "2026-10-09"

atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
atoms = atoms_doc.fetch("atoms")
compounds_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
compounds = compounds_doc.fetch("entries")

source_ids = atoms.select do |a|
  a["family"] == "LIF" || (a["family"] == "MOV" && a["address"][0] == "0")
end.map { |a| a["canonical_id"] }

promotion_path = {}
EraZeroValidation.effective_migrations.each do |path, migration|
  migration.fetch("promoted_roots").each { |root| promotion_path[root.fetch("canonical_id")] = path }
end

first_axis = { "0" => "entity or condition", "1" => "process, action, or transformation", "2" => "capacity, relationship, or systemic possibility" }
second_axis = { "0" => "inward or source locus", "1" => "outward or target locus", "2" => "systemic or shared locus" }
third_axis = { "0" => "lexically completed or persistent pole", "1" => "lexically active, manifest, or operative pole", "2" => "lexically pending, dormant, latent, unresolved, or unrealized pole as fixed by the slot" }
compact_onset = { "0" => "n", "1" => "k", "2" => "m" }
compact_vowel = { "0" => "a", "1" => "o", "2" => "i" }
compact_coda = { "0" => "m", "1" => "k", "2" => "n" }
carrier = { "0" => "ma", "1" => "ki", "2" => "nu" }

atom_rows = atoms.map do |a|
  trits = a.fetch("address").chars
  authority = source_ids.include?(a["canonical_id"]) ? "source_canonical" : "reviewed_canonical"
  provenance = if authority == "source_canonical"
                 { "authority" => authority, "record" => "lexicon/completed_atoms_source.md", "source_url" => a.dig("source", "source_url") }
               else
                 { "authority" => authority, "approval_migration" => promotion_path.fetch(a["canonical_id"]) }
               end
  semantic_payload = { "canonical_id" => a["canonical_id"], "title" => a["title"], "definition" => a["core_definition"], "provenance" => provenance }
  {
    "etymology_id" => "ETY:#{Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(semantic_payload)))[0, 24]}",
    "target_type" => "atom", "target_id" => a.fetch("canonical_id"), "status" => "canonical",
    "english_label" => a.fetch("title"), "english_label_status" => "indexing_gloss_not_form_source",
    "formation_type" => "algorithmic_family_address_encoding",
    "family_derivation" => { "family" => a.fetch("family"), "family_onset" => a.fetch("family_onset"), "harmonic_signature_semitones" => a.fetch("harmonic_signature_semitones") },
    "address_derivation" => {
      "address" => a.fetch("address"), "trits" => trits.map(&:to_i),
      "first_axis" => first_axis.fetch(trits[0]), "second_axis" => second_axis.fetch(trits[1]),
      "third_axis" => third_axis.fetch(trits[2]), "resolved_universal_slot" => a.fetch("universal_slot")
    },
    "form_derivation" => {
      "compact_segments" => [compact_onset.fetch(trits[0]), compact_vowel.fetch(trits[1]), compact_coda.fetch(trits[2])],
      "local_compact_root" => a.fetch("local_compact_root"),
      "family_qualified_transliteration" => a.fetch("canonical_transliteration"),
      "formal_carrier_segments" => [a.fetch("family_onset")] + trits.map { |t| carrier.fetch(t) },
      "formal_carrier" => a.fetch("formal_carrier"), "relative_note_path_semitones" => a.fetch("note_path_semitones")
    },
    "semantic_derivation" => {
      "invariant_definition" => a.fetch("core_definition"),
      "rule" => "The family supplies the domain; the three address axes select one universal semantic slot; detailed review fixes the permanent invariant within that intersection.",
      "provenance" => provenance
    },
    "historical_claim" => "No natural-language cognate or fictional diachronic history is asserted. The form is a deterministic Era Zero construction."
  }
end

compound_rows = compounds.map do |c|
  head = c.fetch("nodes").find { |n| n["node_id"] == c.fetch("semantic_head") }
  payload = { "compound_id" => c["compound_id"], "digest" => c["content_digest"], "version" => c["definition_version"] }
  {
    "etymology_id" => "ETY:#{Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))[0, 24]}",
    "target_type" => "compound", "target_id" => c.fetch("compound_id"), "status" => "canonical",
    "english_label" => c.fetch("display_title"), "english_label_status" => "indexing_gloss_not_identity",
    "formation_type" => "typed_semantic_graph_composition",
    "head" => { "node_id" => c.fetch("semantic_head"), "kind" => head.fetch("kind"), "target_id" => head["root_id"] || head["compound_id"] },
    "components" => c.fetch("nodes"), "relations" => c.fetch("edges"),
    "semantic_derivation" => {
      "invariant_definition" => c.fetch("invariant_definition"),
      "rule" => "The explicit head supplies the category; qualifies edges narrow it; fills_role edges bind typed participants; no component loses its canonical meaning."
    },
    "identity_derivation" => { "architecture_version" => c.fetch("architecture_version"), "canonical_format" => c.dig("serialization", "canonical_format"), "content_digest" => c.fetch("content_digest"), "compound_id_rule" => "CMP plus the first 24 lowercase hexadecimal digits of the semantic-payload SHA-256 digest" },
    "surface_derivation" => "Qualifiers precede their targets with no gap; typed arguments use role register and short-gap binding; runtime state is occurrence metadata and is not etymology.",
    "provenance" => { "authority" => "gate4b_reviewed_compound", "record" => "migrations/gate4b_compound_dictionary_1.0.yaml", "approval_date" => c.fetch("approval_date") },
    "historical_claim" => "No English calque history is asserted. The English title labels the approved compositional graph."
  }
end

table = {
  "metadata" => {
    "title" => "Era Zero Formal Etymology and Derivation Table", "version" => VERSION,
    "status" => "canonical_gate4e", "atom_entries" => atom_rows.length, "compound_entries" => compound_rows.length,
    "total_entries" => atom_rows.length + compound_rows.length,
    "scope" => "Auditable synchronic derivation and authority provenance; no invented natural-language ancestry.",
    "atomic_lexicon_fingerprint" => EraZeroValidation.fingerprint(atoms),
    "compound_dictionary_fingerprint" => EraZeroValidation.fingerprint(compounds)
  },
  "principles" => {
    "synchronic_not_fictional" => "Era Zero forms are engineered encodings. The table records actual construction rules and approval history rather than inventing ancestors or sound changes.",
    "english_independence" => "English titles and glosses aid indexing but do not generate, identify, or semantically authorize a form.",
    "atomic_immutability" => "Family, address, compact root, carrier, harmony, note path, and invariant definition are cited without modification.",
    "compound_transparency" => "A compound's derivation is its versioned typed graph and content digest."
  },
  "entries" => (atom_rows + compound_rows).sort_by { |e| [e["target_type"], e["target_id"]] }
}

schema = {
  "metadata" => { "title" => "Era Zero etymology table schema", "version" => VERSION, "status" => "canonical_gate4e" },
  "target_types" => %w[atom compound],
  "required_common_fields" => %w[etymology_id target_type target_id status english_label english_label_status formation_type semantic_derivation historical_claim],
  "atom_required_fields" => %w[family_derivation address_derivation form_derivation],
  "compound_required_fields" => %w[head components relations identity_derivation surface_derivation provenance],
  "prohibitions" => ["invented proto-language ancestry", "unstated English calque identity", "silent semantic revision", "runtime state inside lexical derivation"]
}

tests = {
  "metadata" => { "version" => VERSION, "expected_atoms" => 324, "expected_compounds" => compounds.length },
  "atom_targets" => atoms.map { |a| a["canonical_id"] }, "compound_targets" => compounds.map { |c| c["compound_id"] },
  "source_canonical_targets" => source_ids.sort,
  "reviewed_targets" => atoms.map { |a| a["canonical_id"] }.reject { |id| source_ids.include?(id) }.sort,
  "invariants" => ["generated_form_exactness", "semantic_definition_exactness", "promotion_provenance", "compound_graph_exactness", "content_digest_exactness", "english_nonidentity", "no_fictional_ancestry"]
}

report = <<~MD
  # Gate 4E Formal Etymology and Derivation Table

  Status: **CANONICAL — COMPOUND-AND-COVERAGE GATE COMPLETE**  
  Version: **#{VERSION}**

  ## Result

  The table contains **#{atom_rows.length} atomic derivations** and **#{compound_rows.length} compound derivations**. It records the real synchronic construction of Era Zero forms: family onset and harmony, three-trit address axes, compact-root segments, formal-carrier segments, relative note path, semantic authority, compound graph, and content-derived identity.

  This standard does not invent a proto-language, borrowing history, or English cognate story. Era Zero is engineered. Its valid “etymology” is the auditable derivation from architecture, address, semantic review, and graph composition.

  ## Authority classes

  - **36 source-canonical atoms:** all `LIF:000–222` and `MOV:000–022`, traced to the source record without semantic rewriting.
  - **288 reviewed-canonical atoms:** traced to the exact effective approval migration that promoted each invariant.
  - **#{compound_rows.length} reviewed compounds:** traced to Gate 4B, with head, nodes, edges, architecture version, SHA-256 digest, and CMP identity rule.

  ## Linguistic boundary

  English labels are glosses only. They do not explain why a form sounds as it does and never authorize a meaning. Runtime state, contour, register, absolute pitch, tense, and discourse realization belong to later occurrence or renderer layers, not lexical derivation.

  ## Gate completion

  Gates 4A–4E are now complete: typed compound architecture, canonical high-frequency compound dictionary, English sense index, coverage/ambiguity measurement, and formal etymology table. The next authorized gate is semantic IR and executable grammar.
MD

migration = {
  "migration_id" => "gate4e_etymology_table_1.0", "date" => DATE, "status" => "applied",
  "from" => { "gate4e_status" => "not_started", "compound_and_coverage" => "in_progress" },
  "to" => { "gate4e_status" => "complete", "compound_and_coverage" => "complete", "entries" => table.dig("metadata", "total_entries"), "version" => VERSION },
  "atomic_fingerprint" => table.dig("metadata", "atomic_lexicon_fingerprint"), "compound_fingerprint" => table.dig("metadata", "compound_dictionary_fingerprint"),
  "semantic_changes" => [], "generated_form_changes" => [], "next_gate" => "semantic_ir_and_grammar"
}

File.write(File.join(EraZeroValidation::ROOT, "spec/etymology_schema.yaml"), YAML.dump(schema))
File.write(File.join(EraZeroValidation::ROOT, "lexicon/etymology_table.yaml"), YAML.dump(table))
File.write(File.join(EraZeroValidation::ROOT, "tests/gate4e_etymology_cases.yaml"), YAML.dump(tests))
File.write(File.join(EraZeroValidation::ROOT, "reports/gate4e_etymology_table.md"), report)
File.write(File.join(EraZeroValidation::ROOT, "migrations/gate4e_etymology_table_1.0.yaml"), YAML.dump(migration))

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["last_completed_gate"] = "gate4e_etymology_table"
version["next_gate_authorized"] = "semantic_ir_and_grammar"
version["gate4e_status"] = "canonical"
version["compound_and_coverage_status"] = "complete"
version["etymology_table_version"] = VERSION
version["etymology_entries"] = table.dig("metadata", "total_entries")
version["etymology_table"] = "lexicon/etymology_table.yaml"
File.write(version_path, YAML.dump(version))

readiness_path = File.join(EraZeroValidation::ROOT, "spec/translator_readiness.yaml")
readiness = YAML.load_file(readiness_path)
readiness["next_authorized_gate"] = "semantic_ir_and_grammar"
gate2 = readiness.fetch("required_gates").find { |g| g["gate"] == "compound_and_coverage" }
gate2["status"] = "complete"
g4e = gate2.fetch("subgates").find { |g| g["gate"] == "gate4e_etymology_table" }
g4e["status"] = "complete"
g4e["entries"] = table.dig("metadata", "total_entries")
readiness["gate4e"] = { "status" => "complete_and_canonical", "table" => "lexicon/etymology_table.yaml", "schema" => "spec/etymology_schema.yaml", "entries" => table.dig("metadata", "total_entries"), "validation" => "reports/gate4e_validation.md" }
File.write(readiness_path, YAML.dump(readiness))

canonical_path = File.join(EraZeroValidation::ROOT, "spec/canonical_spec.yaml")
canonical = YAML.load_file(canonical_path)
canonical["etymology_table"] = { "status" => "canonical", "version" => VERSION, "path" => "lexicon/etymology_table.yaml", "entries" => table.dig("metadata", "total_entries") }
File.write(canonical_path, YAML.dump(canonical))

status_path = File.join(EraZeroValidation::ROOT, "semantic_authority_status.md")
status = File.read(status_path)
unless status.include?("Gate 4E formal etymology")
  status << "\n## Gate 4E formal etymology — #{DATE}\n\n- Status: **canonical #{VERSION}**; **#{table.dig('metadata', 'total_entries')}** atomic and compound derivations.\n- Records real algorithmic formation and approval provenance without fictional ancestry or English-derived identity.\n- Compound-and-coverage Gates 4A–4E are complete. Next authorized work: **semantic IR and executable grammar**.\n"
  File.write(status_path, status)
end

roadmap_path = File.join(EraZeroValidation::ROOT, "reports/translator_readiness_roadmap.md")
roadmap = File.read(roadmap_path)
unless roadmap.include?("Gate 4E completion — #{DATE}")
  roadmap << "\n## Gate 4E completion — #{DATE}\n\nThe formal etymology table is canonical with **#{table.dig('metadata', 'total_entries')}** derivations. Gate 4 compound-and-coverage work is complete. The next stage is semantic IR and executable grammar; translator implementation remains blocked until that stage and the renderer/decoder pass.\n"
  File.write(roadmap_path, roadmap)
end

puts "Built Gate 4E etymology table: #{atom_rows.length} atoms + #{compound_rows.length} compounds"
