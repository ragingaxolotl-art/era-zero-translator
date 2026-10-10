#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "open3"
require "optparse"
require "rbconfig"
require "set"
require_relative "lib/era_zero_validation"

include EraZeroValidation

options = { mode: "auto" }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby tools/validate_rep_000_122_soundness.rb [--mode review|canonical]"
  parser.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode }
end.parse!

entity_ids = EraZeroValidation.ids_for_range("REP:000–022")
process_ids = EraZeroValidation.ids_for_range("REP:100–122")
all_ids = entity_ids + process_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
entity_spec = EraZeroValidation.load_yaml("reviews/REP_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/REP_100_122_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/REP_100_122_scored_candidates.yaml")
entity_stress = EraZeroValidation.load_yaml("reviews/REP_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/REP_100_122_stress_tests.yaml").fetch("tests")
entity_roots = entity_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
process_roots = process_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scores.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
statuses = process_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options.fetch(:mode)
mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "REP:000–022 stays canonical and REP:100–122 has one requested authority state",
           entity_ids.all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))

checks.add("exact layer scope", "the cumulative audit covers exactly eighteen REP roots",
           entity_roots.keys == entity_ids && process_roots.keys == process_ids && all_ids.uniq.length == 18)

checks.add("generated-form integrity", "all 144 fixed-field assertions match deterministic address algorithms",
           all_ids.all? do |id|
             root = entity_roots[id] || process_roots[id]
             root.fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atoms.fetch(id))
           end)

checks.add("semantic uniqueness", "all titles and invariant definitions are nonempty and unique",
           begin
             roots = entity_roots.values + process_roots.values
             titles = roots.map { |root| root.fetch("proposed_title") }
             definitions = roots.map { |root| root.fetch("invariant_definition") }
             titles.uniq.length == 18 && definitions.uniq.length == 18 && definitions.all? { |definition| definition.end_with?(".") }
           end)

checks.add("entity/process separation", "REP:0xx names restoration conditions while REP:1xx names restorative transformations",
           entity_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_0").include?("entity or condition") } &&
             process_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_1").include?("restorative process") })

checks.add("entity overlap logic", "persistent conditions are realization-neutral while manifest and dormant siblings are time-indexed alternatives",
           %w[REP:000 REP:010 REP:020].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("may co-occur") } &&
             %w[REP:001 REP:002 REP:011 REP:012 REP:021 REP:022].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("mutually exclusive") })

checks.add("internal-restoration triplet", "REP:100–102 changes only phase of internally originating restorative transformation",
           %w[REP:100 REP:101 REP:102].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("restorative transformation originating within one reference entity") && definition.include?("internal restoration condition")
           end)

checks.add("target-restoration triplet", "REP:110–112 changes only phase of one-source one-target restoration",
           %w[REP:110 REP:111 REP:112].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("one distinct source") && definition.include?("one reference target") && definition.include?("target restoration condition")
           end)

checks.add("systemic-restoration triplet", "REP:120–122 changes only phase of one coordinated shared restoration",
           %w[REP:120 REP:121 REP:122].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("coordinated restorative transformation") && definition.include?("shared restoration condition") &&
               definition.include?("multiple participant entities") && definition.include?("shared system")
           end)

checks.add("scope separation", "inward origin, distinct source-target causation, and coordinated multi-participant realization remain disjoint",
           %w[REP:100 REP:101 REP:102].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("without requiring a distinct external source") } &&
             %w[REP:110 REP:111 REP:112].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("source remains distinct from one target") } &&
             %w[REP:120 REP:121 REP:122].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("one shared restoration condition") })

checks.add("argument-role discipline", "examples expose condition, source, or participant roles according to the second trit",
           %w[REP:100 REP:101 REP:102].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("CONDITION=") } &&
             %w[REP:110 REP:111 REP:112].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("SOURCE=") } &&
             %w[REP:120 REP:121 REP:122].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("PARTICIPANTS=") })

phase_prefixes = {
  "REP:100" => "Completion of", "REP:101" => "An ongoing", "REP:102" => "A nonactualized",
  "REP:110" => "Completion of", "REP:111" => "An ongoing", "REP:112" => "A nonactualized",
  "REP:120" => "Completion of", "REP:121" => "An ongoing", "REP:122" => "A nonactualized"
}.freeze
checks.add("third-trit discipline", "completed, active, and nonactualized process phases are expressed exactly",
           phase_prefixes.all? { |id, prefix| process_roots.fetch(id).fetch("invariant_definition").start_with?(prefix) })

checks.add("nonactualized discipline", "lexical 1x2 invariants do not encode planning, scheduling, queues, permission, probability, or futurity",
           %w[REP:102 REP:112 REP:122].all? do |id|
             text = [process_roots.fetch(id).fetch("proposed_title"), process_roots.fetch(id).fetch("invariant_definition")].join(" ")
             text.include?("nonactualized") && !text.match?(/plan|schedul|queue|stage|ready|intend|future|permit|probab/i)
           end)

checks.add("nonactualized title guard", "each 1x2 root explicitly separates nonactualization from modality and runtime uncertainty",
           %w[REP:102 REP:112 REP:122].all? do |id|
             guard = process_roots.fetch(id).fetch("catalogue_title_guard")
             guard.include?("nonactualized") && guard.include?("probability") && guard.include?("schedule") && guard.include?("future time")
           end)

forbidden = /maintain|inspect|validat|certif|record|checkpoint|backup|replace|reconstruct|resource|schedul|plan|probab|ready|intend/i
checks.add("collision-free invariants", "process invariants exclude maintenance, validation, records, replacement, resources, planning, probability, and scheduling",
           process_roots.values.none? { |root| root.fetch("invariant_definition").match?(forbidden) })

checks.add("condition/process anchoring", "each process column contrasts with the matching canonical condition column",
           process_roots.values.all? do |root|
             text = root.fetch("same_family_contrast")
             text.include?("REP:0xx owns internal, target, and shared restoration-condition entities") &&
               text.include?("REP:1xx owns restorative transformations") && text.include?("REP:2xx")
           end)

checks.add("completed-result discipline", "completion realizes the condition without adding result persistence, records, validation, maintenance, or affordance",
           %w[REP:100 REP:110 REP:120].all? do |id|
             text = process_roots.fetch(id).fetch("same_family_contrast")
             text.include?("condition was realized") && text.include?("does not entail that the result persists") &&
               text.include?("recorded or validated") && text.include?("maintenance") && text.include?("REP:2xx")
           end)

checks.add("boundary completeness", "every process root has substantial inclusion, exclusions, and same-family contrasts",
           process_roots.values.all? do |root|
             root.fetch("inclusion_boundary").length >= 400 && root.fetch("excluded_meanings").length >= 6 &&
               root.fetch("nearest_neighbors").length >= 6 && root.fetch("same_family_contrast").length >= 450
           end)

checks.add("runtime tailoring", "all 27 process runtime meanings are specific and preserve lexical/runtime separation",
           process_roots.values.all? do |root|
             states = root.fetch("runtime_state_interpretation")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && states.values.all? { |value| value.length >= 130 } &&
               root.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`")
           end)

checks.add("cross-family routing", "every process root distinguishes all eleven competing families",
           process_roots.values.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["REP"]).to_set && comparisons.values.all? { |value| value.length >= 85 }
           end)

checks.add("example coverage", "each process root has six typed examples with state, contour, registers, and a counterexample",
           process_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per root produce the restorative-transformation winner uniquely",
           process_ids.all? do |id|
             record = score_roots.fetch(id)
             candidates = record.fetch("candidates")
             best = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == best }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "restorative_transformation" &&
               record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)

checks.add("coverage routing", "at least seventy-five unique English concepts use varied, non-forced routes",
           process_stress.length >= 75 && process_stress.map { |test| test.fetch("english_concept") }.uniq.length == process_stress.length &&
             process_stress.map { |test| test.fetch("routing") }.uniq.length >= 10 && process_stress.all? { |test| test.fetch("analysis").length >= 35 })

required_stress = [
  "restoration versus condition", "restoration versus recoverability", "restoration versus adverse process",
  "many independent repairs", "coordination without restoration", "repair plan", "nonactualized versus uncertain",
  "repair failed", "restore point", "restoration versus maintenance"
].freeze
checks.add("focused semantic stress", "coverage includes condition/process, scope, modality, recoverability, coordination, and completion-boundary tests",
           required_stress.all? { |concept| process_stress.any? { |test| test["english_concept"] == concept } })

packet_paths = Dir[File.join(ROOT, "reviews/{REP_000_022,REP_100_122}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_rep_000_022_review.rb build_rep_100_122_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "both REP packet builders are idempotent in #{mode} mode", builders_ok && before == after)

checks.add("canonical entity alignment", "canonical REP:000–022 titles and invariants match the live lexicon",
           entity_ids.all? do |id|
             atom = atoms.fetch(id)
             root = entity_roots.fetch(id)
             atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
           end)

if mode == "canonical"
  checks.add("canonical process alignment", "approved REP:100–122 titles and invariants match the live lexicon",
             process_ids.all? do |id|
               atom = atoms.fetch(id)
               root = process_roots.fetch(id)
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional REP:100–122 roots",
             process_spec.dig("metadata", "roots_canonicalized").to_a.empty? && process_roots.values.none? { |root| root["canonicalized"] })
end

checks.add("prior approval immutability", "the REP:000–022 delegated approval migration remains byte-identical",
           Digest::SHA256.file(File.join(ROOT, "migrations/REP_000_022_semantic_approval.yaml")).hexdigest == "21f3909f3f52bbd0f1b1ba916de1a1adf91a270a7001b1b91f6c8e1ae8d1db16")

report = checks.markdown(
  title: "REP:000–122 Combined Restoration-Condition/Transformation Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL REPAIR CONDITION AND PROCESS LAYERS SOUND" : "PASS — REP:100–122 READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**", "Roots audited: **18**", "Generated-form assertions: **144**",
    "Process runtime interpretations: **27**", "Stress tests: **#{entity_stress.length + process_stress.length}** (#{entity_stress.length} condition + #{process_stress.length} process)"
  ]
)
report << "\n## Required interpretation\n\n`REP:0xx` identifies internal, target, and shared restoration conditions. Its persistent member preserves condition identity independently of present realization. `REP:1xx` identifies restorative transformation: inward restoration originates within one reference entity; outward restoration is caused in one target by one distinct source; systemic restoration coordinates realization of one shared restoration condition across multiple participants. A completed process entails realization of the applicable condition at completion, not persistence of the result, a record, validation, maintenance, replacement, or continuing recoverability. Lexical `1x2` is nonactualized only, while runtime `[2]/num` remains assertion-level uncertainty.\n\n"
report << "**#{checks.success? ? 'COMBINED REP SOUNDNESS CONTRACT SATISFIED' : 'COMBINED REP SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/REP_000_122_soundness_audit.md", report)

puts "REP:000–122 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
