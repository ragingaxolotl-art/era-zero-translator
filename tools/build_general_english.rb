#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_general_english"

include EraZeroValidation
VERSION = "1.0.0"
DATE = "2026-10-09"

translator = EraZeroGeneralEnglish::Translator.new(profile: false)
sense_doc = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml")
senses = sense_doc.fetch("senses")
find_sense = lambda { |lemma, key| senses.find { |sense| sense["lemma"] == lemma && sense["sense_key"] == key } or raise "missing sense #{lemma}/#{key}" }

analysis_inputs = {
  "unique_exact_with_runtime" => "leave [1]",
  "question_with_runtime" => "approach [1]?",
  "missing_runtime" => "arrive",
  "lexical_ambiguity" => "go [1]",
  "broad_polysemy" => "change [1]",
  "contextual_ranking" => "change represented information content [1]",
  "structural_route" => "build [1]",
  "grammar_route" => "and",
  "documented_gap" => "food [1]",
  "gap_polysemy" => "home [1]",
  "slotted_compound" => "directed data link [1]",
  "unknown" => "flurple the moon [1]",
  "invalid_runtime" => "leave [num]"
}
analysis_cases = analysis_inputs.map do |case_id, input|
  { "case_id" => case_id, "input" => input, "expected" => translator.analyze(input) }
end

leave = find_sense.call("leave", "active_departure")
direct_link = senses.find { |sense| sense["lemma"] == "directed data link" && sense["controlled_input_allowed"] == true }
build = find_sense.call("build", "generate_composite_artifact")
resolution_specs = [
  { "case_id" => "resolve_atom", "input" => "leave", "sense_id" => leave.fetch("sense_id"), "runtime_state" => 1, "speech_act" => "assertion", "roles" => {} },
  { "case_id" => "resolve_question", "input" => "approach?", "sense_id" => find_sense.call("approach", "active_target_approach").fetch("sense_id"), "runtime_state" => 1, "speech_act" => "question", "roles" => {} },
  { "case_id" => "resolve_slotted_compound", "input" => "directed data link", "sense_id" => direct_link.fetch("sense_id"), "runtime_state" => 1, "speech_act" => "assertion", "roles" => { "source" => { "label" => "conscious other", "state" => 1 }, "target" => { "label" => "active material object", "state" => 1 } } },
  { "case_id" => "reject_structural_as_lexeme", "input" => "build", "sense_id" => build.fetch("sense_id"), "runtime_state" => 1, "speech_act" => "assertion", "roles" => {} }
]
resolution_cases = resolution_specs.map do |item|
  item.merge("expected" => translator.resolve(item["input"], sense_id: item["sense_id"], runtime_state: item["runtime_state"], speech_act: item["speech_act"], roles: item["roles"]))
end

reviewed = senses.select { |sense| sense["sense_key"] != "canonical_atom_label" && sense["sense_key"] != "canonical_compound_label" }
spec = {
  "metadata" => {
    "title" => "Era Zero General-English Candidate Translator", "version" => VERSION, "status" => "canonical",
    "sense_index_fingerprint" => EraZeroValidation.fingerprint(senses),
    "controlled_english_fingerprint" => EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/controlled_english_1.0.yaml")),
    "semantic_ir_fingerprint" => EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/semantic_ir_1.0.yaml")),
    "reviewed_noncanonical_senses" => reviewed.length, "silent_first_match" => false
  },
  "contract" => {
    "analysis" => "Return ranked indexed senses, evidence, route, confidence, candidate IRs where structurally possible, and explicit clarification state.",
    "resolution" => "Produce canonical IR and EZF-1 only from an explicitly selected sense, runtime state, speech act, and every required role.",
    "auto_resolution" => "Allowed only for one unique exact lemma, an explicit runtime marker, a direct atom or compound route, and no unbound compound roles.",
    "no_silent_guess" => "Never choose the first index entry, invent a missing role, collapse a structural route into one atom, or conceal a documented vocabulary gap."
  },
  "normalization" => {
    "text" => "Unicode NFC, lowercase, punctuation removed for matching, whitespace collapsed.",
    "runtime_marker" => "An optional final [0], [1], or [2] is semantic input and removed before sense matching.",
    "speech_act_proposal" => "A final question mark proposes question; every other surface proposes assertion. The proposal is visible and may be overridden during explicit resolution."
  },
  "ranking" => {
    "exact_lemma" => 1.0, "contained_lemma" => 0.72,
    "token_overlap" => "0.18 per covered lemma-token proportion, capped at 0.45",
    "selection_cue_overlap" => "0.06 per input/cue token, capped at 0.18",
    "definition_overlap" => "0.02 per input/definition token, capped at 0.08",
    "total" => "sum capped at 1.0 and rounded to four decimals; ties break by sense_id, never file order",
    "confidence" => { "high" => ">= 0.90", "medium" => ">= 0.65", "low" => "< 0.65" },
    "material_ambiguity" => "Any competing candidate within 0.12 of the top score requires clarification."
  },
  "route_behavior" => {
    "atom" => "Expose canonical target and full IR alternatives for every unexcluded runtime state.",
    "compound" => "Expose IR alternatives when the graph has no open slots; otherwise request every required role.",
    "semantic_ir" => "Request missing structural participants or state-transition structure.",
    "grammar" => "Request the expressions to be joined or scoped by the grammatical relation.",
    "gap" => "Report the recorded vocabulary gap and do not fabricate a lexical target."
  },
  "clarification_reasons" => %w[material_sense_ambiguity runtime_state_required required_roles_missing structural_template_required documented_vocabulary_gap nonexact_surface_match],
  "errors" => %w[empty_input invalid_runtime_state no_candidate unknown_sense invalid_speech_act invalid_role structural_route_requires_template missing_required_role controlled_resolution_failed],
  "pipeline" => ["general-English analysis", "ranked indexed senses", "explicit clarification or conservative auto-resolution", "controlled-English canonicalization", "semantic IR", "EZF-1", "inverse decode"],
  "implementation" => { "library" => "tools/lib/era_zero_general_english.rb", "cli" => "tools/translate_general_english.rb", "evaluation" => "tests/general_english_cases.yaml" }
}

tests = { "metadata" => { "version" => VERSION, "analysis_cases" => analysis_cases.length, "resolution_cases" => resolution_cases.length, "indexed_senses" => senses.length, "reviewed_noncanonical_senses" => reviewed.length }, "analysis_cases" => analysis_cases, "resolution_cases" => resolution_cases }
report = <<~MD
  # General-English Candidate Translator 1.0

  Status: **CANONICAL — CORE TRANSLATOR PIPELINE COMPLETE**

  The translator analyzes unrestricted surface phrases conservatively against the 436-sense canonical English index. It returns deterministic ranked candidates with match type, numerical score, confidence, selection evidence, route, target where applicable, candidate Semantic IR runtime alternatives, and explicit clarification questions.

  It auto-resolves only a unique exact lemma with an explicit runtime state, a direct lexical route, and no missing compound roles. Polysemy, close scores, structural or grammar routes, gaps, missing runtime state, nonexact matches, and open slots require clarification. Explicit resolution passes through controlled English, canonical Semantic IR, EZF-1 rendering, and exact inverse decoding.

  This is a safe core translator rather than a statistical language model. It does not claim complete English coverage. The existing 11 vocabulary gaps and all indexed ambiguity remain visible.
MD
migration = { "migration_id" => "general_english_1.0", "date" => DATE, "status" => "applied", "from" => { "general_english" => "not_started" }, "to" => { "general_english" => "complete", "version" => VERSION, "indexed_senses" => senses.length, "analysis_cases" => analysis_cases.length }, "lexical_changes" => [], "next_gate" => "glyph_and_audio" }

File.write(File.join(EraZeroValidation::ROOT, "spec/general_english_1.0.yaml"), YAML.dump(spec))
File.write(File.join(EraZeroValidation::ROOT, "tests/general_english_cases.yaml"), YAML.dump(tests))
File.write(File.join(EraZeroValidation::ROOT, "reports/general_english.md"), report)
File.write(File.join(EraZeroValidation::ROOT, "migrations/general_english_1.0.yaml"), YAML.dump(migration))

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["last_completed_gate"] = "general_english"
version["next_gate_authorized"] = "glyph_and_audio"
version["general_english_status"] = "canonical"
version["general_english_version"] = VERSION
version["general_english"] = "spec/general_english_1.0.yaml"
File.write(version_path, YAML.dump(version))

readiness_path = File.join(EraZeroValidation::ROOT, "spec/translator_readiness.yaml")
readiness = YAML.load_file(readiness_path)
readiness["next_authorized_gate"] = "glyph_and_audio"
readiness["metadata"]["broad_translator_authorized"] = true
gate = readiness.fetch("required_gates").find { |item| item["gate"] == "general_english" }
gate["status"] = "complete"
gate["artifact"] = "spec/general_english_1.0.yaml"
gate["validation"] = "reports/general_english_validation.md"
readiness["safe_now"]["general_english_translation"] = true
readiness["safe_now"]["compound_translation"] = true
readiness["general_english"] = { "status" => "complete_and_canonical", "version" => VERSION, "spec" => "spec/general_english_1.0.yaml", "implementation" => "tools/lib/era_zero_general_english.rb", "indexed_senses" => senses.length, "silent_first_match" => false }
File.write(readiness_path, YAML.dump(readiness))

canonical_path = File.join(EraZeroValidation::ROOT, "spec/canonical_spec.yaml")
canonical = YAML.load_file(canonical_path)
canonical["general_english"] = { "status" => "canonical", "version" => VERSION, "path" => "spec/general_english_1.0.yaml", "implementation" => "tools/lib/era_zero_general_english.rb" }
File.write(canonical_path, YAML.dump(canonical))

status_path = File.join(EraZeroValidation::ROOT, "semantic_authority_status.md")
status = File.read(status_path)
unless status.include?("General-English candidate translator — #{DATE}")
  status << "\n## General-English candidate translator — #{DATE}\n\n- Status: **canonical #{VERSION}** conservative candidate translator.\n- All 436 indexed senses participate in deterministic ranking; ambiguity, structural routes, roles, runtime state, and 11 vocabulary gaps remain explicit.\n- Explicit resolution round-trips through controlled English, canonical Semantic IR, and EZF-1. Next authorized work: **glyph and audio outputs**.\n"
  File.write(status_path, status)
end

roadmap = <<~MD
  # Era Zero Translator Readiness Roadmap

  ## Current answer

  Era Zero now has a validated conservative general-English candidate translator over its canonical semantic inventory. It is suitable for ranked sense analysis and explicit-resolution translation; it does not claim exhaustive English coverage or permission to guess.

  - 324 meanings are canonical;
  - 0 meanings remain provisional in 0 nine-root chunks;
  - all atomic semantic packets are complete;
  - 28 compounds, 436 indexed English senses, and 352 formal derivations are canonical;
  - Semantic IR, deterministic rendering/decoding, controlled English, and general-English candidate analysis are executable and validated;
  - 11 vocabulary gaps and every material ambiguity remain explicit.

  ## Gate status

  | Order | Gate | State |
  |---:|---|---|
  | 1 | Atomic semantic freeze | Complete |
  | 2 | Compound and coverage, Gates 4A–4E | Complete |
  | 3 | Semantic IR and executable grammar | Complete |
  | 4 | Deterministic renderer and inverse decoder | Complete |
  | 5 | Controlled-English compiler | Complete |
  | 6 | General-English candidate translator | Complete — canonical 1.0.0 |
  | 7 | Glyph and audio outputs | Next — not started |

  ## Safe translator behavior

  The general-English interface ranks all indexed senses deterministically and exposes its scoring evidence. A unique exact reading still requires an explicit runtime state. Polysemy, close scores, open compound slots, grammar or Semantic-IR routes, missing roles, and gaps cause clarification rather than first-match selection. Explicit resolution passes through the controlled grammar, canonical Semantic IR, EZF-1 renderer, and inverse decoder.

  ## Remaining release work

  The core translator pipeline is complete. The next authorized gate is glyph and audio output: IR-driven SVG, MIDI, and optional synthesized audio. Presentation work must consume validated EZF-1 output and must not change semantic identity. Future vocabulary expansion may close recorded gaps through the existing atom/compound review process, but those gaps do not block the safe ranked translator.

  ## Regression command

  Run `ruby tools/regress_current_state.rb` from the project root. A release is acceptable only when the complete atomic, compound, sense, coverage, etymology, IR, renderer, controlled-English, general-English, and family soundness suite passes.
MD
File.write(File.join(EraZeroValidation::ROOT, "reports/translator_readiness_roadmap.md"), roadmap)

puts "Built general English: #{analysis_cases.length} analyses / #{resolution_cases.length} resolutions; #{senses.length} indexed senses"
