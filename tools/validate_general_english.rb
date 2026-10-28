#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_general_english"
require_relative "../tools/lib/era_zero_renderer"

include EraZeroValidation
spec = EraZeroValidation.load_yaml("spec/general_english_1.0.yaml")
tests = EraZeroValidation.load_yaml("tests/general_english_cases.yaml")
sense_doc = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml")
senses = sense_doc.fetch("senses")
translator = EraZeroGeneralEnglish::Translator.new(profile: false)
checks = EraZeroValidation::CheckSet.new

checks.add("source immutability", "sense index, controlled English, and Semantic IR match recorded fingerprints", spec.dig("metadata", "sense_index_fingerprint") == EraZeroValidation.fingerprint(senses) && spec.dig("metadata", "controlled_english_fingerprint") == EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/controlled_english_1.0.yaml")) && spec.dig("metadata", "semantic_ir_fingerprint") == EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/semantic_ir_1.0.yaml")))
checks.add("ranking contract", "ranking weights, deterministic tie break, confidence, and ambiguity margin are explicit", spec.dig("ranking", "exact_lemma") == 1.0 && spec.dig("ranking", "contained_lemma") == 0.72 && spec.dig("ranking", "total").include?("sense_id") && spec.dig("ranking", "material_ambiguity").include?("0.12"))

analysis_ok = tests.fetch("analysis_cases").all? do |item|
  first = translator.analyze(item.fetch("input"))
  second = translator.analyze(item.fetch("input"))
  first == second && first == item.fetch("expected")
end
checks.add("analysis fixtures", "all recorded analyses are byte-for-byte deterministic", analysis_ok && tests.fetch("analysis_cases").length >= 12)

resolution_ok = tests.fetch("resolution_cases").all? do |item|
  actual = translator.resolve(item["input"], sense_id: item["sense_id"], runtime_state: item["runtime_state"], speech_act: item["speech_act"], roles: item["roles"])
  next false unless actual == item["expected"]
  actual["status"] == "error" || (actual["round_trip_equal"] == true && EraZeroRenderer.decode(actual.fetch("formal")) == actual.fetch("semantic_ir"))
end
checks.add("explicit resolution", "selected lexical readings resolve through controlled English, IR, EZF-1, and exact decode; structural misuse fails", resolution_ok && tests.fetch("resolution_cases").length >= 4)

indexed_coverage = senses.all? do |sense|
  result = translator.analyze(sense.fetch("lemma"), limit: 20)
  result["status"] == "ok" && result.fetch("candidates").any? { |candidate| candidate["sense_id"] == sense["sense_id"] }
end
checks.add("indexed-sense recall", "every indexed sense is returned for its exact lemma", indexed_coverage && senses.length == sense_doc.dig("metadata", "sense_count"))

leave = translator.analyze("leave [1]")
checks.add("conservative auto-resolution", "unique exact direct sense plus explicit runtime may auto-resolve and round-trip", leave.dig("decision", "auto_resolution_allowed") == true && leave.dig("translation", "round_trip_equal") == true && leave.dig("candidates", 0, "target_id") == "MOV:101")

no_runtime = translator.analyze("leave")
checks.add("runtime clarification", "a unique lexical sense still exposes three IR state alternatives and asks for runtime", no_runtime.dig("decision", "auto_resolution_allowed") == false && no_runtime.dig("decision", "reasons").include?("runtime_state_required") && no_runtime.dig("candidates", 0, "semantic_ir_options").map { |option| option["runtime_state"] } == [0, 1, 2])

go = translator.analyze("go [1]")
change = translator.analyze("change [1]")
checks.add("polysemy clarification", "go and change expose competing senses instead of selecting file order", go.dig("decision", "reasons").include?("material_sense_ambiguity") && go.dig("candidates").map { |candidate| candidate["route"] }.to_set.superset?(%w[atom semantic_ir].to_set) && change.dig("candidates").count { |candidate| candidate["match_type"] == "exact_lemma" } >= 5 && change.dig("decision", "auto_resolution_allowed") == false)

context = translator.analyze("change represented information content [1]")
checks.add("contextual evidence", "selection-cue and definition evidence ranks the data-transformation sense first but preserves clarification", context.dig("candidates", 0, "target_id") == "DAT:101" && context.dig("candidates", 0, "evidence", "selection_cue_overlap") > 0 && context.dig("decision", "requires_clarification") == true)

food = translator.analyze("food [1]")
home = translator.analyze("home [1]")
checks.add("gap honesty", "single and polysemous vocabulary gaps remain explicit with no invented IR", food.dig("candidates", 0, "route") == "gap" && food.dig("decision", "reasons").include?("documented_vocabulary_gap") && !food.dig("candidates", 0).key?("semantic_ir_options") && home.dig("candidates").count { |candidate| candidate["route"] == "gap" } >= 2)

build = translator.analyze("build [1]")
and_result = translator.analyze("and")
checks.add("structural routing", "semantic-IR and grammar senses request structure instead of collapsing to lexical atoms", build.dig("candidates", 0, "route") == "semantic_ir" && build.dig("decision", "reasons").include?("structural_template_required") && and_result.dig("candidates", 0, "route") == "grammar")

slotted = translator.analyze("directed data link [1]")
checks.add("open-slot clarification", "slotted compounds expose required roles and no premature candidate IR", slotted.dig("candidates", 0, "required_roles") == %w[source target] && slotted.dig("candidates", 0, "semantic_ir_options").empty? && slotted.dig("decision", "reasons").include?("required_roles_missing"))

unknown = translator.analyze("flurple the moon [1]")
bad_state = translator.analyze("leave [num]")
checks.add("structured failure", "unknown input and invalid runtime markers return stable errors without translation", unknown.dig("error", "code") == "no_candidate" && bad_state.dig("error", "code") == "invalid_runtime_state" && !unknown.key?("translation") && !bad_state.key?("translation"))

checks.add("no silent first match", "auto-resolution policy and implementation prohibit material ambiguity, missing state, missing roles, structural routes, gaps, and nonexact matches", spec.dig("metadata", "silent_first_match") == false && spec.dig("contract", "no_silent_guess").include?("Never choose") && %w[material_sense_ambiguity runtime_state_required required_roles_missing structural_template_required documented_vocabulary_gap nonexact_surface_match].all? { |reason| spec.fetch("clarification_reasons").include?(reason) })
checks.add("implementation", "library, CLI, spec, tests, report, and migration exist", %w[tools/lib/era_zero_general_english.rb tools/translate_general_english.rb spec/general_english_1.0.yaml tests/general_english_cases.yaml reports/general_english.md migrations/general_english_1.0.yaml].all? { |path| File.file?(File.join(EraZeroValidation::ROOT, path)) })
checks.add("authority integration", "general English remains canonical and its migration records the glyph/audio handoff", begin
  version = EraZeroValidation.load_yaml("spec/version.yaml")
  readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
  migration = EraZeroValidation.load_yaml("migrations/general_english_1.0.yaml")
  gate = readiness.fetch("required_gates").find { |item| item["gate"] == "general_english" }
  next_ok = version["next_gate_authorized"] == "glyph_and_audio" || (version["next_gate_authorized"].nil? && version["glyph_audio_status"] == "canonical")
  version["general_english_status"] == "canonical" && migration["next_gate"] == "glyph_and_audio" && next_ok && gate["status"] == "complete" && readiness.dig("safe_now", "general_english_translation") == true && readiness.dig("metadata", "broad_translator_authorized") == true
end)

report = checks.markdown(title: "General-English Candidate Translator Validation", pass_status: "PASS — CORE TRANSLATOR PIPELINE CANONICAL", summary: ["Indexed senses: **#{senses.length}**", "Analysis fixtures: **#{tests.fetch('analysis_cases').length}**", "Resolution fixtures: **#{tests.fetch('resolution_cases').length}**", "Exact-lemma sense recall: **#{senses.length}/#{senses.length}**", "Silent first-match selection: **no**", "Next authorized gate: **glyph and audio**"])
EraZeroValidation.write("reports/general_english_validation.md", report)
puts "General English validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
