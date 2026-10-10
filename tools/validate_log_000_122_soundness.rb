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
OptionParser.new { |parser| parser.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode } }.parse!

entity_ids = EraZeroValidation.ids_for_range("LOG:000–022")
process_ids = EraZeroValidation.ids_for_range("LOG:100–122")
all_ids = entity_ids + process_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
entity_spec = EraZeroValidation.load_yaml("reviews/LOG_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/LOG_100_122_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/LOG_100_122_scored_candidates.yaml")
entity_stress = EraZeroValidation.load_yaml("reviews/LOG_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/LOG_100_122_stress_tests.yaml").fetch("tests")
entity_roots = entity_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
process_roots = process_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scores.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
statuses = process_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options.fetch(:mode)
mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "LOG:000–022 stays canonical and LOG:100–122 has one requested authority state",
           entity_ids.all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))

checks.add("exact layer scope", "the cumulative audit covers exactly eighteen LOG roots",
           entity_roots.keys == entity_ids && process_roots.keys == process_ids && all_ids.uniq.length == 18)

checks.add("generated-form integrity", "all 144 fixed-field assertions match deterministic address algorithms",
           all_ids.all? do |id|
             root = entity_roots[id] || process_roots[id]
             EraZeroValidation.generated_field_errors({ id => atoms.fetch(id) }).empty? &&
               root.fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atoms.fetch(id))
           end)

checks.add("semantic uniqueness", "all eighteen titles and invariant definitions are nonempty and unique",
           begin
             roots = entity_roots.values + process_roots.values
             titles = roots.map { |root| root.fetch("proposed_title") }
             definitions = roots.map { |root| root.fetch("invariant_definition") }
             titles.uniq.length == 18 && definitions.uniq.length == 18 && definitions.all? { |definition| definition.end_with?(".") }
           end)

checks.add("entity/process separation", "LOG:0xx names formal constraints while LOG:1xx names admissibility-determining evaluations",
           entity_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_0").include?("formal rule or constraint entity") } &&
             process_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_1").include?("formal evaluation process") })

checks.add("entity overlap logic", "persistent constraints are operation-neutral while operative and dormant siblings are time-indexed alternatives",
           %w[LOG:000 LOG:010 LOG:020].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("may co-occur") } &&
             %w[LOG:001 LOG:002 LOG:011 LOG:012 LOG:021 LOG:022].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("mutually exclusive") })

checks.add("internal-evaluation triplet", "LOG:100–102 changes only the phase of one internal formal evaluation",
           %w[LOG:100 LOG:101 LOG:102].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("formal evaluation") && definition.include?("admissibility of one reference entity") &&
               definition.include?("applicable internal criterion")
           end)

checks.add("target-application triplet", "LOG:110–112 changes only the phase of one constraint applied to one distinct target",
           %w[LOG:110 LOG:111 LOG:112].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("one specified constraint") && definition.include?("one distinct reference target") &&
               definition.include?("target's admissibility")
           end)

checks.add("systemic-evaluation triplet", "LOG:120–122 changes only the phase of one coordinated joint evaluation",
           %w[LOG:120 LOG:121 LOG:122].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("coordinated formal evaluation") && definition.include?("joint admissibility") &&
               definition.include?("multiple participants") && definition.include?("shared formal regime")
           end)

checks.add("scope separation", "inward, target, and systemic evaluation scopes remain disjoint",
           %w[LOG:100 LOG:101 LOG:102].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("without requiring a distinct external target") } &&
             %w[LOG:110 LOG:111 LOG:112].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("one specified constraint and one distinct target") } &&
             %w[LOG:120 LOG:121 LOG:122].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("multiple participants under one shared regime") })

checks.add("argument-role discipline", "examples expose entity/criterion, target/constraint, or participant/regime roles by second trit",
           %w[LOG:100 LOG:101 LOG:102].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("ENTITY=") } &&
             %w[LOG:110 LOG:111 LOG:112].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("TARGET=") } &&
             %w[LOG:120 LOG:121 LOG:122].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("PARTICIPANTS=") })

phase_prefixes = {
  "LOG:100" => "Completion of", "LOG:101" => "An ongoing", "LOG:102" => "A nonactualized",
  "LOG:110" => "Completion of", "LOG:111" => "An ongoing", "LOG:112" => "A nonactualized",
  "LOG:120" => "Completion of", "LOG:121" => "An ongoing", "LOG:122" => "A nonactualized"
}.freeze
checks.add("third-trit discipline", "completed, active, and nonactualized evaluation phases are expressed exactly",
           phase_prefixes.all? { |id, prefix| process_roots.fetch(id).fetch("invariant_definition").start_with?(prefix) })

checks.add("nonactualized discipline", "lexical 1x2 invariants do not encode intention, scheduling, readiness, probability, uncertainty, or futurity",
           %w[LOG:102 LOG:112 LOG:122].all? do |id|
             text = [process_roots.fetch(id).fetch("proposed_title"), process_roots.fetch(id).fetch("invariant_definition")].join(" ")
             text.include?("nonactualized") && !text.match?(/intend|plan|schedul|queue|ready|future|probab|uncertain|possible|permit/i)
           end)

forbidden = /accept|reject|true|false|satisf|violat|validity|proof|correct|belief|record|store|execut|algorithm|enforc|authority|schedul|plan|probab|future/i
checks.add("result and collision neutrality", "process invariants exclude result polarity, truth, correctness, storage, implementation, authority, enforcement, and modality",
           process_roots.values.none? { |root| root.fetch("invariant_definition").match?(forbidden) })

checks.add("constraint/process anchoring", "each process root contrasts constraint entities, evaluations, and reserved LOG:2xx relations",
           process_roots.values.all? do |root|
             text = root.fetch("same_family_contrast")
             text.include?("LOG:0xx") && text.include?("formal constraint entities") && text.include?("LOG:1xx") &&
               text.include?("formal evaluation processes") && text.include?("LOG:2xx")
           end)

checks.add("completion neutrality", "completion determines an admissibility result without asserting its polarity or persistence",
           %w[LOG:100 LOG:110 LOG:120].all? do |id|
             root = process_roots.fetch(id)
             root.fetch("invariant_definition").include?("determin") &&
               root.fetch("inclusion_boundary").include?(id[5] == "0" ? "result polarity remain separate" : id[5] == "1" ? "pass/fail outcome remain separate" : "acceptance versus rejection")
           end)

checks.add("boundary completeness", "every process root has substantial inclusion, exclusions, neighbors, and same-family contrasts",
           process_roots.values.all? do |root|
             root.fetch("inclusion_boundary").length >= 300 && root.fetch("excluded_meanings").length >= 6 &&
               root.fetch("nearest_neighbors").length >= 6 && root.fetch("same_family_contrast").length >= 450
           end)

checks.add("runtime tailoring", "all 27 process runtime meanings are specific and preserve lexical/runtime separation",
           process_roots.values.all? do |root|
             states = root.fetch("runtime_state_interpretation")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && states.values.all? { |value| value.length >= 120 } &&
               root.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`")
           end)

checks.add("cross-family routing", "every process root distinguishes all eleven competing families",
           process_roots.values.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["LOG"]).to_set && comparisons.values.all? { |value| value.length >= 90 }
           end)

checks.add("example coverage", "each process root has six typed examples with state, contour, registers, and a counterexample",
           process_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per root produce the formal-evaluation winner uniquely",
           process_ids.all? do |id|
             record = score_roots.fetch(id)
             candidates = record.fetch("candidates")
             best = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == best }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "formal_evaluation_processes" &&
               record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)

checks.add("coverage routing", "at least one hundred unique process concepts use varied, non-forced routes",
           process_stress.length >= 100 && process_stress.map { |test| test.fetch("english_concept") }.uniq.length == process_stress.length &&
             process_stress.map { |test| test.fetch("routing") }.uniq.length >= 10 && process_stress.all? { |test| test.fetch("analysis").length >= 35 })

required_stress = [
  "evaluate", "check", "validate", "accept", "reject", "true", "prove", "run a program",
  "evaluation scheduled", "evaluation queued", "evaluation uncertain", "many independent checks",
  "joint compliance review", "rule evaluation versus rule", "result stored", "authorize"
].freeze
checks.add("focused semantic stress", "coverage tests rule/process, result, implementation, phase, scope, modality, and enforcement boundaries",
           required_stress.all? { |concept| process_stress.any? { |test| test["english_concept"] == concept } })

packet_paths = Dir[File.join(ROOT, "reviews/{LOG_000_022,LOG_100_122}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_log_000_022_review.rb build_log_100_122_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "both LOG packet builders are idempotent in #{mode} mode", builders_ok && before == after)

checks.add("canonical entity alignment", "canonical LOG:000–022 titles and invariants match the live lexicon",
           entity_ids.all? do |id|
             atom = atoms.fetch(id)
             root = entity_roots.fetch(id)
             atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
           end)

if mode == "canonical"
  checks.add("canonical process alignment", "approved LOG:100–122 titles and invariants match the live lexicon",
             process_ids.all? do |id|
               atom = atoms.fetch(id)
               root = process_roots.fetch(id)
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional LOG:100–122 roots",
             process_spec.dig("metadata", "roots_canonicalized").to_a.empty? && process_roots.values.none? { |root| root["canonicalized"] })
end

checks.add("prior approval immutability", "the LOG:000–022 delegated approval migration remains byte-identical",
           Digest::SHA256.file(File.join(ROOT, "migrations/LOG_000_022_semantic_approval.yaml")).hexdigest == "f61869790f33098780f9421cd61828dd27c692977ef1a98958a55192cd9c6cfb")

report = checks.markdown(
  title: "LOG:000–122 Combined Constraint-Entity/Evaluation-Process Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL LOGIC ENTITY AND PROCESS LAYERS SOUND" : "PASS — LOG:100–122 READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**", "Roots audited: **18**", "Generated-form assertions: **144**",
    "Process runtime interpretations: **27**", "Stress tests: **#{entity_stress.length + process_stress.length}** (#{entity_stress.length} entity + #{process_stress.length} process)"
  ]
)
report << "\n## Required interpretation\n\n`LOG:0xx` identifies formal constraint entities: one internal criterion, one target-directed constraint, or one shared formal regime. `LOG:1xx` identifies bounded evaluations that determine admissibility under those constraints: inward for one entity, outward for one specified constraint and target, or systemic for multiple participants under one regime. A completed evaluation entails that an admissibility result was determined, not acceptance, rejection, truth, correctness, persistence, recording, authority, or enforcement. Lexical `1x2` is nonactualized only; runtime `[2]/num` remains uncertainty about the selected phase assertion.\n\n"
report << "**#{checks.success? ? 'COMBINED LOG SOUNDNESS CONTRACT SATISFIED' : 'COMBINED LOG SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/LOG_000_122_soundness_audit.md", report)

puts "LOG:000–122 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
