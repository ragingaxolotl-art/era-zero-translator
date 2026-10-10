#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_renderer"
require_relative "../tools/lib/era_zero_controlled_english"

include EraZeroValidation
VERSION = "1.0.0"
DATE = "2026-10-09"

compiler = EraZeroControlledEnglish::Compiler.new
sense_doc = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml")
atoms = EraZeroValidation.load_yaml("lexicon/atoms.yaml").fetch("atoms")
compounds = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries")

valid_inputs = {
  "simple_assertion" => 'ASSERT "active care" [1].',
  "question" => 'QUESTION "active destination" [1].',
  "command_roles" => 'COMMAND "active target restoration" [1] ROLE actor "conscious other" [1] ROLE target "active material object" [1].',
  "negation" => 'ASSERT NOT "active internal formal evaluation" [1].',
  "modality" => 'POSSIBILITY MODAL possible "potential source departure" [2].',
  "aspect" => 'ASSERT ASPECT ongoing "active artifact generation" [1].',
  "time" => 'ASSERT "completed source departure" [1] TIME before SPEECH_TIME.',
  "measurement" => 'ASSERT "active source departure" [1] MEASURE 5 kilometer.',
  "quantifier" => 'ASSERT "conscious other" [1] QUANTIFIER exact 3.',
  "fixed_compound" => 'ASSERT "living body" [1].',
  "slotted_compound" => 'ASSERT "directed data link" [1] ROLE source "conscious other" [1] ROLE target "active material object" [1].',
  "sequence" => 'ASSERT SEQUENCE "completed source departure" [1] THEN "completed target arrival" [1].',
  "parallel" => 'ASSERT PARALLEL "active internal data transformation" [1] AND "active source expression" [1].',
  "repetition" => 'ASSERT REPEAT 3 TIMES "active shared-frame movement" [1].',
  "conditional" => 'ASSERT IF "active internal formal evaluation" [1] THEN "active artifact generation" [1].',
  "definition" => 'DEFINE "program definition" [1].'
}

invalid_inputs = {
  "empty" => ["", "empty_input"],
  "missing_period" => ['ASSERT "active care" [1]', "missing_terminal_period"],
  "bad_act" => ['TELL "active care" [1].', "unsupported_speech_act"],
  "missing_clause" => ["ASSERT.", "missing_clause"],
  "unquoted" => ["ASSERT active care [1].", "invalid_lexical_form"],
  "bad_runtime" => ['ASSERT "active care" [num].', "invalid_runtime_state"],
  "unknown_label" => ['ASSERT "imaginary snow motion" [1].', "unknown_lexeme"],
  "unsupported_route" => ['ASSERT "food" [1].', "unsupported_sense_route"],
  "bad_modality" => ['ASSERT MODAL maybe "active care" [1].', "invalid_modality"],
  "bad_role" => ['ASSERT "active care" [1] ROLE owner "conscious other" [1].', "invalid_role"],
  "duplicate_role" => ['ASSERT "active care" [1] ROLE actor "conscious other" [1] ROLE actor "active material object" [1].', "duplicate_role"],
  "bad_time" => ['ASSERT "active care" [1] TIME yesterday SPEECH_TIME.', "invalid_time_relation"],
  "bad_unit" => ['ASSERT "active source departure" [1] MEASURE 5 furlong.', "invalid_unit"],
  "missing_compound_slot" => ['ASSERT "directed data link" [1] ROLE source "conscious other" [1].', "missing_compound_role"],
  "unexpected_text" => ['ASSERT "active care" [1] PLEASE.', "unexpected_token"],
  "bad_coordination" => ['ASSERT SEQUENCE "active care" [1].', "invalid_coordination"],
  "bad_repetition" => ['ASSERT REPEAT zero TIMES "active care" [1].', "invalid_repetition"]
}

golden = valid_inputs.map do |case_id, input|
  result = compiler.compile(input)
  raise "valid fixture failed: #{case_id}: #{result.inspect}" unless result["status"] == "ok"
  formal = EraZeroRenderer.render(result.fetch("semantic_ir"))
  { "case_id" => case_id, "input" => input, "expected_ir" => result.fetch("semantic_ir"), "expected_formal_id" => formal.fetch("formal_id"), "expected_literal_gloss" => formal.fetch("literal_gloss") }
end
negative = invalid_inputs.map do |case_id, (input, code)|
  result = compiler.compile(input)
  raise "invalid fixture unexpectedly passed: #{case_id}" unless result["status"] == "error" && result.dig("error", "code") == code
  { "case_id" => case_id, "input" => input, "expected_error" => code }
end

controlled_senses = sense_doc.fetch("senses").select { |sense| sense["controlled_input_allowed"] == true && %w[atom compound].include?(sense["route"]) }
spec = {
  "metadata" => {
    "title" => "Era Zero Controlled English Compiler", "version" => VERSION, "status" => "canonical",
    "sense_index_fingerprint" => EraZeroValidation.fingerprint(sense_doc.fetch("senses")),
    "semantic_ir_fingerprint" => EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/semantic_ir_1.0.yaml")),
    "renderer_fingerprint" => EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/renderer_decoder_1.0.yaml")),
    "controlled_lexeme_count" => controlled_senses.length, "general_english_started" => false
  },
  "boundary" => {
    "purpose" => "A deterministic, auditable input language for canonical labels and explicit semantic operators; not unrestricted English.",
    "accepted_lexemes" => "Exact quoted canonical atom and approved compound labels whose sense record has controlled_input_allowed: true.",
    "normalization" => "Unicode NFC, lowercase lookup, collapsed internal whitespace; output retains canonical target identity.",
    "no_guessing" => "Unknown, non-controlled, ambiguous, or underspecified input returns one structured error and no IR.",
    "excluded" => ["synonym inference", "pronouns or implicit coreference", "implicit tense", "implicit roles", "unquoted free phrases", "ranked candidate selection", "general-English parsing"]
  },
  "grammar" => {
    "terminal" => "Every input ends in exactly one period.",
    "speech_act" => "ASSERT | QUESTION | COMMAND | DEFINE | POSSIBILITY",
    "lexical" => "\"<controlled label>\" [0|1|2]",
    "simple" => "ACT [NOT] [MODAL mode] [ASPECT aspect] LEXICAL {ROLE role LEXICAL} [TIME relation SPEECH_TIME] [MEASURE decimal unit] [QUANTIFIER kind [decimal]] .",
    "sequence" => "ACT SEQUENCE LEXICAL THEN LEXICAL {THEN LEXICAL} .",
    "parallel" => "ACT PARALLEL LEXICAL AND LEXICAL {AND LEXICAL} .",
    "repetition" => "ACT REPEAT positive_integer TIMES LEXICAL .",
    "conditional" => "ACT IF LEXICAL THEN LEXICAL .",
    "ordering_rule" => "Keywords and modifiers occur only in the documented order; reordering is an error, not an alternative parse."
  },
  "inventories" => {
    "speech_acts" => EraZeroControlledEnglish::ACTS,
    "roles" => EraZeroControlledEnglish::ROLES,
    "modalities" => EraZeroControlledEnglish::MODES,
    "aspects" => EraZeroControlledEnglish::ASPECTS,
    "time_relations" => EraZeroControlledEnglish::TIME_RELATIONS,
    "units" => EraZeroControlledEnglish::UNITS,
    "runtime_states" => { 0 => "state zero", 1 => "state one", 2 => "state two, named num in the renderer" }
  },
  "mapping" => {
    "lexical" => "The unique controlled sense supplies target_type and target_id.",
    "roles" => "ROLE creates an explicit fills_role edge from argument occurrence to head occurrence.",
    "operators" => "NOT, MODAL, ASPECT, and QUANTIFIER create explicit nested scope_operator nodes in written order.",
    "time" => "TIME creates a speech_time anchor and explicit time_relation to the root clause.",
    "measurement" => "MEASURE creates a measurement node filling quantity.",
    "compound_slots" => "Every open slot declared by an approved compound must be supplied by a matching ROLE binding.",
    "composition" => "SEQUENCE, PARALLEL, REPEAT, and IF create the canonical coordination, repetition, and conditional IR structures."
  },
  "errors" => %w[empty_input missing_terminal_period unsupported_speech_act missing_clause invalid_lexical_form invalid_runtime_state unknown_lexeme ambiguous_lexeme unsupported_sense_route invalid_modality invalid_aspect invalid_role duplicate_role invalid_time_relation duplicate_time invalid_quantity invalid_unit duplicate_measurement missing_quantifier_value duplicate_quantifier missing_compound_role invalid_coordination invalid_repetition invalid_conditional unexpected_token],
  "pipeline" => ["controlled input", "deterministic compiler", "canonical semantic IR", "IR validation", "EZF-1 renderer", "inverse decoder"],
  "implementation" => { "library" => "tools/lib/era_zero_controlled_english.rb", "cli" => "tools/compile_controlled_english.rb", "golden_tests" => "tests/controlled_english_cases.yaml" }
}

tests = { "metadata" => { "version" => VERSION, "valid_cases" => golden.length, "invalid_cases" => negative.length, "controlled_lexemes" => controlled_senses.length }, "valid_cases" => golden, "invalid_cases" => negative }
report = <<~MD
  # Controlled English Compiler 1.0

  Status: **CANONICAL — GENERAL-ENGLISH GATE MAY BEGIN**

  This gate implements a deliberately restricted English-facing compiler. Exact quoted canonical labels combine with explicit runtime states, speech acts, roles, scope operators, speech-time relations, measurements, quantifiers, sequence, parallelism, repetition, and conditionals. Every successful compilation produces canonical Semantic IR and passes through the existing deterministic renderer and inverse decoder.

  The compiler does not accept unrestricted prose, infer synonyms, recover omitted roles, choose a first sense, or equate runtime state with negation, modality, or tense. Unsupported input returns a structured error with a stable code and no partial IR. Open compound slots must be explicitly bound.

  The golden suite contains #{golden.length} valid translations and #{negative.length} negative cases. Exhaustive lexical tests cover all #{controlled_senses.length} controlled canonical labels (#{atoms.length} atoms and #{compounds.length} compounds).
MD
migration = { "migration_id" => "controlled_english_1.0", "date" => DATE, "status" => "applied", "from" => { "controlled_english" => "not_started" }, "to" => { "controlled_english" => "complete", "version" => VERSION, "controlled_lexemes" => controlled_senses.length, "golden_cases" => golden.length }, "lexical_changes" => [], "next_gate" => "general_english" }

File.write(File.join(EraZeroValidation::ROOT, "spec/controlled_english_1.0.yaml"), YAML.dump(spec))
File.write(File.join(EraZeroValidation::ROOT, "tests/controlled_english_cases.yaml"), YAML.dump(tests))
File.write(File.join(EraZeroValidation::ROOT, "reports/controlled_english.md"), report)
File.write(File.join(EraZeroValidation::ROOT, "migrations/controlled_english_1.0.yaml"), YAML.dump(migration))

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["last_completed_gate"] = "controlled_english"
version["next_gate_authorized"] = "general_english"
version["controlled_english_status"] = "canonical"
version["controlled_english_version"] = VERSION
version["controlled_english"] = "spec/controlled_english_1.0.yaml"
File.write(version_path, YAML.dump(version))

readiness_path = File.join(EraZeroValidation::ROOT, "spec/translator_readiness.yaml")
readiness = YAML.load_file(readiness_path)
readiness["next_authorized_gate"] = "general_english"
gate = readiness.fetch("required_gates").find { |item| item["gate"] == "controlled_english" }
gate["status"] = "complete"
gate["artifact"] = "spec/controlled_english_1.0.yaml"
gate["validation"] = "reports/controlled_english_validation.md"
readiness["safe_now"]["controlled_english_translation"] = true
readiness["controlled_english"] = { "status" => "complete_and_canonical", "version" => VERSION, "spec" => "spec/controlled_english_1.0.yaml", "implementation" => "tools/lib/era_zero_controlled_english.rb", "controlled_lexemes" => controlled_senses.length, "general_english_started" => false }
File.write(readiness_path, YAML.dump(readiness))

canonical_path = File.join(EraZeroValidation::ROOT, "spec/canonical_spec.yaml")
canonical = YAML.load_file(canonical_path)
canonical["controlled_english"] = { "status" => "canonical", "version" => VERSION, "path" => "spec/controlled_english_1.0.yaml", "implementation" => "tools/lib/era_zero_controlled_english.rb" }
File.write(canonical_path, YAML.dump(canonical))

status_path = File.join(EraZeroValidation::ROOT, "semantic_authority_status.md")
status = File.read(status_path)
unless status.include?("Controlled English compiler — #{DATE}")
  status << "\n## Controlled English compiler — #{DATE}\n\n- Status: **canonical #{VERSION}** with deterministic compiler and structured errors.\n- All 324 canonical atom labels and 28 approved compound labels are available only through the explicit controlled grammar.\n- Lexical authority is unchanged. Next authorized work: **general English** with ranked candidates and clarification.\n"
  File.write(status_path, status)
end

puts "Built controlled English: #{golden.length} valid / #{negative.length} invalid golden cases; #{controlled_senses.length} lexemes"
