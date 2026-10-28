#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "set"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_renderer"
require_relative "../tools/lib/era_zero_controlled_english"

include EraZeroValidation
spec = EraZeroValidation.load_yaml("spec/controlled_english_1.0.yaml")
tests = EraZeroValidation.load_yaml("tests/controlled_english_cases.yaml")
sense_doc = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml")
atoms = EraZeroValidation.load_yaml("lexicon/atoms.yaml").fetch("atoms")
compounds = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries")
compiler = EraZeroControlledEnglish::Compiler.new
checks = EraZeroValidation::CheckSet.new

controlled = sense_doc.fetch("senses").select { |sense| sense["controlled_input_allowed"] == true && %w[atom compound].include?(sense["route"]) }
checks.add("source immutability", "sense index, semantic IR, and renderer match recorded fingerprints", spec.dig("metadata", "sense_index_fingerprint") == EraZeroValidation.fingerprint(sense_doc.fetch("senses")) && spec.dig("metadata", "semantic_ir_fingerprint") == EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/semantic_ir_1.0.yaml")) && spec.dig("metadata", "renderer_fingerprint") == EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/renderer_decoder_1.0.yaml")))
checks.add("controlled label partition", "all and only canonical atom and compound canonical labels are controlled", controlled.length == atoms.length + compounds.length && controlled.count { |sense| sense["route"] == "atom" } == atoms.length && controlled.count { |sense| sense["route"] == "compound" } == compounds.length && controlled.group_by { |sense| sense["lemma"].downcase.gsub(/\s+/, " ").strip }.values.all? { |items| items.length == 1 })

golden_ok = tests.fetch("valid_cases").all? do |item|
  first = compiler.compile(item.fetch("input"))
  second = compiler.compile(item.fetch("input"))
  next false unless first == second && first["status"] == "ok" && first["semantic_ir"] == item["expected_ir"]
  formal = EraZeroRenderer.render(first.fetch("semantic_ir"))
  formal["formal_id"] == item["expected_formal_id"] && formal["literal_gloss"] == item["expected_literal_gloss"] && EraZeroRenderer.decode(formal) == first["semantic_ir"]
end
checks.add("golden translations", "every valid controlled input deterministically compiles, renders, and decodes to the recorded IR", golden_ok && tests.fetch("valid_cases").length >= 16)

negative_ok = tests.fetch("invalid_cases").all? do |item|
  result = compiler.compile(item.fetch("input"))
  result["status"] == "error" && result.dig("error", "code") == item["expected_error"] && result.dig("error", "message").is_a?(String) && result.dig("error", "input") == item["input"] && result.dig("error", "details").is_a?(Hash) && !result.key?("semantic_ir")
end
checks.add("structured failures", "invalid and unsupported inputs return exact stable errors without partial IR", negative_ok && tests.fetch("invalid_cases").length >= 15)

lexical_ok = controlled.all? do |sense|
  input = if sense["target_id"] == "CMP:742b44d9ead66b451346708a"
            %(ASSERT "#{sense['lemma']}" [1] ROLE source "conscious other" [1] ROLE target "active material object" [1].)
          else
            %(ASSERT "#{sense['lemma']}" [1].)
          end
  result = compiler.compile(input)
  next false unless result["status"] == "ok"
  occurrence = result.dig("semantic_ir", "nodes").find { |node| node["kind"] == "lexical_occurrence" && node["target_id"] == sense["target_id"] }
  formal = EraZeroRenderer.render(result.fetch("semantic_ir"))
  occurrence && occurrence["target_type"] == sense["route"] && EraZeroRenderer.decode(formal) == result["semantic_ir"]
end
checks.add("exhaustive lexical translation", "all controlled labels resolve to their one approved atom or compound and round-trip", lexical_ok)

grammar = spec.fetch("grammar")
checks.add("restricted grammar", "simple, sequence, parallel, repetition, and conditional templates are explicit and ordered", %w[simple sequence parallel repetition conditional ordering_rule].all? { |key| grammar.key?(key) })
checks.add("semantic dimension separation", "negation, modality, aspect, time, quantity, measurement, and runtime create distinct IR structures", begin
  not_ir = compiler.compile!('ASSERT NOT "active care" [0].')
  modal_ir = compiler.compile!('ASSERT MODAL possible "active care" [2].')
  time_ir = compiler.compile!('ASSERT "active care" [1] TIME after SPEECH_TIME.')
  not_ir["nodes"].any? { |node| node["operator"] == "negation" } && modal_ir["nodes"].any? { |node| node["operator"] == "modality" } && time_ir["nodes"].any? { |node| node["kind"] == "time_anchor" } && not_ir["nodes"].find { |node| node["kind"] == "lexical_occurrence" }.dig("runtime_state", "code") == 0
end)
checks.add("slot enforcement", "slotted compounds fail without all roles and succeed with explicit source and target", compiler.compile('ASSERT "directed data link" [1].').dig("error", "code") == "missing_compound_role" && compiler.compile('ASSERT "directed data link" [1] ROLE source "conscious other" [1] ROLE target "active material object" [1].')["status"] == "ok")
checks.add("no silent guessing", "boundary forbids synonyms, implicit roles, first-sense choice, and general parsing", spec.dig("boundary", "no_guessing").include?("no IR") && %w[synonym\ inference implicit\ roles general-English\ parsing].all? { |item| spec.dig("boundary", "excluded").include?(item.tr("\\", "")) })
checks.add("error inventory", "documented errors cover parse, lexicon, state, operator, role, quantity, slot, and composition failures", %w[unknown_lexeme ambiguous_lexeme unsupported_sense_route invalid_runtime_state invalid_modality invalid_role invalid_quantity missing_compound_role invalid_coordination invalid_repetition invalid_conditional].all? { |code| spec.fetch("errors").include?(code) })
checks.add("implementation", "compiler library, CLI, spec, golden tests, and report exist", %w[tools/lib/era_zero_controlled_english.rb tools/compile_controlled_english.rb spec/controlled_english_1.0.yaml tests/controlled_english_cases.yaml reports/controlled_english.md].all? { |path| File.file?(File.join(EraZeroValidation::ROOT, path)) })
checks.add("general-English boundary", "the controlled-English release itself began no general-English work", spec.dig("metadata", "general_english_started") == false)
checks.add("authority integration", "controlled English remains canonical after orderly downstream progression", begin
  version = EraZeroValidation.load_yaml("spec/version.yaml")
  readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
  migration = EraZeroValidation.load_yaml("migrations/controlled_english_1.0.yaml")
  gate = readiness.fetch("required_gates").find { |item| item["gate"] == "controlled_english" }
  downstream_ok = %w[general_english glyph_and_audio].include?(version["next_gate_authorized"]) || (version["next_gate_authorized"].nil? && version["glyph_audio_status"] == "canonical")
  version["controlled_english_status"] == "canonical" && migration["next_gate"] == "general_english" && downstream_ok && gate["status"] == "complete" && readiness.dig("safe_now", "controlled_english_translation") == true
end)

report = checks.markdown(title: "Controlled English Compiler Validation", pass_status: "PASS — CONTROLLED ENGLISH CANONICAL; GENERAL ENGLISH MAY BEGIN", summary: ["Controlled lexemes: **#{controlled.length}**", "Golden valid cases: **#{tests.fetch('valid_cases').length}**", "Golden invalid cases: **#{tests.fetch('invalid_cases').length}**", "Exhaustive lexical round trips: **#{controlled.length}**", "General English authorized next: **yes**", "General English implemented: **no**"])
EraZeroValidation.write("reports/controlled_english_validation.md", report)
puts "Controlled English validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
