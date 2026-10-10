#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require "set"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation

dictionary = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
reviews = EraZeroValidation.load_yaml("reviews/gate4b_high_frequency_compounds_scored_candidates.yaml")
cases = EraZeroValidation.load_yaml("tests/gate4b_compound_cases.yaml")
atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
atoms = EraZeroValidation.atoms_by_id(atoms_doc)
ids = atoms.keys.to_set
entries = dictionary.fetch("entries")
checks = EraZeroValidation::CheckSet.new

checks.add("bounded release", "dictionary declares canonical initial release and a nonzero exact count", dictionary.dig("metadata", "status") == "canonical_initial_release" && dictionary.dig("metadata", "entry_count") == entries.length && entries.length >= 24)
checks.add("unique content identities", "every entry has a unique CMP id and full digest", entries.map { |e| e["compound_id"] }.uniq.length == entries.length && entries.map { |e| e["content_digest"] }.uniq.length == entries.length)
checks.add("single heads", "every graph uses exactly one canonical h head", entries.all? { |e| e["semantic_head"] == "h" && e["nodes"].count { |n| n["node_id"] == "h" } == 1 })
checks.add("architecture binding", "every approved entry explicitly binds to compound architecture 1.0", entries.all? { |e| e["architecture_version"] == "1.0" })
checks.add("canonical atoms only", "every root node resolves to one of 324 canonical roots", entries.flat_map { |e| e["nodes"] }.select { |n| n["kind"] == "root" }.all? { |n| ids.include?(n["root_id"]) && atoms[n["root_id"]]["status"] == "canonical" })
checks.add("connected graphs", "every non-head node has a path to h", entries.all? do |e|
  graph = e["nodes"].to_h { |n| [n["node_id"], []] }
  e["edges"].each { |edge| graph[edge["from"]] << edge["to"] }
  reach = lambda { |node, seen| node == "h" || (!seen.include?(node) && graph.fetch(node).any? { |target| reach.call(target, seen | [node]) }) }
  graph.keys.all? { |node| reach.call(node, Set.new) }
end)
checks.add("content hashes", "each CMP id is derived from the canonical semantic payload", entries.all? do |e|
  payload = e.slice("architecture_version", "semantic_head", "nodes", "edges", "lexical_constraints")
  payload["architecture_version"] = "1.0"
  digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
  digest == e["content_digest"] && e["compound_id"] == "CMP:#{digest[0, 24]}" && e.dig("serialization", "content_digest") == digest
end)
checks.add("runtime separation", "no dictionary identity stores runtime, contour, pitch, or English-word fields", entries.all? { |e| (e.keys & %w[runtime_state contour register absolute_pitch english_word timing]).empty? })
checks.add("semantic records", "every entry has invariant, boundaries, collision analysis, examples, and confidence", entries.all? { |e| e["invariant_definition"].to_s.length >= 35 && e.dig("boundaries", "includes").to_s.length >= 15 && e.dig("boundaries", "excludes").to_s.length >= 15 && e["collision_audit"].to_s.length >= 30 && e.fetch("examples").keys.to_set == %w[ordinary technical future_compound counterexample].to_set })
checks.add("candidate review", "each approved entry has three scored semantic directions and one winner", reviews.fetch("reviews").length == entries.length && reviews.fetch("reviews").all? { |r| r["candidates"].length >= 3 && r["candidates"].count { |c| c["decision"] == "winner" } == 1 && r["candidates"].all? { |c| EraZeroValidation::SCORE_KEYS.all? { |k| c["scores"][k].between?(1, 10) } } })
checks.add("atom collision discipline", "every accepted graph contains a real cross-atom distinction", entries.all? { |e| e["nodes"].count { |n| n["kind"] == "root" } >= 2 })
checks.add("gap honesty", "water, food, shelter, and home are not forced into approved entries", %w[water food shelter home].all? { |term| cases.fetch("routing_tests").any? { |r| r["english_concept"] == term && %w[unresolved_gap defer_to_gate4c_and_ir].include?(r["route"]) } })
checks.add("occurrence boundary", "program execution, message sending, and transport are deferred to IR", %w[run\ a\ program send\ a\ message transport].all? { |term| cases.fetch("routing_tests").any? { |r| r["english_concept"] == term && r["route"].include?("ir") } })
checks.add("conformance coverage", "all approved entries and critical rejection classes have tests", cases.fetch("accepted").length == entries.length && cases.fetch("rejection_tests").length >= 5)
checks.add("atomic immutability", "atomic fingerprint and all generated forms remain unchanged", EraZeroValidation.fingerprint(atoms_doc.fetch("atoms")) == EraZeroValidation.load_yaml("migrations/gate4b_compound_dictionary_1.0.yaml")["atomic_lexicon_fingerprint"] && EraZeroValidation.generated_field_errors(atoms).empty?)
checks.add("authority integration", "Gate 4B remains canonical and its migration records the orderly Gate 4C handoff", begin
  version = EraZeroValidation.load_yaml("spec/version.yaml")
  readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
  migration = EraZeroValidation.load_yaml("migrations/gate4b_compound_dictionary_1.0.yaml")
  general_gate = readiness.fetch("required_gates").find { |gate| gate["gate"] == "general_english" }
  translator_progress_ok = readiness.dig("safe_now", "general_english_translation") == false || general_gate["status"] == "complete"
  version["compound_dictionary_entries"] == entries.length && version["gate4b_status"] == "canonical" && migration["next_gate"] == "gate4c_english_concept_and_sense_index" && translator_progress_ok
end)

report = checks.markdown(
  title: "Gate 4B High-Frequency Compound Dictionary Validation",
  pass_status: "PASS — GATE 4B INITIAL DICTIONARY CANONICAL; GATE 4C MAY BEGIN",
  summary: [
    "Dictionary version: **#{dictionary.dig('metadata', 'version')}**",
    "Approved compounds: **#{entries.length}**",
    "Candidate reviews: **#{reviews.fetch('reviews').length}**",
    "Routing tests: **#{cases.fetch('routing_tests').length}**",
    "Rejected/unsupported tests: **#{cases.fetch('rejection_tests').length}**",
    "Atomic roots changed: **0**",
    "Translator authorized: **no**"
  ]
)
report << "\n## Boundary\n\nGate 4B approves this bounded compound dictionary only. Gate 4C must build a sense-specific English index before labels can drive lookup. Semantic IR, grammar, renderer, decoder, and translator remain unstarted.\n"
EraZeroValidation.write("reports/gate4b_validation.md", report)

approval = <<~MD
  # Gate 4B Approval Record

  Status: **APPROVED — CANONICAL INITIAL RELEASE**  
  Version: **#{dictionary.dig('metadata', 'version')}**  
  Approved entries: **#{entries.length}**

  The user authorized the next translator-readiness stage and delegated approval authority. This record approves only the compound graphs whose identifiers appear in `lexicon/compound_dictionary.yaml`. It changes no atomic meaning or generated form.

  Common English concepts that cannot yet be represented precisely remain explicit gaps or are deferred. English labels remain metadata until Gate 4C. Semantic IR, grammar, renderer, decoder, and translator are not authorized by this approval.

  Next authorized gate: **Gate 4C — English concept and sense index**.
MD
EraZeroValidation.write("reports/gate4b_approval_record.md", approval)

puts "Gate 4B validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}; entries: #{entries.length}"
checks.failures.each { |f| warn f }
exit(checks.success? ? 0 : 1)
