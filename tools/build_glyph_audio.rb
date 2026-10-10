#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "fileutils"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_renderer"
require_relative "../tools/lib/era_zero_presentation"

include EraZeroValidation
VERSION = "1.0.0"
DATE = "2026-10-09"

ir_cases = EraZeroValidation.load_yaml("tests/semantic_ir_cases.yaml").fetch("valid_cases")
manifests = []
ir_cases.each do |item|
  [48, 60, 72].each do |anchor|
    formal = EraZeroRenderer.render(item.fetch("ir"), anchor_midi: anchor)
    manifests << EraZeroPresentation.manifest(formal).merge("case_id" => item["case_id"], "anchor_midi" => anchor)
  end
end

sample_dir = File.join(EraZeroValidation::ROOT, "examples/presentation")
FileUtils.mkdir_p(sample_dir)
ir_cases.first(3).each do |item|
  formal = EraZeroRenderer.render(item.fetch("ir"))
  prefix = File.join(sample_dir, item.fetch("case_id"))
  File.write("#{prefix}.svg", EraZeroPresentation.svg(formal))
  File.binwrite("#{prefix}.mid", EraZeroPresentation.midi(formal))
end

spec = {
  "metadata" => {
    "title" => "Era Zero Deterministic Glyph and MIDI Presentation", "version" => VERSION, "status" => "canonical",
    "renderer_fingerprint" => EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/renderer_decoder_1.0.yaml")),
    "semantic_identity" => "unchanged", "synthesized_waveform_audio" => "optional_not_implemented"
  },
  "input_contract" => {
    "format" => "validated EZF-1 only", "validation" => "inverse-decode before presentation generation",
    "identity" => "SVG and MIDI are derived presentation artifacts and never participate in UTT or EZF identity."
  },
  "svg" => {
    "format" => "EZSVG-1", "encoding" => "UTF-8 SVG 1.1-compatible XML",
    "layout" => "one labeled row per lexical event; family opening, address path, and runtime ending rendered as connected pitch points",
    "metadata" => ["formal_id", "semantic_digest", "profile", "primary contour"],
    "accessibility" => "role=img with title and description; every event exposes target and register data attributes",
    "determinism" => "identical EZF input produces byte-identical SVG"
  },
  "midi" => {
    "format" => "Standard MIDI File type 0", "ticks_per_beat" => EraZeroPresentation::TICKS_PER_BEAT,
    "tempo_microseconds_per_quarter" => EraZeroPresentation::TEMPO_MICROSECONDS, "program" => 0,
    "sequence" => "each lexical event emits family opening, address path, and runtime tail; primary contour follows lexical material",
    "velocity" => { "lexical" => 90, "contour" => 70 },
    "determinism" => "identical EZF input produces byte-identical MIDI"
  },
  "audio" => {
    "status" => "optional and not implemented in Era Zero 1.0", "reason" => "MIDI preserves the deterministic pitch/timing performance without choosing a voice, instrument recording, or synthesis engine.",
    "future_rule" => "Any synthesizer must consume the canonical MIDI/performance plan and remain presentation-only."
  },
  "transposition" => "Changing anchor pitch changes SVG vertical coordinates and MIDI notes but not semantic_digest or formal_id.",
  "implementation" => { "library" => "tools/lib/era_zero_presentation.rb", "cli" => "tools/generate_presentation.rb", "examples" => "examples/presentation/" }
}
tests = { "metadata" => { "version" => VERSION, "semantic_ir_cases" => ir_cases.length, "anchors" => [48, 60, 72], "presentation_cases" => manifests.length, "sample_pairs" => 3 }, "manifests" => manifests }
report = <<~MD
  # Deterministic Glyph and MIDI Presentation 1.0

  Status: **CANONICAL — ERA ZERO TRANSLATOR RELEASE PIPELINE COMPLETE**

  Validated EZF-1 documents now produce deterministic accessible SVG pitch-path notation and Standard MIDI File type 0 output. Both artifacts include or derive from the fixed family opening, address path, runtime ending, registers, contour, and timing profile without altering semantic identity.

  SVG and MIDI are presentation artifacts: transposition changes visible or audible pitch but never the UTT or EZF identity. Optional synthesized waveform audio is deliberately not implemented because selecting a synthesis engine, timbre, and voice would add nonsemantic presentation policy. MIDI is the canonical executable audio-performance interchange for this release.

  The conformance matrix contains #{manifests.length} presentations across #{ir_cases.length} Semantic-IR fixtures and three anchors. Three SVG/MIDI example pairs are generated under `examples/presentation/`.
MD
migration = { "migration_id" => "glyph_audio_1.0", "date" => DATE, "status" => "applied", "from" => { "glyph_and_audio" => "not_started" }, "to" => { "glyph_and_audio" => "complete", "version" => VERSION, "svg" => true, "midi" => true, "synthesized_audio" => false }, "lexical_changes" => [], "next_gate" => nil }

File.write(File.join(EraZeroValidation::ROOT, "spec/glyph_audio_1.0.yaml"), YAML.dump(spec))
File.write(File.join(EraZeroValidation::ROOT, "tests/glyph_audio_cases.yaml"), YAML.dump(tests))
File.write(File.join(EraZeroValidation::ROOT, "reports/glyph_audio.md"), report)
File.write(File.join(EraZeroValidation::ROOT, "migrations/glyph_audio_1.0.yaml"), YAML.dump(migration))

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["last_completed_gate"] = "glyph_and_audio"
version["next_gate_authorized"] = nil
version["glyph_audio_status"] = "canonical"
version["glyph_audio_version"] = VERSION
version["glyph_audio"] = "spec/glyph_audio_1.0.yaml"
version["translator_release_status"] = "complete"
File.write(version_path, YAML.dump(version))

readiness_path = File.join(EraZeroValidation::ROOT, "spec/translator_readiness.yaml")
readiness = YAML.load_file(readiness_path)
readiness["next_authorized_gate"] = nil
gate = readiness.fetch("required_gates").find { |item| item["gate"] == "glyph_and_audio" }
gate["status"] = "complete"
gate["artifact"] = "spec/glyph_audio_1.0.yaml"
gate["validation"] = "reports/glyph_audio_validation.md"
readiness["safe_now"]["svg_generation"] = true
readiness["safe_now"]["midi_generation"] = true
readiness["glyph_and_audio"] = { "status" => "complete_and_canonical", "version" => VERSION, "spec" => "spec/glyph_audio_1.0.yaml", "svg" => true, "midi" => true, "synthesized_waveform_audio" => false }
File.write(readiness_path, YAML.dump(readiness))

canonical_path = File.join(EraZeroValidation::ROOT, "spec/canonical_spec.yaml")
canonical = YAML.load_file(canonical_path)
canonical["glyph_and_audio"] = { "status" => "canonical", "version" => VERSION, "path" => "spec/glyph_audio_1.0.yaml", "implementation" => "tools/lib/era_zero_presentation.rb" }
File.write(canonical_path, YAML.dump(canonical))

status_path = File.join(EraZeroValidation::ROOT, "semantic_authority_status.md")
status = File.read(status_path)
unless status.include?("Glyph and MIDI presentation — #{DATE}")
  status << "\n## Glyph and MIDI presentation — #{DATE}\n\n- Status: **canonical #{VERSION}** deterministic SVG and Standard MIDI generation.\n- Presentation artifacts preserve UTT and EZF identity; optional synthesized waveform audio is deliberately deferred.\n- All seven translator-readiness gates are complete.\n"
  File.write(status_path, status)
end

roadmap_path = File.join(EraZeroValidation::ROOT, "reports/translator_readiness_roadmap.md")
roadmap = File.read(roadmap_path)
roadmap.sub!("| 7 | Glyph and audio outputs | Next — not started |", "| 7 | Glyph and audio outputs | Complete — SVG and MIDI canonical 1.0.0 |")
roadmap.sub!("The next authorized gate is glyph and audio output: IR-driven SVG, MIDI, and optional synthesized audio. Presentation work must consume validated EZF-1 output and must not change semantic identity.", "All planned translator-readiness gates are complete. Validated EZF-1 now produces deterministic accessible SVG and Standard MIDI output without changing semantic identity. Optional synthesized waveform audio remains a presentation extension, not a semantic gate.")
File.write(roadmap_path, roadmap)

puts "Built glyph/audio presentation: #{manifests.length} conformance artifacts and 3 sample pairs"
