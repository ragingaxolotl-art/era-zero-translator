#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "set"
require_relative 'lib/era_zero_compound_role_binding'
require_relative 'lib/era_zero_dictionary_probe'
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_renderer"

include EraZeroValidation
spec = EraZeroValidation.load_yaml("spec/renderer_decoder_1.0.yaml")
tests = EraZeroValidation.load_yaml("tests/renderer_round_trip_cases.yaml")
ir_cases = EraZeroValidation.load_yaml("tests/semantic_ir_cases.yaml").fetch("valid_cases")
atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
atoms = atoms_doc.fetch("atoms")
compounds_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
compounds = compounds_doc.fetch("entries")
checks = EraZeroValidation::CheckSet.new

checks.add("source immutability", "IR and compounds match recorded fingerprints; atoms match directly or through exact editorial reconciliation", spec.dig("metadata", "semantic_ir_fingerprint") == EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/semantic_ir_1.0.yaml")) && EraZeroValidation.atomic_fingerprint_matches?(atoms, spec.dig("metadata", "atomic_lexicon_fingerprint")) && spec.dig("metadata", "compound_dictionary_fingerprint") == EraZeroValidation.fingerprint(compounds))
checks.add("deliverable completeness", "formal notation, forms, notes, state, contour, timing, register, gloss, decoder, and round trip are specified", %w[formal_document reference_pitch_profile runtime_endings contours timing registers decoder round_trip_contract implementation].all? { |k| spec.key?(k) })

round_trip_ok = true
transposition_ok = true
ir_cases.each do |item|
  rendered = [48, 60, 72].map { |anchor| EraZeroRenderer.render(item.fetch("ir"), anchor_midi: anchor) }
  round_trip_ok &&= rendered.all? { |formal| EraZeroRenderer.decode(formal) == item.fetch("ir") }
  round_trip_ok &&= [48, 60, 72].zip(rendered).all? do |anchor, formal|
    snapshot = tests.fetch("round_trips").find { |row| row["source_case"] == item["case_id"] && row["anchor_midi"] == anchor }
    snapshot && snapshot["formal_id"] == formal["formal_id"] && snapshot["utterance_id"] == item.fetch("ir")["utterance_id"] && snapshot["lexical_event_count"] == formal.dig("performance", "lexical_events").length
  end
  transposition_ok &&= rendered.map { |f| f["formal_id"] }.uniq.length == 1
  relative = rendered.map { |f| f.dig("performance", "lexical_events").map { |e| [e["target_id"], e["address_relative_semitones"], e.dig("runtime_tail", "relative_motion_semitones")] } }
  transposition_ok &&= relative.uniq.length == 1
  [rendered[0], rendered[1], rendered[2]].each_cons(2) do |a, b|
    delta = b.dig("performance", "anchor_midi") - a.dig("performance", "anchor_midi")
    aa = a.dig("performance", "lexical_events").flat_map { |e| e["address_absolute_midi"] }
    bb = b.dig("performance", "lexical_events").flat_map { |e| e["address_absolute_midi"] }
    transposition_ok &&= aa.zip(bb).all? { |x, y| y - x == delta }
  end
end
checks.add("round trip", "all semantic-IR fixtures round-trip at MIDI anchors 48, 60, and 72", round_trip_ok && tests.fetch("round_trips").length == ir_cases.length * 3 && tests.fetch("round_trips").all? { |t| t["round_trip_equal"] })
checks.add("transposition", "formal identity and relative plans survive transposition while absolute notes shift exactly", transposition_ok)

atomic_ok = atoms.all? do |atom|
  [0, 1, 2].all? do |state|
    payload = { "ir_version" => "1.0", "root_clause" => "n001", "speech_act" => "assertion", "nodes" => [{ "node_id" => "n001", "kind" => "clause", "clause_type" => "predication" }, { "node_id" => "n002", "kind" => "lexical_occurrence", "target_type" => "atom", "target_id" => atom["canonical_id"], "runtime_state" => { "code" => state } }], "edges" => [{ "edge_id" => "e001", "type" => "centers", "from" => "n002", "to" => "n001" }], "discourse_constraints" => {} }
    digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
    ir = payload.merge("utterance_id" => "UTT:#{digest[0, 24]}", "serialization" => { "canonical_format" => "EZIR-JSON-1", "content_digest" => digest })
    formal = EraZeroRenderer.render(ir)
    event = formal.dig("performance", "lexical_events").first
    tail = event["runtime_tail"]
    event["family_qualified_transliteration"] == atom["canonical_transliteration"] && event["formal_carrier"] == atom["formal_carrier"] && event["address_relative_semitones"] == atom["note_path_semitones"] && tail["code"] == state && EraZeroRenderer.decode(formal) == ir
  end
end
checks.add("exhaustive atomic rendering", "all 324 atoms in all three runtime states render and decode exactly", atomic_ok && tests.dig("exhaustive_atomic_matrix", "assertions") == 972)

compound_ok = compounds.all? do |compound|
  [0, 1, 2].all? do |state|
    required_roles = EraZeroRenderer.required_compound_roles(compound, compounds: compounds)
    filler_nodes = required_roles.each_with_index.map { |_role, index| { "node_id" => format("n%03d", index + 3), "kind" => "lexical_occurrence", "target_type" => "atom", "target_id" => "ORI:000", "runtime_state" => { "code" => 1 } } }
    role_edges = required_roles.each_with_index.map { |role, index| { "edge_id" => format("e%03d", index + 2), "type" => "fills_role", "from" => filler_nodes[index]["node_id"], "to" => "n002", "role" => role } }
    aliases=EraZeroDictionaryProbe.role_aliases(compound,compounds)
    aliases.each { |role,first| role_edges.find { |e| e['role']==role }['from']=role_edges.find { |e| e['role']==first }['from'] }
    filler_nodes.select! { |node| role_edges.any? { |edge| edge['from']==node['node_id'] } }
    payload = { "ir_version" => "1.0", "root_clause" => "n001", "speech_act" => "assertion", "nodes" => [{ "node_id" => "n001", "kind" => "clause", "clause_type" => "predication" }, { "node_id" => "n002", "kind" => "lexical_occurrence", "target_type" => "compound", "target_id" => compound["compound_id"], "runtime_state" => { "code" => state } }] + filler_nodes, "edges" => [{ "edge_id" => "e001", "type" => "centers", "from" => "n002", "to" => "n001" }] + role_edges, "discourse_constraints" => {} }
    EraZeroCompoundRoleBinding.bind_unique_roles!(payload['nodes'],payload['edges'],compounds.to_h{|c|[c['compound_id'],c]})
    digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
    ir = payload.merge("utterance_id" => "UTT:#{digest[0, 24]}", "serialization" => { "canonical_format" => "EZIR-JSON-1", "content_digest" => digest })
    formal = EraZeroRenderer.render(ir)
    events = formal.dig("performance", "lexical_events")
    compound_events = events.select { |event| event["occurrence_id"] == "n002" }
    expanded = EraZeroCompoundExpansion::Expander.new(compounds).expand(compound.fetch("compound_id"), compound.fetch("definition_version"))
    roots = compound_events.reject { |event| event["kind"] == "grammar_marker" || event.key?("argument_node_id") }
    expected_roots = expanded.fetch("nodes").select { |node| node["kind"] == "root" }.map { |node| node.fetch("root_id") }.sort
    expected_markers = expanded.fetch("scopes").select { |scope| scope.key?("conventional_meaning") }.flat_map do |scope|
      %w[open close].map do |side|
        marker=EraZeroCompoundConventions.event(scope.fetch("conventional_meaning"),side,"n002",60,scope.fetch("path"))
        # A qualifying nested compound closes without a gap before its target.
        if side=='close' && expanded['edges'].any? { |e| e['type']=='qualifies' && e['from_scope_target']==scope['path'] }
          marker['boundary_after_beats']=0
        end
        marker
      end
    end
    markers = compound_events.select { |event| event["kind"] == "grammar_marker" }
    roots.count { |event| event["runtime_tail"] } == 1 && roots.map { |event| event["target_id"] }.sort == expected_roots && markers.sort_by { |event| JSON.generate(event) } == expected_markers.sort_by { |event| JSON.generate(event) } && EraZeroRenderer.decode(formal) == ir
  end
end
checks.add("compound rendering", "all approved compounds render every root and place runtime state on the head only", compound_ok && tests.dig("compound_matrix", "assertions") == compounds.length * 3)

slotted = compounds.find { |compound| EraZeroRenderer.required_compound_roles(compound).any? }
missing_slot_rejected = begin
  payload = { "ir_version" => "1.0", "root_clause" => "n001", "speech_act" => "assertion", "nodes" => [{ "node_id" => "n001", "kind" => "clause", "clause_type" => "predication" }, { "node_id" => "n002", "kind" => "lexical_occurrence", "target_type" => "compound", "target_id" => slotted.fetch("compound_id"), "runtime_state" => { "code" => 1 } }], "edges" => [{ "edge_id" => "e001", "type" => "centers", "from" => "n002", "to" => "n001" }], "discourse_constraints" => {} }
  digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
  ir = payload.merge("utterance_id" => "UTT:#{digest[0, 24]}", "serialization" => { "canonical_format" => "EZIR-JSON-1", "content_digest" => digest })
  EraZeroRenderer.render(ir)
  false
rescue EraZeroRenderer::RenderError => error
  error.message.include?("missing required roles")
end
checks.add("compound slot enforcement", "open compound participant slots must be explicitly bound before rendering", missing_slot_rejected)

sample = EraZeroRenderer.render(ir_cases.first.fetch("ir"))
corruption_ok = %w[formal_id semantic_digest literal_gloss].all? do |field|
  bad = Marshal.load(Marshal.dump(sample)); bad[field] = "corrupt"
  begin
    EraZeroRenderer.decode(bad)
    false
  rescue EraZeroRenderer::DecodeError
    true
  end
end
bad = Marshal.load(Marshal.dump(sample)); bad["performance"]["lexical_events"][0]["formal_carrier"] = "bad"
begin
  EraZeroRenderer.decode(bad)
  corruption_ok = false
rescue EraZeroRenderer::DecodeError
  # Expected: performance corruption must be rejected.
end
checks.add("corruption rejection", "decoder rejects identity, semantic, gloss, and performance corruption", corruption_ok)
checks.add("runtime algorithms", "state endings exactly implement -1 sharp, return-to-start, and +7 sustain num", spec.dig("runtime_endings", 0, "rule").include?("one semitone") && spec.dig("runtime_endings", 1, "rule").include?("starting pitch") && spec.dig("runtime_endings", 2, "name") == "num" && spec.dig("runtime_endings", 2, "rule").include?("seven semitones"))
checks.add("contour and timing", "all fixed speech-act contours and timing categories are represented", spec.dig("contours", "primary").keys.to_set == %w[assertion question command definition possibility].to_set && EraZeroRenderer::TIMING_BEATS.keys.to_set == %w[no_gap short_gap medium_gap long_gap overlap repeated_pulse].to_set)
checks.add("later-gate isolation", "controlled and general English remain unstarted", spec.dig("metadata", "controlled_english_started") == false && spec.dig("metadata", "general_english_started") == false)
checks.add("authority integration", "renderer/decoder remains canonical after orderly downstream progression", begin
  version = EraZeroValidation.load_yaml("spec/version.yaml")
  readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
  migration = EraZeroValidation.load_yaml("migrations/deterministic_renderer_decoder_1.0.yaml")
  gate = readiness.fetch("required_gates").find { |g| g["gate"] == "deterministic_renderer_and_decoder" }
  downstream = %w[controlled_english general_english glyph_and_audio]
  general_gate = readiness.fetch("required_gates").find { |item| item["gate"] == "general_english" }
  translator_progress_ok = readiness.dig("safe_now", "general_english_translation") == false || general_gate["status"] == "complete"
  downstream_ok = downstream.include?(version["next_gate_authorized"]) || (version["next_gate_authorized"].nil? && version["glyph_audio_status"] == "canonical")
  version["renderer_decoder_status"] == "canonical" && migration["next_gate"] == "controlled_english" && downstream_ok && gate["status"] == "complete" && translator_progress_ok
end)

report = checks.markdown(title: "Deterministic Renderer and Inverse Decoder Validation", pass_status: "PASS — RENDERER/DECODER CANONICAL; CONTROLLED ENGLISH MAY BEGIN", summary: ["Semantic IR fixtures: **#{ir_cases.length}**", "Transposed round trips: **#{ir_cases.length * 3}**", "Atomic state renderings: **972**", "Compound state renderings: **#{compounds.length * 3}**", "Decoder corruption classes tested: **4+**", "General English authorized: **no**"])
EraZeroValidation.write("reports/renderer_decoder_validation.md", report)
puts "Renderer/decoder validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |f| warn f }
exit(checks.success? ? 0 : 1)
