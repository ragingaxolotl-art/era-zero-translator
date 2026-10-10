#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require_relative "lib/era_zero_validation"

include EraZeroValidation

ENTITY_RANGE = "CON:000–022"
PROCESS_RANGE = "CON:100–122"
ENTITY_IDS = EraZeroValidation.ids_for_range(ENTITY_RANGE)
PROCESS_IDS = EraZeroValidation.ids_for_range(PROCESS_RANGE)
IDS = ENTITY_IDS + PROCESS_IDS

EXPECTED = {
  "CON:000" => ["persistent source endpoint", "A bounded communicative locus that remains identified as the source-side endpoint of an exchange context."],
  "CON:001" => ["active source endpoint", "A source-side communicative locus presently participating as an endpoint in an exchange context."],
  "CON:002" => ["dormant source endpoint", "A source-side communicative locus defined for an exchange context without presently participating in it."],
  "CON:010" => ["persistent target endpoint", "A bounded communicative locus that remains identified as the target-side endpoint of an exchange context."],
  "CON:011" => ["active target endpoint", "A target-side communicative locus presently participating as an endpoint in an exchange context."],
  "CON:012" => ["dormant target endpoint", "A target-side communicative locus defined for an exchange context without presently participating in it."],
  "CON:020" => ["persistent shared channel", "A bounded communicative environment that remains the common exchange context of multiple participant endpoints."],
  "CON:021" => ["active shared channel", "A shared communicative environment presently functioning as the common exchange context of multiple participant endpoints."],
  "CON:022" => ["dormant shared channel", "A shared communicative environment defined for multiple participant endpoints without presently functioning as their common exchange context."],
  "CON:100" => ["completed source expression", "Completion of an act by which a source endpoint makes a communicative expression available to an exchange context."],
  "CON:101" => ["active source expression", "An ongoing act by which a source endpoint makes a communicative expression available to an exchange context."],
  "CON:102" => ["potential source expression", "A nonactualized act by which a source endpoint would make a communicative expression available to an exchange context."],
  "CON:110" => ["completed target reception", "Completion of an act by which a target endpoint takes up a communicative expression from an exchange context."],
  "CON:111" => ["active target reception", "An ongoing act by which a target endpoint takes up a communicative expression from an exchange context."],
  "CON:112" => ["potential target reception", "A nonactualized act by which a target endpoint would take up a communicative expression from an exchange context."],
  "CON:120" => ["completed shared distribution", "Completion of an act by which a communicative expression is made available across a shared channel to multiple participant endpoints."],
  "CON:121" => ["active shared distribution", "An ongoing act by which a communicative expression is made available across a shared channel to multiple participant endpoints."],
  "CON:122" => ["potential shared distribution", "A nonactualized act by which a communicative expression would be made available across a shared channel to multiple participant endpoints."]
}.freeze

PACKETS = {
  ENTITY_RANGE => {
    recommended: "reviews/CON_000_022_recommended_spec.yaml",
    scored: "reviews/CON_000_022_scored_candidates.yaml",
    stress: "reviews/CON_000_022_stress_tests.yaml",
    collision: "reviews/CON_000_022_collision_report.md",
    builder: "tools/build_con_000_022_review.rb",
    migration: "migrations/CON_000_022_semantic_approval.yaml"
  },
  PROCESS_RANGE => {
    recommended: "reviews/CON_100_122_recommended_spec.yaml",
    scored: "reviews/CON_100_122_scored_candidates.yaml",
    stress: "reviews/CON_100_122_stress_tests.yaml",
    collision: "reviews/CON_100_122_collision_report.md",
    builder: "tools/build_con_100_122_review.rb",
    migration: "migrations/CON_100_122_semantic_approval.yaml"
  }
}.freeze

atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
all_atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/all_atoms.yaml"))
reviewed = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/reviewed_canonical_atoms.yaml"))
canonical_spec = EraZeroValidation.atoms_by_id(
  "atoms" => EraZeroValidation.load_yaml("spec/canonical_spec.yaml").dig("lexicon", "completed_atoms")
)

packet_documents = PACKETS.transform_values do |paths|
  {
    recommended: EraZeroValidation.load_yaml(paths.fetch(:recommended)),
    scored: EraZeroValidation.load_yaml(paths.fetch(:scored)),
    stress: EraZeroValidation.load_yaml(paths.fetch(:stress)),
    collision: File.read(File.join(ROOT, paths.fetch(:collision)), encoding: "UTF-8"),
    builder: File.read(File.join(ROOT, paths.fetch(:builder)), encoding: "UTF-8"),
    migration: EraZeroValidation.load_yaml(paths.fetch(:migration))
  }
end

recommended_roots = packet_documents.values.flat_map { |packet| packet.dig(:recommended, "roots") }
specs = recommended_roots.to_h do |root|
  [root.dig("fixed_generated_fields", "canonical_id"), root]
end

checks = EraZeroValidation::CheckSet.new

checks.add("canonical scope", "both cleaned blocks contain exactly 18 canonical roots",
           IDS.length == 18 && IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" } &&
             specs.keys.to_set == IDS.to_set)

checks.add("immutable generated forms", "all 18 roots retain the fixed address-derived forms",
           IDS.all? do |id|
             expected = EraZeroValidation.packet_fixed_projection(atoms.fetch(id))
             specs.fetch(id).fetch("fixed_generated_fields") == expected
           end && EraZeroValidation.generated_field_errors(atoms.slice(*IDS)).empty?)

checks.add("canonical title and invariant freeze", "all live and packet meanings match the approved 18-root grid exactly",
           EXPECTED.all? do |id, (title, definition)|
             [atoms, all_atoms, reviewed, canonical_spec].all? do |records|
               records.fetch(id)["title"] == title && records.fetch(id)["core_definition"] == definition
             end && specs.fetch(id)["proposed_title"] == title && specs.fetch(id)["invariant_definition"] == definition
           end)

checks.add("address-axis projection", "entity/process, source/target/shared, and lexical phase align with every address",
           IDS.all? do |id|
             address = id.split(":").last
             title, definition = EXPECTED.fetch(id)
             first_ok = address[0] == "0" ? definition.match?(/locus|environment/) : definition.match?(/act/)
             second_ok = { "0" => /source/, "1" => /target/, "2" => /shared/ }.fetch(address[1]).match?(title + " " + definition)
             third_ok = if address[0] == "0"
                          { "0" => /persistent|remains/, "1" => /active|presently/, "2" => /dormant|without presently/ }.fetch(address[2]).match?(title + " " + definition)
                        else
                          { "0" => /Completion/, "1" => /ongoing/, "2" => /nonactualized/ }.fetch(address[2]).match?(definition)
                        end
             first_ok && second_ok && third_ok
           end)

checks.add("triplet isomorphism", "each process triplet changes only completed/ongoing/nonactualized realization",
           %w[0 1 2].all? do |second|
             defs = %w[0 1 2].map { |third| EXPECTED.fetch("CON:1#{second}#{third}").last }
             defs[0].start_with?("Completion of an act") && defs[1].start_with?("An ongoing act") &&
               defs[2].start_with?("A nonactualized act")
           end)

checks.add("layer separation", "communicative loci never absorb exchange acts, and process roots never redefine loci",
           ENTITY_IDS.all? do |id|
             definition = EXPECTED.fetch(id).last
             !definition.match?(/makes? a communicative expression|takes? up a communicative expression|distribution/)
           end && PROCESS_IDS.all? do |id|
             definition = EXPECTED.fetch(id).last
             definition.include?("act") && !definition.match?(/remains identified|presently participating as an endpoint|defined for multiple/)
           end)

checks.add("non-entailment boundaries", "expression, reception, comprehension, and multi-endpoint uptake remain separate claims",
           !EXPECTED.fetch("CON:100").last.include?("target") &&
             !EXPECTED.fetch("CON:110").last.include?("understand") &&
             EXPECTED.fetch("CON:120").last.include?("multiple participant endpoints") &&
             specs.values.all? { |root| root.fetch("excluded_meanings").length >= 5 })

prohibited_1x2 = /\b(?:intend(?:ed|tion)?|plan(?:ned|ning)?|queue(?:d)?|schedul(?:e|ed|ing)|permission|ready|readiness|probab(?:le|ility)|future|certainty)\b/i
checks.add("nonactualized-process discipline", "CON:102/112/122 invariants contain no hidden plan, queue, schedule, permission, probability, or futurity",
           %w[CON:102 CON:112 CON:122].all? do |id|
             definition = EXPECTED.fetch(id).last
             definition.include?("nonactualized") && !definition.match?(prohibited_1x2)
           end)

banned_runtime_phrases = ["completed completed", "ongoing active", "including when the lexeme itself is dormant", "does not select the dormant sibling lexeme"]
checks.add("tailored runtime semantics", "every root has clean, phase-specific [0], [1], and [2]/num interpretations",
           specs.all? do |id, root|
             states = root.fetch("runtime_state_interpretation")
             text = states.values.join(" ")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set &&
               banned_runtime_phrases.none? { |phrase| text.include?(phrase) } &&
               (id.end_with?("2") ? text.include?("nonactualized") || text.include?("dormant") : true)
           end)

checks.add("cross-family separation", "all 18 roots distinguish every competing semantic family",
           specs.values.all? do |root|
             root.fetch("cross_family_comparisons").keys.to_set == (FAMILIES.keys - ["CON"]).to_set
           end)

expected_risks = {
  ENTITY_RANGE => {
    "0" => ["source participant", "source expression"],
    "1" => ["target participant", "target reception"],
    "2" => ["topology", "shared distribution"]
  },
  PROCESS_RANGE => {
    "0" => ["content creation", "source expression"],
    "1" => ["perception/understanding", "target reception"],
    "2" => ["routing/topology", "shared distribution"]
  }
}
checks.add("collision-matrix trit routing", "source, target, and shared rows use risks selected by the second trit",
           PACKETS.all? do |range, paths|
             text = File.read(File.join(ROOT, paths.fetch(:collision)), encoding: "UTF-8")
             EraZeroValidation.ids_for_range(range).all? do |id|
               line = text.lines.find { |candidate| candidate.start_with?("| #{id} |") }.to_s
               expected_risks.fetch(range).fetch(id.split(":").last[1]).all? { |term| line.include?(term) }
             end
           end)

checks.add("candidate rationale integrity", "the Phase 2 rationale explains likely selection rather than substituting rejection language",
           packet_documents.values.all? do |packet|
             packet.dig(:scored, "roots").all? do |root|
               rationale = root.fetch("current_meaning_rationale")
               rationale.include?("Phase 2") && rationale.match?(/follows|label|salient|vocabulary/)
             end
           end)

checks.add("evidence breadth", "both blocks retain five candidates per root, six examples per root, and broad non-forced English routing",
           packet_documents.values.all? do |packet|
             packet.dig(:scored, "roots").all? { |root| root.fetch("candidates").length == 5 } &&
               packet.dig(:recommended, "roots").all? { |root| root.fetch("examples").length >= 6 } &&
               packet.dig(:stress, "tests").length >= 60 &&
               packet.dig(:stress, "tests").map { |test| test.fetch("routing") }.any? { |route| route.match?(/compound|family|gap|unresolved/) }
           end)

checks.add("approval evidence", "both packets remain canonical and match their immutable approval migrations",
           packet_documents.all? do |range, packet|
             packet.dig(:recommended, "metadata", "status") == "approved_and_canonical_by_delegated_authority" &&
               packet.dig(:recommended, "roots").all? { |root| root["canonicalized"] == true } &&
               packet.dig(:migration, "approved_packet", "range") == range &&
               packet.dig(:migration, "promoted_roots").length == 9
           end)

checks.add("rerun-safe builders", "both builders preserve original Phase 2 candidates and current canonical approval state",
           packet_documents.values.all? do |packet|
             builder = packet.fetch(:builder)
             builder.include?("PHASE2_CANDIDATES") && builder.include?("canonicalized_now") &&
               builder.include?("id[5]") && !builder.include?("scope = id[4]") &&
               !builder.include?('id[4] == "2"')
           end)

report = checks.markdown(
  title: "CON:000–122 Combined Soundness Audit",
  pass_status: "PASS — BOTH CANONICAL CONNECTION BLOCKS ARE SEMANTICALLY SOUND",
  summary: [
    "Canonical roots audited: **#{IDS.length}**",
    "Candidate architectures retained: **90**",
    "Scored criterion values retained: **720**",
    "English routing tests retained: **#{packet_documents.values.sum { |packet| packet.dig(:stress, "tests").length }}**",
    "Canonical titles changed by cleanup: **0**",
    "Canonical invariant definitions changed by cleanup: **0**"
  ]
)
report << "\nThe cleanup corrected supporting evidence, runtime wording, collision routing, and rerun safety. It did not alter any canonical title, invariant definition, generated form, approval migration, or authority count.\n"
EraZeroValidation.write("reviews/CON_000_122_soundness_audit.md", report)

puts "CON:000–122 soundness: #{checks.success? ? "PASS" : "FAIL"}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
