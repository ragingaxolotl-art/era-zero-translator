#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "digest"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_general_english"

include EraZeroValidation
VERSION = "1.0.0"
DATE = "2026-10-10"
translator = EraZeroGeneralEnglish::Translator.new
senses = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml").fetch("senses")
reviewed = senses.reject { |sense| %w[canonical_atom_label canonical_compound_label].include?(sense["sense_key"]) }

evaluation = reviewed.map.with_index do |sense, index|
  input = "#{sense.fetch('lemma')} [1]"
  result = translator.analyze(input, limit: 20)
  {
    "case_id" => format("sense-%03d", index + 1), "category" => "indexed_sense_recall", "input" => input,
    "expected_sense_id" => sense.fetch("sense_id"), "expected_route" => sense.fetch("route"),
    "candidate_present" => result["status"] == "ok" && result.fetch("candidates").any? { |candidate| candidate["sense_id"] == sense["sense_id"] },
    "expected_clarification" => sense["route"] != "atom" || result.dig("decision", "requires_clarification")
  }
end

journeys = [
  { "case_id" => "journey-auto-leave", "category" => "auto_resolution", "input" => "leave [1]", "expect" => { "auto" => true, "target_id" => "MOV:101" } },
  { "case_id" => "journey-question", "category" => "speech_act", "input" => "approach [1]?", "expect" => { "speech_act" => "question", "target_id" => "MOV:111" } },
  { "case_id" => "journey-runtime", "category" => "clarification", "input" => "arrive", "expect" => { "reason" => "runtime_state_required" } },
  { "case_id" => "journey-go", "category" => "polysemy", "input" => "go [1]", "expect" => { "reason" => "material_sense_ambiguity", "routes" => %w[atom semantic_ir] } },
  { "case_id" => "journey-change", "category" => "polysemy", "input" => "change [1]", "expect" => { "minimum_exact_candidates" => 5 } },
  { "case_id" => "journey-data-context", "category" => "contextual_ranking", "input" => "change represented information content [1]", "expect" => { "top_target" => "DAT:101", "clarify" => true } },
  { "case_id" => "journey-food-gap", "category" => "gap", "input" => "food [1]", "expect" => { "route" => "gap" } },
  { "case_id" => "journey-home-gap", "category" => "gap_polysemy", "input" => "home [1]", "expect" => { "minimum_gap_candidates" => 2 } },
  { "case_id" => "journey-build", "category" => "structural_route", "input" => "build [1]", "expect" => { "route" => "semantic_ir" } },
  { "case_id" => "journey-and", "category" => "grammar_route", "input" => "and", "expect" => { "route" => "grammar" } },
  { "case_id" => "journey-slotted", "category" => "compound_roles", "input" => "directed data link [1]", "expect" => { "roles" => %w[source target] } },
  { "case_id" => "journey-unknown", "category" => "unsupported", "input" => "flurple the moon [1]", "expect" => { "error" => "no_candidate" } },
  { "case_id" => "journey-bad-state", "category" => "invalid", "input" => "leave [num]", "expect" => { "error" => "invalid_runtime_state" } }
]

spec = {
  "metadata" => {
    "title" => "Era Zero Translator Workbench and Local API", "version" => VERSION, "status" => "canonical",
    "date" => DATE, "translator_fingerprint" => EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/general_english_1.0.yaml")),
    "presentation_fingerprint" => EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("spec/glyph_audio_1.0.yaml")),
    "semantic_authority_changes" => 0
  },
  "surfaces" => {
    "web" => "responsive local browser workbench for analysis, candidate comparison, clarification, resolution, inspection, preview, and export",
    "api" => "JSON and binary localhost endpoints under /api",
    "cli" => "existing controlled/general translator CLIs plus local server launcher",
    "exchange" => "EZB-1 deterministic integrity-checked translation bundle"
  },
  "api" => {
    "bind_default" => "127.0.0.1", "port_default" => 8787, "maximum_body_bytes" => 1_048_576,
    "endpoints" => ["GET /api/health", "GET /api/meta", "POST /api/analyze", "POST /api/resolve", "POST /api/controlled", "POST /api/svg", "POST /api/midi", "POST /api/bundle/export", "POST /api/bundle/import"],
    "error_contract" => "JSON status:error with stable code, message, and details; no exception traces or partial translations",
    "network_scope" => "localhost by default; no external service or telemetry"
  },
  "workbench" => {
    "general_flow" => ["enter phrase", "rank candidates", "inspect evidence", "choose runtime/speech act/roles", "resolve", "inspect meaning/IR/EZF/glyph", "preview or export"],
    "controlled_flow" => ["enter restricted statement", "compile deterministic IR", "inspect canonical identity"],
    "accessibility" => ["semantic landmarks", "keyboard-selectable candidates", "live status regions", "labeled controls", "responsive layout", "reduced-motion support"],
    "safety" => ["no first-match guess", "gaps visible", "structural routes visible", "roles explicit", "runtime explicit", "round-trip result visible"]
  },
  "exchange" => {
    "format" => "EZB-1", "identity" => "SHA-256 over sorted envelope excluding bundle_digest",
    "contents" => ["source", "sense_id", "target_id", "controlled_input", "semantic_ir", "formal", "presentation manifest"],
    "import_checks" => ["format and version", "bundle digest", "IR/EZF exact decode", "SVG/MIDI manifest hashes"]
  },
  "audit" => {
    "evaluation_cases" => evaluation.length + journeys.length, "indexed_noncanonical_senses" => reviewed.length,
    "required_checks" => ["canonical fingerprints", "API route contract", "structured errors", "candidate determinism", "indexed sense recall", "ambiguity and gap honesty", "resolution round trips", "bundle integrity", "SVG/MIDI export", "static UI accessibility markers", "JavaScript syntax", "local HTTP smoke test", "full language regression"]
  },
  "implementation" => { "server" => "app/server.rb", "api" => "app/api.rb", "web" => "app/public/", "exchange" => "tools/lib/era_zero_exchange.rb", "launcher" => "bin/era-zero-workbench" }
}

tests = { "metadata" => { "version" => VERSION, "sense_cases" => evaluation.length, "journey_cases" => journeys.length, "total" => evaluation.length + journeys.length }, "sense_cases" => evaluation, "journey_cases" => journeys }
migration = { "migration_id" => "product_application_1.0", "date" => DATE, "status" => "applied", "from" => { "translator_product" => "not_started" }, "to" => { "translator_product" => "canonical", "version" => VERSION, "api" => true, "web_workbench" => true, "exchange_format" => "EZB-1" }, "lexical_changes" => [], "semantic_changes" => [] }

File.write(File.join(EraZeroValidation::ROOT, "spec/product_application_1.0.yaml"), YAML.dump(spec))
File.write(File.join(EraZeroValidation::ROOT, "tests/product_evaluation_corpus.yaml"), YAML.dump(tests))
File.write(File.join(EraZeroValidation::ROOT, "migrations/product_application_1.0.yaml"), YAML.dump(migration))

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["product_application_status"] = "canonical"
version["product_application_version"] = VERSION
version["product_application"] = "spec/product_application_1.0.yaml"
File.write(version_path, YAML.dump(version))

canonical_path = File.join(EraZeroValidation::ROOT, "spec/canonical_spec.yaml")
canonical = YAML.load_file(canonical_path)
canonical["product_application"] = { "status" => "canonical", "version" => VERSION, "path" => "spec/product_application_1.0.yaml", "semantic_authority" => "unchanged" }
File.write(canonical_path, YAML.dump(canonical))

puts "Built product application audit corpus: #{evaluation.length} sense cases + #{journeys.length} journeys"
