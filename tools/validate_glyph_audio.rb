#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "digest"
require "rexml/document"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_renderer"
require_relative "../tools/lib/era_zero_presentation"

include EraZeroValidation
spec = EraZeroValidation.load_yaml("spec/glyph_audio_1.0.yaml")
tests = EraZeroValidation.load_yaml("tests/glyph_audio_cases.yaml")
ir_cases = EraZeroValidation.load_yaml("tests/semantic_ir_cases.yaml").fetch("valid_cases")
atoms = EraZeroValidation.load_yaml("lexicon/atoms.yaml").fetch("atoms")
checks = EraZeroValidation::CheckSet.new

checks.add("source immutability", "renderer matches the recorded fingerprint and semantic identity is unchanged", spec.dig("metadata", "renderer_fingerprint") == EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/renderer_decoder_1.0.yaml")) && spec.dig("metadata", "semantic_identity") == "unchanged")

matrix_ok = ir_cases.all? do |item|
  [48, 60, 72].all? do |anchor|
    formal = EraZeroRenderer.render(item.fetch("ir"), anchor_midi: anchor)
    # Historical bytes for these fixtures omitted their operator semantics.
    # Keep those manifests as historical evidence, never as accepted output.
    if %w[parallel].include?(item.fetch("case_id"))
      next [:svg, :midi].all? do |method|
        begin
          EraZeroPresentation.send(method, formal)
          false
        rescue EraZeroPresentation::PresentationError => error
          error.message.include?("unsupported musical")
        end
      end
    end
    svg1 = EraZeroPresentation.svg(formal); svg2 = EraZeroPresentation.svg(formal)
    midi1 = EraZeroPresentation.midi(formal); midi2 = EraZeroPresentation.midi(formal)
    manifest = tests.fetch("manifests").find { |entry| entry["case_id"] == item["case_id"] && entry["anchor_midi"] == anchor }
    svg1 == svg2 && midi1 == midi2 && manifest["svg_sha256"] == Digest::SHA256.hexdigest(svg1) && manifest["midi_sha256"] == Digest::SHA256.hexdigest(midi1) && EraZeroRenderer.decode(formal) == item["ir"]
  end
end
checks.add("presentation matrix", "supported fixtures match recorded SVG/MIDI at three anchors; parallel fixtures explicitly refuse semantically incomplete output", matrix_ok && tests.fetch("manifests").length == ir_cases.length * 3)

sample_formal = EraZeroRenderer.render(ir_cases.first.fetch("ir"))
sample_svg = EraZeroPresentation.svg(sample_formal)
svg_doc = REXML::Document.new(sample_svg)
root = svg_doc.root
checks.add("SVG conformance", "SVG is parseable, accessible, labeled, and tied to formal identity", root.name == "svg" && root.attributes["data-format"] == "EZSVG-1" && root.attributes["data-formal-id"] == sample_formal["formal_id"] && root.attributes["role"] == "img" && REXML::XPath.first(svg_doc, "//title") && REXML::XPath.first(svg_doc, "//desc") && REXML::XPath.match(svg_doc, "//*[contains(@class,'lexical-event')]").length == sample_formal.dig("performance", "lexical_events").length)

sample_midi = EraZeroPresentation.midi(sample_formal)
track_length = sample_midi[18, 4].unpack1("N")
checks.add("MIDI conformance", "MIDI has a type-0 header, one track, 480 PPQ, exact track length, tempo, and end marker", sample_midi.start_with?("MThd") && sample_midi[8, 6].unpack("nnn") == [0, 1, 480] && sample_midi[14, 4] == "MTrk" && track_length == sample_midi.bytesize - 22 && sample_midi.include?("\xFF\x51\x03".b) && sample_midi.end_with?("\x00\xFF\x2F\x00".b))

transposed = [48, 60, 72].map { |anchor| EraZeroRenderer.render(ir_cases.first.fetch("ir"), anchor_midi: anchor) }
checks.add("transposition", "pitch changes presentation bytes but not semantic or formal identity", transposed.map { |formal| formal["formal_id"] }.uniq.length == 1 && transposed.map { |formal| formal["semantic_digest"] }.uniq.length == 1 && transposed.map { |formal| Digest::SHA256.hexdigest(EraZeroPresentation.midi(formal)) }.uniq.length == 3 && transposed.map { |formal| Digest::SHA256.hexdigest(EraZeroPresentation.svg(formal)) }.uniq.length == 3)

atomic_ok = atoms.all? do |atom|
  [0, 1, 2].all? do |state|
    payload = { "ir_version" => "1.0", "root_clause" => "n001", "speech_act" => "assertion", "nodes" => [{ "node_id" => "n001", "kind" => "clause", "clause_type" => "predication" }, { "node_id" => "n002", "kind" => "lexical_occurrence", "target_type" => "atom", "target_id" => atom["canonical_id"], "runtime_state" => { "code" => state } }], "edges" => [{ "edge_id" => "e001", "type" => "centers", "from" => "n002", "to" => "n001" }], "discourse_constraints" => {} }
    digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
    ir = payload.merge("utterance_id" => "UTT:#{digest[0, 24]}", "serialization" => { "canonical_format" => "EZIR-JSON-1", "content_digest" => digest })
    formal = EraZeroRenderer.render(ir)
    EraZeroPresentation.svg(formal).include?(atom["canonical_id"]) && EraZeroPresentation.midi(formal).start_with?("MThd")
  end
end
checks.add("exhaustive atomic presentation", "all 324 atoms in all three runtime states produce SVG and MIDI", atomic_ok)

bad = Marshal.load(Marshal.dump(sample_formal)); bad["formal_id"] = "corrupt"
rejected = begin
  EraZeroPresentation.svg(bad)
  false
rescue EraZeroPresentation::PresentationError
  true
end
checks.add("invalid input rejection", "presentation refuses corrupted EZF-1 instead of drawing unverified data", rejected)
checks.add("audio scope", "MIDI is canonical while waveform synthesis remains explicitly optional and nonsemantic", spec.dig("audio", "status").include?("optional") && spec.dig("metadata", "synthesized_waveform_audio") == "optional_not_implemented")
checks.add("examples", "three SVG/MIDI example pairs exist", ir_cases.first(3).all? { |item| %w[svg mid].all? { |extension| File.file?(File.join(EraZeroValidation::ROOT, "examples/presentation/#{item['case_id']}.#{extension}")) } })
checks.add("legacy authority integration", "historical release gate metadata and presentation permissions remain consistent", begin
  version = EraZeroValidation.load_yaml("spec/version.yaml")
  readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
  version["glyph_audio_status"] == "canonical" && version["translator_release_status"] == "complete" && version["next_gate_authorized"].nil? && readiness["next_authorized_gate"].nil? && readiness.fetch("required_gates").all? { |gate| gate["status"] == "complete" } && readiness.dig("safe_now", "svg_generation") == true && readiness.dig("safe_now", "midi_generation") == true
end)

report = checks.markdown(title: "Glyph and MIDI Presentation Validation", pass_status: "PASS — BOUNDED PRESENTATION REGRESSION", summary: ["IR fixtures: **#{ir_cases.length}**", "Transposed presentation cases: **#{ir_cases.length * 3}**", "Atomic state presentations: **972**", "Example SVG/MIDI pairs: **3**", "Waveform synthesis: **optional, not implemented**", "This check does not establish full sentence or audible semantic completeness. See docs/translator-completion.md."])
EraZeroValidation.write("reports/glyph_audio_validation.md", report)
puts "Glyph/audio validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
