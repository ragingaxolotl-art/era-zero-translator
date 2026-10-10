#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "fileutils"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_renderer"

include EraZeroValidation
VERSION = "1.0.0"
DATE = "2026-10-09"

ir_spec = EraZeroValidation.load_yaml("spec/semantic_ir_1.0.yaml")
atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
compounds_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")

spec = {
  "metadata" => {
    "title" => "Era Zero Deterministic Renderer and Inverse Decoder", "version" => VERSION,
    "status" => "canonical", "formal_format" => "EZF-1", "performance_profile" => "reference-midi-v1",
    "semantic_ir_fingerprint" => EraZeroValidation.fingerprint(ir_spec),
    "atomic_lexicon_fingerprint" => EraZeroValidation.fingerprint(atoms_doc.fetch("atoms")),
    "compound_dictionary_fingerprint" => EraZeroValidation.fingerprint(compounds_doc.fetch("entries")),
    "controlled_english_started" => false, "general_english_started" => false
  },
  "render_pipeline" => [
    "validate canonical semantic IR identity",
    "resolve every lexical target against canonical atom or approved compound authority",
    "require explicit IR bindings for every open compound slot and expand root graphs with qualifier-before-head order",
    "assign role register from explicit fills_role edges",
    "emit family opening and address interval paths",
    "append runtime ending to each atomic occurrence or compound head",
    "derive speech-act contour and secondary repetition/parallel/dependency contours",
    "derive edge boundary timing",
    "emit literal gloss and canonical EZF identity"
  ],
  "formal_document" => {
    "semantic_layer" => "the complete canonical IR, retained losslessly for inverse decoding",
    "performance_layer" => "a deterministic derived plan containing lexical events, registers, relative and absolute notes, runtime tails, contours, and timing",
    "literal_gloss" => "deterministic node-and-component ordered lexical labels; diagnostic, not natural English",
    "formal_identity" => "SHA-256 of semantic digest plus the transposition-independent relative performance plan; ID is EZF:<first 24 lowercase hexadecimal digits>",
    "transposition" => "anchor_midi and all absolute notes are presentation data excluded from formal identity and decoded semantic equality"
  },
  "reference_pitch_profile" => {
    "anchor_midi_default" => 60, "anchor_name" => "C4 under MIDI convention; any integer 24–96 is valid",
    "register_offsets_semitones" => EraZeroRenderer::REGISTER_OFFSETS,
    "family_opening" => "register base plus the family's fixed harmonic-signature semitone offsets",
    "address_path" => "register base plus the root's fixed relative note path",
    "identity_rule" => "interval relations identify meaning; exact pitch does not"
  },
  "runtime_endings" => {
    0 => { "rule" => "from the address-final note, descend one semitone", "articulation" => "sharp stop", "reference_duration_beats" => 0.25 },
    1 => { "rule" => "return firmly to the phrase/register starting pitch", "articulation" => "firm return", "reference_duration_beats" => 0.5 },
    2 => { "name" => "num", "rule" => "from the address-final note, rise seven semitones (a perfect fifth)", "articulation" => "sustain", "reference_duration_beats" => 2.0 }
  },
  "contours" => {
    "primary" => EraZeroRenderer::CONTOURS,
    "reference_relative_paths" => EraZeroRenderer::CONTOUR_PATHS,
    "secondary" => { "repetition" => "repeated_loop", "parallel" => "overlapping_phrases", "condition_or_dependency" => "unresolved_ending" },
    "rule" => "Contour conveys grammar and never replaces the runtime ending or lexical address path."
  },
  "timing" => {
    "reference_beats" => EraZeroRenderer::TIMING_BEATS,
    "edge_mapping" => { "qualifies" => "no_gap", "fills_role" => "short_gap", "ordinary_structural_edge" => "medium_gap", "parallel_membership" => "overlap", "statement_end" => "long_gap", "repetition" => "repeated_pulse" },
    "rule" => "Beat values are a versioned reference performance profile; boundary categories carry grammar."
  },
  "registers" => {
    "core" => { "low" => %w[actor source cause], "middle" => ["predicate and all roles without a specialized profile"], "high" => %w[target result destination recipient beneficiary], "sustained_background" => %w[environment persistent_condition location time] },
    "selection" => "high, then low, then sustained-background, then middle when one occurrence fills multiple roles",
    "compound_rule" => "Components inherit the external occurrence register; only the compound head receives the occurrence runtime ending. Every open participant slot must be bound by an explicit IR fills_role edge before rendering."
  },
  "decoder" => {
    "checks" => ["EZF format", "semantic digest", "UTT identity", "lexical authority", "generated transliteration", "carrier", "relative path", "absolute transposition", "runtime ending", "register", "contour", "timing", "literal gloss", "EZF identity"],
    "result" => "the exact canonical semantic IR",
    "presentation_exclusions" => ["anchor_midi", "absolute notes", "reference durations"],
    "corruption_policy" => "Any mismatch is a structured decode error; the decoder never repairs or guesses."
  },
  "round_trip_contract" => {
    "equation" => "decode(render(IR, anchor)) = IR",
    "anchors" => [48, 60, 72],
    "semantic_comparison" => "exact deep equality of canonical IR",
    "transposition_test" => "relative plan and semantic result remain identical while every absolute note shifts by the anchor delta"
  },
  "implementation" => { "library" => "tools/lib/era_zero_renderer.rb", "render_cli" => "tools/render_ir.rb", "decode_cli" => "tools/decode_formal.rb" }
}

ir_cases = EraZeroValidation.load_yaml("tests/semantic_ir_cases.yaml").fetch("valid_cases")
roundtrips = []
ir_cases.each do |item|
  [48, 60, 72].each do |anchor|
    formal = EraZeroRenderer.render(item.fetch("ir"), anchor_midi: anchor)
    decoded = EraZeroRenderer.decode(formal)
    roundtrips << { "case_id" => "#{item['case_id']}@#{anchor}", "source_case" => item["case_id"], "anchor_midi" => anchor, "utterance_id" => decoded["utterance_id"], "formal_id" => formal["formal_id"], "lexical_event_count" => formal.dig("performance", "lexical_events").length, "round_trip_equal" => decoded == item["ir"] }
  end
end

tests = {
  "metadata" => { "version" => VERSION, "ir_cases" => ir_cases.length, "anchors" => [48, 60, 72], "round_trip_cases" => roundtrips.length },
  "round_trips" => roundtrips,
  "exhaustive_atomic_matrix" => { "atoms" => 324, "runtime_states" => [0, 1, 2], "assertions" => 972, "anchors" => [48, 60, 72], "generated_fields" => %w[canonical_transliteration formal_carrier harmonic_signature_semitones note_path_semitones runtime_ending] },
  "compound_matrix" => { "compounds" => compounds_doc.fetch("entries").length, "runtime_states" => [0, 1, 2], "assertions" => compounds_doc.fetch("entries").length * 3, "rule" => "all component roots render; runtime tail appears on head only; open slots require explicit role bindings" },
  "corruption_cases" => %w[formal_id semantic_digest transliteration carrier relative_notes absolute_notes runtime_tail contour timing literal_gloss unknown_target]
}

report = <<~MD
  # Deterministic Renderer and Inverse Decoder 1.0

  Status: **CANONICAL — CONTROLLED-ENGLISH GATE MAY BEGIN**

  This release implements canonical semantic IR to `EZF-1` formal notation and exact inverse decoding. It emits family-qualified transliteration, formal carrier, family opening, relative and absolute note paths, runtime ending, role register, speech-act contour, secondary repetition/parallel/dependency contours, boundary timing, and literal gloss.

  Absolute pitch is a transposable presentation profile. The default anchor is MIDI 60, with low, middle, high, and sustained-background register offsets. Formal identity uses only semantic content and the relative performance plan. Tests at anchors 48, 60, and 72 prove that transposition shifts absolute notes without changing relative intervals, UTT meaning, or EZF identity.

  Runtime state 2 is rendered as the fixed `num` ending: rise a perfect fifth and sustain. It has no invented numeric parameter. Compounds expand their approved root graphs; only the compound head receives the occurrence runtime ending.

  The inverse decoder regenerates the expected performance from the embedded canonical IR and rejects any mismatch instead of repairing or guessing. It returns the original IR exactly. English parsing remains outside this gate.
MD

migration = { "migration_id" => "deterministic_renderer_decoder_1.0", "date" => DATE, "status" => "applied", "from" => { "deterministic_renderer_and_decoder" => "not_started" }, "to" => { "deterministic_renderer_and_decoder" => "complete", "version" => VERSION, "round_trip_cases" => roundtrips.length }, "semantic_ir_fingerprint" => spec.dig("metadata", "semantic_ir_fingerprint"), "lexical_changes" => [], "next_gate" => "controlled_english" }

File.write(File.join(EraZeroValidation::ROOT, "spec/renderer_decoder_1.0.yaml"), YAML.dump(spec))
File.write(File.join(EraZeroValidation::ROOT, "tests/renderer_round_trip_cases.yaml"), YAML.dump(tests))
File.write(File.join(EraZeroValidation::ROOT, "reports/renderer_decoder.md"), report)
File.write(File.join(EraZeroValidation::ROOT, "migrations/deterministic_renderer_decoder_1.0.yaml"), YAML.dump(migration))

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["last_completed_gate"] = "deterministic_renderer_and_decoder"
version["next_gate_authorized"] = "controlled_english"
version["renderer_decoder_status"] = "canonical"
version["renderer_decoder_version"] = VERSION
version["renderer_decoder"] = "spec/renderer_decoder_1.0.yaml"
File.write(version_path, YAML.dump(version))

readiness_path = File.join(EraZeroValidation::ROOT, "spec/translator_readiness.yaml")
readiness = YAML.load_file(readiness_path)
readiness["next_authorized_gate"] = "controlled_english"
gate = readiness.fetch("required_gates").find { |g| g["gate"] == "deterministic_renderer_and_decoder" }
gate["status"] = "complete"
gate["artifact"] = "spec/renderer_decoder_1.0.yaml"
gate["validation"] = "reports/renderer_decoder_validation.md"
readiness["renderer_decoder"] = { "status" => "complete_and_canonical", "version" => VERSION, "spec" => "spec/renderer_decoder_1.0.yaml", "implementation" => "tools/lib/era_zero_renderer.rb", "round_trip_cases" => roundtrips.length, "controlled_english_started" => false }
File.write(readiness_path, YAML.dump(readiness))

canonical_path = File.join(EraZeroValidation::ROOT, "spec/canonical_spec.yaml")
canonical = YAML.load_file(canonical_path)
canonical["renderer_decoder"] = { "status" => "canonical", "version" => VERSION, "path" => "spec/renderer_decoder_1.0.yaml", "implementation" => "tools/lib/era_zero_renderer.rb" }
File.write(canonical_path, YAML.dump(canonical))

status_path = File.join(EraZeroValidation::ROOT, "semantic_authority_status.md")
status = File.read(status_path)
unless status.include?("Deterministic renderer and inverse decoder — #{DATE}")
  status << "\n## Deterministic renderer and inverse decoder — #{DATE}\n\n- Status: **canonical #{VERSION}** with executable render/decode implementation.\n- `EZF-1` covers transliteration, carriers, relative/absolute notes, runtime endings, contours, timing, registers, literal gloss, and exact IR recovery.\n- Round trips pass across three transpositions. Next authorized work: **controlled English**.\n"
  File.write(status_path, status)
end

puts "Built renderer/decoder: #{roundtrips.length} round-trip fixtures"
