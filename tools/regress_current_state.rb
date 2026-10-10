#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "rbconfig"
require_relative "lib/era_zero_validation"

include EraZeroValidation

version = EraZeroValidation.load_yaml("spec/version.yaml")
last_packet = version.fetch("last_completed_review_packet")
canonical_count = version.fetch("canonical_semantic_roots")
provisional_count = version.fetch("provisional_semantic_roots")
remaining_chunks = version.fetch("unreviewed_nine_root_chunks")
migration_count = EraZeroValidation::EFFECTIVE_MIGRATIONS.length
promotion_count = EraZeroValidation.effective_promotions.length
ruby = RbConfig.ruby
node = ENV.fetch("ERA_ZERO_NODE", "node")
commands = [
  ["refresh current gap inventory", [ruby, File.join(ROOT, "tools/regenerate_current_gap_reports.rb")]],
  ["validate current authority and translator boundary", [ruby, File.join(ROOT, "tools/validate_current_state.rb")]],
  [
    "validate latest semantic packet with reusable contract",
    [
      ruby,
      File.join(ROOT, "tools/validate_semantic_packet.rb"),
      last_packet.tr("–", "-"),
      "--mode", "canonical",
      "--report", "reports/latest_semantic_packet_validation.md"
    ]
  ],
  [
    "validate Gate 4A typed compound architecture",
    [ruby, File.join(ROOT, "tools/validate_gate4a_compound_architecture.rb")]
  ],
  [
    "validate Gate 4B high-frequency compound dictionary",
    [ruby, File.join(ROOT, "tools/validate_gate4b_compound_dictionary.rb")]
  ],
  [
    "validate Gate 4C English concept and sense index",
    [ruby, File.join(ROOT, "tools/validate_gate4c_english_sense_index.rb")]
  ],
  [
    "validate Gate 4D coverage and ambiguity report",
    [ruby, File.join(ROOT, "tools/validate_gate4d_coverage_report.rb")]
  ],
  [
    "validate Gate 4E formal etymology table",
    [ruby, File.join(ROOT, "tools/validate_gate4e_etymology_table.rb")]
  ],
  [
    "validate semantic IR and executable grammar",
    [ruby, File.join(ROOT, "tools/validate_semantic_ir_and_grammar.rb")]
  ],
  [
    "validate deterministic renderer and inverse decoder",
    [ruby, File.join(ROOT, "tools/validate_renderer_decoder.rb")]
  ],
  [
    "validate controlled English compiler",
    [ruby, File.join(ROOT, "tools/validate_controlled_english.rb")]
  ],
  [
    "validate general-English candidate translator",
    [ruby, File.join(ROOT, "tools/validate_general_english.rb")]
  ],
  [
    "validate glyph and MIDI presentation",
    [ruby, File.join(ROOT, "tools/validate_glyph_audio.rb")]
  ],
  [
    "validate carrier-driven character visemes",
    [node, File.join(ROOT, "tools/validate_viseme_performance.mjs")]
  ],
  [
    "audit game and story English translation profile",
    [node, File.join(ROOT, "tools/audit_game_story_translation.mjs")]
  ],
  [
    "validate translator workbench product application",
    [ruby, File.join(ROOT, "tools/validate_product_application.rb")]
  ],
  [
    "validate translator workbench frontend syntax",
    ["sh", File.join(ROOT, "tools/check_product_frontend.sh")]
  ],
  [
    "validate translator workbench over real localhost HTTP",
    [ruby, File.join(ROOT, "tools/test_product_http.rb")]
  ],
  [
    "validate the complete REP:000–222 family",
    [ruby, File.join(ROOT, "tools/validate_rep_000_222_soundness.rb"), "--mode", "canonical"]
  ],
  [
    "validate the complete LOG:000–222 family",
    [ruby, File.join(ROOT, "tools/validate_log_000_222_soundness.rb"), "--mode", "canonical"]
  ],
  [
    "validate the complete DAT:000–222 family",
    [ruby, File.join(ROOT, "tools/validate_dat_000_222_soundness.rb"), "--mode", "canonical"]
  ],
  [
    "validate the complete CRE:000–222 family",
    [ruby, File.join(ROOT, "tools/validate_cre_000_222_soundness.rb"), "--mode", "canonical"]
  ],
  [
    "validate the complete ORI:000–222 family",
    [ruby, File.join(ROOT, "tools/validate_ori_000_222_soundness.rb"), "--mode", "canonical"]
  ],
  [
    "validate the complete CON:000–222 family",
    [ruby, File.join(ROOT, "tools/validate_con_000_222_soundness.rb"), "--mode", "canonical"]
  ],
  [
    "validate the complete STR:000–222 family",
    [ruby, File.join(ROOT, "tools/validate_str_000_222_soundness.rb"), "--mode", "canonical"]
  ],
  [
    "validate the complete WRN:000–222 family",
    [ruby, File.join(ROOT, "tools/validate_wrn_000_222_soundness.rb"), "--mode", "canonical"]
  ]
]

results = commands.map do |label, command|
  stdout, stderr, status = Open3.capture3(*command, chdir: ROOT)
  puts "#{label}: #{status.success? ? "PASS" : "FAIL"}"
  puts stdout unless stdout.empty?
  warn stderr unless stderr.empty?
  { label: label, command: command, stdout: stdout, stderr: stderr, success: status.success? }
end

success = results.all? { |result| result.fetch(:success) }
report = +"# Era Zero Complete Regression Run\n\n"
report << "Status: **#{success ? "PASS — ALL CURRENT-STATE CHECKS SUCCEEDED" : "FAIL"}**\n\n"
report << "Run this complete regression from the project root with:\n\n"
report << "```text\nruby tools/regress_current_state.rb\n```\n\n"
report << "The command refreshes the current gap inventory, validates every active semantic authority layer, applies the reusable packet contract to the latest completed review packet (`#{last_packet}`), validates Gate 4A typed compounds, the Gate 4B canonical dictionary, and the Gate 4C English sense index, and runs full-family soundness audits for all complete canonical Creation, Data, Logic, Connection, Structure, Warning, Repair, and Origin families.\n\n"

results.each do |result|
  report << "## #{result.fetch(:success) ? "PASS" : "FAIL"} — #{result.fetch(:label)}\n\n"
  report << "```text\n#{result.fetch(:stdout).strip}\n```\n\n" unless result.fetch(:stdout).strip.empty?
  report << "```text\n#{result.fetch(:stderr).strip}\n```\n\n" unless result.fetch(:stderr).strip.empty?
end

report << "## Regression coverage\n\n"
report << "- all active canonical titles and invariant definitions;\n"
report << "- all #{migration_count} effective approval migrations and #{promotion_count} selective promotions;\n"
report << "- all 324 deterministic records and 2,592 generated-form assertions;\n"
report << "- immutable 36-root source-canonical fingerprint and replication;\n"
report << "- live #{canonical_count}/#{provisional_count} authority counts across lexicons and specifications;\n"
report << "- exact provisional complement and current #{remaining_chunks}-chunk gap inventory;\n"
report << "- withdrawn Gate 3 isolation;\n"
report << "- prohibited dependencies and translator gate boundaries;\n"
report << "- the latest detailed semantic packet's candidates, scores, definitions, boundaries, collisions, examples, and stress tests.\n"
report << "- Gate 4A single-head graph structure, node and edge typing, semantic roles, scope, runtime separation, serialization, versioning, 12 valid cases, 23 invalid diagnostics, and zero dictionary entries.\n"
report << "- Gate 4B content-derived compound identities, graph connectivity, canonical-atom references, semantic records, three-direction scored review, atom-collision discipline, gap honesty, IR deferrals, authority integration, and atomic immutability.\n"
report << "- Gate 4C exact atom and compound label coverage, typed sense routes, explicit polysemy, gap/grammar/IR routing, controlled-input boundaries, index integrity, authority integration, and atomic/compound immutability.\n"
report << "- Gate 4D route partitioning, coverage arithmetic, family and compound coverage, high-frequency benchmarks, explicit gap and ambiguity registers, no-first-match policy, source fingerprinting, and translator boundary.\n"
report << "- Gate 4E complete atomic and compound derivation coverage, exact generated forms and invariant semantics, source/review provenance, compound graph and digest identity, English-label independence, and no-fictional-ancestry policy.\n"
report << "- semantic IR graph typing, lexical occurrence authority, runtime/polarity/modality/time separation, roles, scope, quantity, measurement, transitions, coordination, seriality, parallelism, repetition, recursion, coreference, errors, canonical identity, and later-gate isolation.\n"
report << "- deterministic atom and compound rendering, required compound-slot bindings, generated forms, note paths, runtime endings, role registers, speech-act and secondary contours, structural timing, literal glosses, exact inverse decoding, corruption rejection, and transposition-invariant identity.\n"
report << "- controlled-English grammar restriction, unique canonical sense mapping, explicit roles and scope, open compound-slot enforcement, structured unsupported-input errors, golden translations, all 352 lexical routes, and full compiler-to-renderer-to-decoder round trips.\n"
report << "- general-English deterministic ranking, exact-lemma recall across all 436 indexed senses, evidence and confidence, runtime alternatives, material ambiguity, structural and grammar routing, explicit gaps, role clarification, conservative auto-resolution, and selected-sense round trips.\n"
report << "- validated EZF-1 to accessible SVG and Standard MIDI, deterministic byte output, three-anchor transposition behavior, all 972 atom/runtime presentations, invalid-input rejection, example artifacts, and semantic-identity preservation.\n"
report << "- carrier-driven character visemes across all 324 atoms and all 5,265 hosted formal variants, with independent base-head, happy/sad/angry eye, and timed mouth-sound layers; complete syllable coverage; note preservation; cue timing; grammatical-tone sustain; and transposition invariance.\n"
report << "- game/story English routing across care, need, nourishment, rest, health, discovery, participant references, labeled nouns, disclosed generalizations, explicit semantic gaps, and rejection of phonemic fallback for unknown verbs and descriptors.\n"
report << "- local translator API and responsive workbench, reviewed-sense evaluation corpus, conservative clarification journeys, API error paths, EZB-1 import/export integrity, SVG/MIDI download, accessibility markers, and canonical semantic immutability.\n"
report << "- full-family locus/process/affordance-relation separation, triplet coherence, runtime-state tailoring, collision routing, and rerun safety for `CON:000–222`.\n"
report << "- constituent-position/interface/composite-arrangement entities; reconfiguration/incorporation/integration processes; matching reconfigurability/incorporability/integrability affordances; triplet coherence; lexical/runtime separation; collision routing; layer non-entailment; and rerun safety for `STR:000–222`.\n"
report << "- intrinsic-fault/external-hazard/distributed-fault entity separation, persistence/manifestation/dormancy coherence, lexical/runtime separation, collision routing, and rerun safety for `WRN:000–022`.\n"
report << "- internal/target/shared restoration-condition entities; inward/target/systemic restorative processes; matching recoverability/applicability/pathway affordances; triplet coherence; lexical/runtime separation; collision routing; layer non-entailment; and rerun safety for `REP:000–222`.\n"
report << "- internal formal criteria, target-directed formal constraints, and shared formal regimes; persistent/operative/dormant coherence; lexical/runtime separation; collision routing; and rerun safety for `LOG:000–022`.\n"
report << "- internal generative patterns, generated artifacts, and shared generative repertoires as entities; internal pattern formation, outward artifact generation, and systemic co-generation as productive processes; internal pattern-forming capacities, source-artifact generative relations, and systemic co-generative capacities as affordances; triplet coherence; lexical/runtime separation; collision routing; layer non-entailment; and rerun safety for `CRE:000–222`.\n"
report << "- source-ground, distinct-existence, and shared-world conditions; persistent/occurrent-or-operative/latent coherence; separation from cause, time, truth, observation, substrate, and modality; lexical/runtime separation; collision routing; and rerun safety for `ORI:000–022`.\n"
report << "- source-ground establishment, distinct actualization, and shared-world transition processes; completed/active/nonactualized coherence; condition/process separation; nonactualization neutrality; collision routing; and rerun safety for `ORI:100–122`.\n"
report << "- source-grounding capacity, target-ground dependence, and shared-world constraint relations; persistent/operative/latent coherence; three-layer separation; latency neutrality; collision routing; and rerun safety for `ORI:200–222`.\n"
EraZeroValidation.write("reports/regression_run.md", report)

exit(success ? 0 : 1)
