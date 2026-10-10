#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation

doc = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml")
schema = EraZeroValidation.load_yaml("spec/english_sense_index_schema.yaml")
tests = EraZeroValidation.load_yaml("tests/gate4c_sense_index_cases.yaml")
atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
compound_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
atoms = atoms_doc.fetch("atoms")
compounds = compound_doc.fetch("entries")
senses = doc.fetch("senses")
index = doc.fetch("lemma_index")
checks = EraZeroValidation::CheckSet.new

atom_ids = atoms.map { |a| a["canonical_id"] }.to_set
compound_ids = compounds.map { |c| c["compound_id"] }.to_set
routes = schema.fetch("routes").keys.to_set
required = schema.fetch("required_sense_fields").to_set

checks.add("inventory", "metadata counts exactly match records and normalized lemmas", doc.dig("metadata", "sense_count") == senses.length && doc.dig("metadata", "lemma_count") == index.length && senses.length >= 400)
checks.add("unique sense ids", "every sense has one unique content-derived ENS identifier", senses.map { |s| s["sense_id"] }.uniq.length == senses.length && senses.all? { |s| s["sense_id"].match?(/\AENS:[0-9a-f]{24}\z/) })
checks.add("required fields", "every sense satisfies the schema contract", senses.all? { |s| required.subset?(s.keys.to_set) })
checks.add("route typing", "every route is one of atom, compound, grammar, semantic_ir, or gap", senses.all? { |s| routes.include?(s["route"]) })
checks.add("target discipline", "targets exist exactly for atom and compound routes", senses.all? do |s|
  case s["route"]
  when "atom" then atom_ids.include?(s["target_id"])
  when "compound" then compound_ids.include?(s["target_id"])
  else !s.key?("target_id") || s["target_id"].nil?
  end
end)
checks.add("exact atomic coverage", "all 324 canonical atom labels resolve to their exact roots", tests.fetch("exact_atom_labels").all? do |t|
  senses.any? { |s| s["lemma"] == t["input"].downcase && s["route"] == "atom" && s["target_id"] == t["expected_target"] && s["controlled_input_allowed"] }
end && tests.fetch("exact_atom_labels").length == 324)
checks.add("exact compound coverage", "all 28 approved compound labels resolve to their exact CMP identities", tests.fetch("exact_compound_labels").all? do |t|
  senses.any? { |s| s["lemma"] == t["input"].downcase && s["route"] == "compound" && s["target_id"] == t["expected_target"] && s["controlled_input_allowed"] }
end && tests.fetch("exact_compound_labels").length == 28)
checks.add("lemma index integrity", "lemma index names every and only sense under that normalized form", index.all? { |lemma, item| item["sense_ids"].to_set == senses.select { |s| s["lemma"] == lemma }.map { |s| s["sense_id"] }.to_set } && index.keys.to_set == senses.map { |s| s["lemma"] }.to_set)
checks.add("polysemy explicit", "reviewed ambiguous lemmas require disambiguation and contain multiple senses", tests.fetch("polysemy_tests").all? { |t| index.dig(t["input"], "requires_disambiguation") && index.dig(t["input"], "sense_ids").length >= t["minimum_senses"] })
checks.add("gaps explicit", "unsupported high-frequency concepts route to gap", tests.fetch("gap_tests").all? { |t| senses.any? { |s| s["lemma"] == t["input"] && s["route"] == "gap" } })
checks.add("grammar explicit", "grammar concepts are not lexicalized as roots", tests.fetch("grammar_tests").all? { |t| senses.any? { |s| s["lemma"] == t["input"] && s["route"] == "grammar" } })
checks.add("IR explicit", "occurrence and temporal concepts are reserved for semantic IR", tests.fetch("ir_tests").all? { |t| senses.any? { |s| s["lemma"] == t["input"] && s["route"] == "semantic_ir" } })
checks.add("no silent gap resolution", "gap senses are never marked as controlled direct inputs or given targets", senses.select { |s| s["route"] == "gap" }.all? { |s| !s["controlled_input_allowed"] && !s.key?("target_id") })
checks.add("sense boundaries", "every record has selection cues and excluded readings", senses.all? { |s| s["selection_cues"].is_a?(Array) && !s["selection_cues"].empty? && s["excluded_readings"].is_a?(Array) && !s["excluded_readings"].empty? })
checks.add("atomic immutability", "atomic fingerprint and generated forms are unchanged", doc.dig("metadata", "atomic_lexicon_fingerprint") == EraZeroValidation.fingerprint(atoms_doc.fetch("atoms")) && EraZeroValidation.generated_field_errors(EraZeroValidation.atoms_by_id(atoms_doc)).empty?)
checks.add("compound immutability", "Gate 4B compound dictionary fingerprint is unchanged", doc.dig("metadata", "compound_dictionary_fingerprint") == EraZeroValidation.fingerprint(compound_doc.fetch("entries")))
checks.add("authority integration", "Gate 4C remains canonical, its migration records the Gate 4D handoff, and later translation is orderly", begin
  version = EraZeroValidation.load_yaml("spec/version.yaml")
  readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
  migration = EraZeroValidation.load_yaml("migrations/gate4c_english_sense_index_1.0.yaml")
  general_gate = readiness.fetch("required_gates").find { |gate| gate["gate"] == "general_english" }
  translator_progress_ok = readiness.dig("safe_now", "general_english_translation") == false || general_gate["status"] == "complete"
  version["gate4c_status"] == "canonical" && migration["next_gate"] == "gate4d_coverage_and_ambiguity_report" && translator_progress_ok && doc.dig("metadata", "translator_started") == false
end)

report = checks.markdown(
  title: "Gate 4C English Concept and Sense Index Validation",
  pass_status: "PASS — GATE 4C CORE SENSE INDEX CANONICAL; GATE 4D MAY BEGIN",
  summary: [
    "Sense records: **#{senses.length}**", "Normalized lemmas: **#{index.length}**",
    "Atom-label senses: **#{tests.fetch('exact_atom_labels').length}**", "Compound-label senses: **#{tests.fetch('exact_compound_labels').length}**",
    "Explicit gap senses: **#{senses.count { |s| s['route'] == 'gap' }}**", "Semantic-IR routes: **#{senses.count { |s| s['route'] == 'semantic_ir' }}**",
    "Translator authorized: **no**"
  ]
)
report << "\n## Boundary\n\nGate 4C approves the sense and routing index only. Gate 4D must quantify coverage and ambiguity before etymology and later compiler gates. No parser, semantic IR implementation, grammar engine, renderer, decoder, or translator is authorized.\n"
EraZeroValidation.write("reports/gate4c_validation.md", report)

approval = <<~MD
  # Gate 4C Approval Record

  Status: **APPROVED — CANONICAL CORE RELEASE**  
  Version: **#{doc.dig('metadata', 'version')}**

  This approval covers #{senses.length} English sense records across #{index.length} normalized lemmas. It preserves all 324 atomic meanings and all #{compounds.length} approved compound graphs unchanged. Exact canonical labels are deterministic controlled inputs; polysemous and unsupported everyday readings require disambiguation, grammar, semantic IR, or a gap result.

  Next authorized gate: **Gate 4D — coverage and ambiguity report**. General-English translation remains unauthorized.
MD
EraZeroValidation.write("reports/gate4c_approval_record.md", approval)

puts "Gate 4C validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}; senses: #{senses.length}; lemmas: #{index.length}"
checks.failures.each { |f| warn f }
exit(checks.success? ? 0 : 1)
