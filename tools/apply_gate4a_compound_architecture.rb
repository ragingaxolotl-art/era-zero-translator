#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

ARCHITECTURE = "spec/compound_architecture_1.0.yaml"
SCHEMA = "spec/compound_graph_schema.yaml"
CASES = "tests/gate4a_compound_cases.yaml"
VALIDATION = "reports/gate4a_validation.md"
MIGRATION = "migrations/gate4a_compound_architecture_1.0.yaml"
APPROVAL = "reports/gate4a_approval_record.md"

raise("Gate 4A migration already exists") if File.exist?(File.join(ROOT, MIGRATION))
validation = File.read(File.join(ROOT, VALIDATION), encoding: "UTF-8")
raise("Gate 4A validation has not passed") unless validation.include?("PASS — GATE 4A ARCHITECTURE CANONICAL; GATE 4B MAY BEGIN") && validation.include?("Checks failed: **0**")

architecture = EraZeroValidation.load_yaml(ARCHITECTURE)
raise("unexpected Gate 4A status") unless architecture.dig("metadata", "status") == "canonical_gate4a_architecture"
raise("dictionary was started") unless architecture.dig("metadata", "compound_dictionary_started") == false
atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
atoms = EraZeroValidation.atoms_by_id(atoms_doc)
raise("atomic inventory is not fully canonical") unless atoms.length == 324 && atoms.values.all? { |atom| atom["status"] == "canonical" }
raise("atomic fingerprint mismatch") unless architecture.dig("metadata", "atomic_lexicon_fingerprint") == EraZeroValidation.fingerprint(atoms_doc.fetch("atoms"))

version = EraZeroValidation.load_yaml("spec/version.yaml")
version["compound_architecture_version"] = "1.0.0"
version["gate4a_status"] = "canonical"
version["last_completed_gate"] = "gate4a_typed_compound_architecture"
version["next_gate_authorized"] = "gate4b_high_frequency_compound_dictionary"
version["compound_dictionary_entries"] = 0
version["compound_architecture"] = ARCHITECTURE
version["compound_graph_schema"] = SCHEMA
EraZeroValidation.write("spec/version.yaml", YAML.dump(version))

readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
readiness["metadata"]["status"] = "blocked_pending_compound_dictionary_and_later_gates"
readiness["metadata"]["compound_architecture_version"] = "1.0.0"
readiness["safe_now"]["compound_schema_validation"] = true
readiness["safe_now"]["compound_definition_authoring"] = true
readiness["safe_now"]["approved_compound_count"] = 0
readiness["safe_now"]["compound_translation"] = false
gates = readiness.fetch("required_gates")
atomic_gate = gates.find { |gate| gate["gate"] == "atomic_semantic_freeze" }
compound_gate = gates.find { |gate| gate["gate"] == "compound_and_coverage" }
atomic_gate["status"] = "complete"
compound_gate["status"] = "in_progress"
compound_gate["subgates"] = [
  { "gate" => "gate4a_typed_compound_architecture", "status" => "complete", "artifact" => ARCHITECTURE },
  { "gate" => "gate4b_high_frequency_compound_dictionary", "status" => "not_started", "entries" => 0 },
  { "gate" => "gate4c_english_concept_and_sense_index", "status" => "not_started" },
  { "gate" => "gate4d_coverage_and_ambiguity_report", "status" => "not_started" },
  { "gate" => "gate4e_etymology_table", "status" => "not_started" }
]
readiness["next_authorized_gate"] = "gate4b_high_frequency_compound_dictionary"
readiness["gate4a"] = {
  "status" => "complete_and_canonical",
  "architecture" => ARCHITECTURE,
  "schema" => SCHEMA,
  "validation" => VALIDATION,
  "conformance_cases" => CASES,
  "dictionary_entries" => 0
}
EraZeroValidation.write("spec/translator_readiness.yaml", YAML.dump(readiness))

canonical = EraZeroValidation.load_yaml("spec/canonical_spec.yaml")
canonical["compound_architecture"] = {
  "status" => "canonical_gate4a_architecture",
  "version" => "1.0.0",
  "specification" => ARCHITECTURE,
  "schema" => SCHEMA,
  "dictionary_entries" => 0,
  "next_gate" => "Gate 4B high-frequency compound dictionary"
}
EraZeroValidation.write("spec/canonical_spec.yaml", YAML.dump(canonical))

standard = EraZeroValidation.load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
standard["metadata"]["gate4a_status"] = "canonical"
standard["metadata"]["compound_architecture_version"] = "1.0.0"
standard["metadata"]["compound_architecture"] = ARCHITECTURE
standard["deferred_post_core_layers"].reject! { |item| item.include?("ORI:000–222") }
standard["deferred_post_core_layers"].map! do |item|
  item == "compound dictionary and English concept coverage" ? "Gate 4B compound dictionary and Gate 4C English concept coverage" : item
end
EraZeroValidation.write("spec/era_zero_core_standard_1.0.0.yaml", YAML.dump(standard))

status_path = File.join(ROOT, "semantic_authority_status.md")
status = File.read(status_path, encoding: "UTF-8")
status.gsub!("- Gate 4, compound architecture, and translator implementation remain deferred.", "- Gate 4A typed compound architecture is canonical.\n- Gate 4B compound dictionary, later compositional gates, and translator implementation remain deferred.")
marker = "\nMachine-readable authority:"
section = <<~MARKDOWN

  ## Gate 4A compound architecture

  Gate 4A is complete and canonical at version **1.0.0**. A lexical compound is a connected acyclic semantic graph with one explicit head, typed modifier or argument edges, deterministic serialization, and versioned change control. The architecture creates no compound meanings: the approved dictionary contains **0 entries**.

  The next authorized task is **Gate 4B: the reviewed high-frequency compound dictionary**. English indexing, semantic IR, executable grammar, rendering, decoding, and translation remain unstarted.
MARKDOWN
status.sub!(marker, "#{section}#{marker}")
EraZeroValidation.write("semantic_authority_status.md", status)

roadmap_path = File.join(ROOT, "reports/translator_readiness_roadmap.md")
roadmap = File.read(roadmap_path, encoding: "UTF-8")
roadmap.gsub!("| Gate 4A | Typed compound architecture | Most ordinary English concepts require multi-root graphs | Not begun |", "| Gate 4A | Typed compound architecture | Most ordinary English concepts require multi-root graphs | **Complete — canonical architecture 1.0.0** |")
roadmap.gsub!("| Gate 4B | Canonical compound dictionary | Supplies stable decompositions for person, tool, food, water, machine, home, program, injury, and other common concepts | Not begun |", "| Gate 4B | Canonical compound dictionary | Supplies stable decompositions for person, tool, food, water, machine, home, program, injury, and other common concepts | **Next — not begun; 0 entries** |")
roadmap.gsub!("Atomic semantic review is complete; compound architecture and executable grammar are now the critical path, but remain outside this goal.", "Atomic semantic review and Gate 4A are complete. Gate 4B compound review is now the critical path; executable grammar and translation remain later gates.")
roadmap.sub!("## Compound architecture required before English mapping", "## Gate 4A compound architecture — complete\n\nThe canonical machine-readable architecture is `spec/compound_architecture_1.0.yaml`; its schema and conformance suite are validated. It defines heads, modifiers, typed roles, scope, nesting, serialization, versioning, and change control while deliberately creating zero dictionary entries.\n\n## Gate 4B compound dictionary required before English mapping")
EraZeroValidation.write("reports/translator_readiness_roadmap.md", roadmap)

artifacts = [ARCHITECTURE, SCHEMA, CASES, VALIDATION].to_h do |path|
  [path, Digest::SHA256.file(File.join(ROOT, path)).hexdigest]
end
migration = {
  "metadata" => { "title" => "Gate 4A typed compound architecture approval", "status" => "applied", "version" => "1.0.0", "authority" => "Direct user request to perform the next gated language-completion stage", "atomic_meanings_changed" => false, "generated_fields_changed" => false },
  "approved_architecture" => { "specification" => ARCHITECTURE, "schema" => SCHEMA, "conformance_cases" => CASES, "validation" => VALIDATION, "artifact_sha256" => artifacts },
  "inventory" => { "canonical_atomic_roots" => 324, "provisional_atomic_roots" => 0, "approved_compound_entries" => 0 },
  "boundary" => { "gate4a_complete" => true, "gate4b_started" => false, "english_index_started" => false, "semantic_ir_started" => false, "grammar_implementation_started" => false, "renderer_started" => false, "translator_started" => false },
  "next_authorized_gate" => "gate4b_high_frequency_compound_dictionary"
}
EraZeroValidation.write(MIGRATION, YAML.dump(migration))

approval = <<~MARKDOWN
  # Gate 4A Typed Compound Architecture Approval

  Status: **APPLIED — ARCHITECTURE 1.0.0 CANONICAL**

  The user requested the next language-completion stage after all 324 atomic roots became canonical. Gate 4A passed 21 architecture checks, 12 valid-graph cases, and 23 invalid-graph diagnostics while preserving the complete atomic fingerprint and all generated forms.

  Gate 4A approves composition structure only: one explicit semantic head, `qualifies`, `fills_role`, and `member_of` edges, typed roles, explicit scope, acyclic nesting, deterministic serialization, content-derived identity, and versioned change control.

  It approves **zero compound meanings**. Gate 4B, the English sense index, semantic IR, executable grammar, renderer, decoder, and translator were not begun.
MARKDOWN
EraZeroValidation.write(APPROVAL, approval)

puts "Applied Gate 4A compound architecture 1.0.0; 324 atoms preserved; 0 dictionary entries; Gate 4B is next."
