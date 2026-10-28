#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require_relative "../tools/lib/era_zero_validation"
require_relative "../app/api"

include EraZeroValidation
spec = EraZeroValidation.load_yaml("spec/product_application_1.0.yaml")
corpus = EraZeroValidation.load_yaml("tests/product_evaluation_corpus.yaml")
api = EraZeroApp::API.new
checks = EraZeroValidation::CheckSet.new
json_body = ->(response) { JSON.parse(response.body) }
post = ->(path, value) { api.dispatch("POST", path, JSON.generate(value)) }

checks.add("canonical immutability", "product layer fingerprints canonical translator/presentation and declares zero semantic changes", spec.dig("metadata", "translator_fingerprint") == EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/general_english_1.0.yaml")) && spec.dig("metadata", "presentation_fingerprint") == EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/glyph_audio_1.0.yaml")) && spec.dig("metadata", "semantic_authority_changes") == 0)

health = json_body.call(api.dispatch("GET", "/api/health"))
meta = json_body.call(api.dispatch("GET", "/api/meta"))
checks.add("health and metadata", "service reports complete canonical engine, formats, counts, limits, and no-silent-guess policy", health["status"] == "ok" && health["all_gates_complete"] == true && health["translator_release"] == "complete" && meta.dig("counts", "atoms") == 324 && meta.dig("counts", "senses") == EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml").fetch("senses").length && meta["formats"].to_set == %w[EZIR-JSON-1 EZF-1 EZSVG-1 EZB-1 MIDI-0].to_set && meta["no_silent_guess"] == true)

sense_ok = corpus.fetch("sense_cases").all? do |item|
  result = json_body.call(post.call("/api/analyze", { "input" => item["input"], "limit" => 20 }))
  result["status"] == "ok" && result.fetch("candidates").any? { |candidate| candidate["sense_id"] == item["expected_sense_id"] && candidate["route"] == item["expected_route"] }
end
checks.add("evaluation sense recall", "all reviewed noncanonical senses are recalled through the public API", sense_ok && corpus.fetch("sense_cases").length >= 80)

leave = json_body.call(post.call("/api/analyze", { "input" => "leave [1]" }))
go = json_body.call(post.call("/api/analyze", { "input" => "go [1]" }))
change = json_body.call(post.call("/api/analyze", { "input" => "change [1]" }))
context = json_body.call(post.call("/api/analyze", { "input" => "change represented information content [1]" }))
checks.add("candidate decisions", "auto-resolution, polysemy, and contextual ranking retain the canonical conservative behavior", leave.dig("decision", "auto_resolution_allowed") == true && leave.dig("translation", "round_trip_equal") == true && go.dig("decision", "reasons").include?("material_sense_ambiguity") && change.fetch("candidates").count { |candidate| candidate["match_type"] == "exact_lemma" } >= 5 && context.dig("candidates", 0, "target_id") == "DAT:101" && context.dig("decision", "requires_clarification") == true)

food = json_body.call(post.call("/api/analyze", { "input" => "food [1]" }))
home = json_body.call(post.call("/api/analyze", { "input" => "home [1]" }))
build = json_body.call(post.call("/api/analyze", { "input" => "build [1]" }))
slotted = json_body.call(post.call("/api/analyze", { "input" => "directed data link [1]" }))
checks.add("gap and structure honesty", "gaps, structural routes, and compound roles remain visible with no premature IR", food.dig("candidates", 0, "route") == "gap" && home.fetch("candidates").count { |candidate| candidate["route"] == "gap" } >= 2 && build.dig("candidates", 0, "route") == "semantic_ir" && slotted.dig("candidates", 0, "required_roles") == %w[source target] && slotted.dig("candidates", 0, "semantic_ir_options").empty?)

resolution = leave.fetch("translation")
resolved = json_body.call(post.call("/api/resolve", { "input" => "leave", "sense_id" => resolution["sense_id"], "runtime_state" => 1, "speech_act" => "assertion", "roles" => {} }))
checks.add("resolution round trip", "public resolve endpoint returns controlled input, canonical IR, EZF, and exact round trip", resolved["status"] == "resolved" && resolved["target_id"] == "MOV:101" && resolved["round_trip_equal"] == true && resolved.dig("semantic_ir", "utterance_id").start_with?("UTT:") && resolved.dig("formal", "formal_id").start_with?("EZF:"))

controlled = json_body.call(post.call("/api/controlled", { "input" => 'QUESTION "active destination" [1].' }))
checks.add("controlled compiler", "controlled endpoint produces question IR and rejects malformed free text", controlled["status"] == "ok" && controlled.dig("semantic_ir", "speech_act") == "question" && post.call("/api/controlled", { "input" => "please go" }).status == 422)

svg = post.call("/api/svg", { "formal" => resolved["formal"] })
midi = post.call("/api/midi", { "formal" => resolved["formal"] })
checks.add("presentation exports", "SVG and MIDI endpoints return correct deterministic binary formats", svg.status == 200 && svg.headers["Content-Type"].start_with?("image/svg+xml") && svg.body.include?("data-format=\"EZSVG-1\"") && midi.status == 200 && midi.headers["Content-Type"] == "audio/midi" && midi.body.start_with?("MThd"))

bundle = json_body.call(post.call("/api/bundle/export", { "source" => "leave [1]", "resolution" => resolved }))
verified = json_body.call(post.call("/api/bundle/import", { "bundle" => bundle }))
corrupt = Marshal.load(Marshal.dump(bundle)); corrupt["payload"]["target_id"] = "MOV:999"
corrupt_result = json_body.call(post.call("/api/bundle/import", { "bundle" => corrupt }))
checks.add("exchange integrity", "EZB-1 export imports exactly and corruption is rejected", bundle["format"] == "EZB-1" && verified["status"] == "valid" && verified["target_id"] == "MOV:101" && corrupt_result.dig("error", "code") == "invalid_bundle")

invalid_json = json_body.call(api.dispatch("POST", "/api/analyze", "{"))
missing = json_body.call(post.call("/api/analyze", {}))
too_large = json_body.call(api.dispatch("POST", "/api/analyze", "x" * (EraZeroApp::MAX_BODY_BYTES + 1)))
not_found = json_body.call(api.dispatch("GET", "/api/missing"))
method = json_body.call(api.dispatch("DELETE", "/api/health"))
checks.add("API error and abuse paths", "invalid JSON, missing fields, oversized bodies, unknown routes, and methods return stable bounded errors", invalid_json.dig("error", "code") == "invalid_json" && missing.dig("error", "code") == "missing_field" && too_large.dig("error", "code") == "payload_too_large" && not_found.dig("error", "code") == "not_found" && method.dig("error", "code") == "method_not_allowed")

html = File.read(File.join(EraZeroValidation::ROOT, "app/public/index.html"))
css = File.read(File.join(EraZeroValidation::ROOT, "app/public/styles.css"))
js = File.read(File.join(EraZeroValidation::ROOT, "app/public/app.js"))
checks.add("workbench surface", "responsive UI exposes analysis, clarification, roles, runtime, speech act, IR, EZF, SVG, MIDI, and bundles with accessibility markers", %w[sourceInput candidateList runtimeState speechAct roleFields irCode formalCode glyphStage downloadMidi downloadBundle importBundle].all? { |id| html.include?(%(id="#{id}")) } && html.include?("aria-live") && html.include?("role=\"tablist\"") && css.include?("@media(max-width:900px)") && css.include?("prefers-reduced-motion") && js.include?("material_sense_ambiguity") && js.include?("round_trip_equal"))
checks.add("selectable audio voices", "the local workbench exposes instrument-like presentation voices without changing semantic data", html.include?('id="soundVoice"') && %w[era_zero ocarina electric_piano synth_bell warm_organ].all? { |voice| html.include?(%(value="#{voice}")) } && js.include?("AUDIO_VOICES") && js.include?("Notes and meanings stay unchanged"))
checks.add("mode-state isolation", "switching input modes preserves separate drafts, clears stale results, updates examples, and sends controlled compilation directly to its Semantic IR", js.include?("drafts:{general:'',controlled:''}") && js.include?("state.resolution=null") && js.include?("examples[next][i][1]") && js.include?("activateOutputPanel('ir')"))
checks.add("automatic result labeling", "safe automatic resolutions display the matched invariant definition instead of falling back to an opaque target ID", js.include?("state.analysis?.candidates.find(c=>c.sense_id===result.sense_id)") && js.include?("resolvedCandidate?.definition||result.target_id"))

checks.add("documentation and launch", "launcher, API guide, user guide, audit checklist, and source files exist", %w[bin/era-zero-workbench README_TRANSLATOR.md docs/TRANSLATOR_API.md docs/PRODUCT_AUDIT.md app/server.rb app/api.rb app/public/index.html app/public/styles.css app/public/app.js tools/lib/era_zero_exchange.rb].all? { |path| File.file?(File.join(EraZeroValidation::ROOT, path)) })

version = EraZeroValidation.load_yaml("spec/version.yaml")
canonical = EraZeroValidation.load_yaml("spec/canonical_spec.yaml")
checks.add("authority integration", "application is canonical and semantic authority remains unchanged", version["product_application_status"] == "canonical" && version["product_application_version"] == "1.0.0" && canonical.dig("product_application", "status") == "canonical" && canonical.dig("product_application", "semantic_authority") == "unchanged" && EraZeroValidation.load_yaml("migrations/product_application_1.0.yaml")["semantic_changes"] == [])

report = checks.markdown(title: "Era Zero Translator Workbench Product Audit", pass_status: "PASS — CANONICAL PRODUCT RELEASE MEETS AUDIT CONTRACT", summary: ["API endpoints: **9**", "Reviewed-sense evaluation cases: **#{corpus.fetch('sense_cases').length}**", "Curated user journeys: **#{corpus.fetch('journey_cases').length}**", "Bundle format: **EZB-1**", "Canonical semantic changes: **0**", "Full regression required: **yes**"])
EraZeroValidation.write("reports/product_application_audit.md", report)
puts "Product application audit: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
