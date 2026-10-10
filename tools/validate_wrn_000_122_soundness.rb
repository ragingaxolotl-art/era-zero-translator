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
  parser.banner = "Usage: ruby tools/validate_wrn_000_122_soundness.rb [--mode review|canonical]"
  parser.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode }
end.parse!

entity_ids = EraZeroValidation.ids_for_range("WRN:000–022")
process_ids = EraZeroValidation.ids_for_range("WRN:100–122")
all_ids = entity_ids + process_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
entity_spec = EraZeroValidation.load_yaml("reviews/WRN_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/WRN_100_122_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/WRN_100_122_scored_candidates.yaml")
entity_stress = EraZeroValidation.load_yaml("reviews/WRN_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/WRN_100_122_stress_tests.yaml").fetch("tests")
entity_roots = entity_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
process_roots = process_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scores.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
statuses = process_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options.fetch(:mode)
mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "WRN:000–022 stays canonical and WRN:100–122 has one requested authority state",
           entity_ids.all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))

checks.add("exact layer scope", "the cumulative audit covers exactly eighteen WRN roots",
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

checks.add("entity/process separation", "WRN:0xx names adverse conditions while WRN:1xx names adverse transformations",
           entity_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_0").include?("entity or condition") } &&
             process_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_1").include?("adverse process") })

checks.add("entity overlap logic", "persistent conditions are manifestation-neutral while manifest and dormant siblings are time-indexed alternatives",
           %w[WRN:000 WRN:010 WRN:020].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("may co-occur") } &&
             %w[WRN:001 WRN:002 WRN:011 WRN:012 WRN:021 WRN:022].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("mutually exclusive") })

checks.add("internal-degradation triplet", "WRN:100–102 changes only phase of internally originating adverse transformation",
           %w[WRN:100 WRN:101 WRN:102].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("adverse transformation originating within one reference entity") && definition.include?("less acceptable condition")
           end)

checks.add("target-impairment triplet", "WRN:110–112 changes only phase of one-source one-target impairment",
           %w[WRN:110 WRN:111 WRN:112].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("one distinct source") && definition.include?("one reference target") && definition.include?("less acceptable condition")
           end)

checks.add("systemic-propagation triplet", "WRN:120–122 changes only phase of one correlated adverse condition becoming distributed",
           %w[WRN:120 WRN:121 WRN:122].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("one correlated adverse condition") && definition.include?("distributed across multiple participant entities") && definition.include?("shared system")
           end)

checks.add("scope separation", "inward origin, distinct source-target causation, and correlated multi-participant distribution remain disjoint",
           %w[WRN:100 WRN:101 WRN:102].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("without requiring a distinct external source") } &&
             %w[WRN:110 WRN:111 WRN:112].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("source remains distinct from one target") } &&
             %w[WRN:120 WRN:121 WRN:122].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("same correlated adverse condition") })

checks.add("argument-role discipline", "examples expose condition, source, or participant roles according to the second trit",
           %w[WRN:100 WRN:101 WRN:102].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("CONDITION=") } &&
             %w[WRN:110 WRN:111 WRN:112].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("SOURCE=") } &&
             %w[WRN:120 WRN:121 WRN:122].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("PARTICIPANTS=") })

phase_prefixes = {
  "WRN:100" => "Completion of", "WRN:101" => "An ongoing", "WRN:102" => "A nonactualized",
  "WRN:110" => "Completion of", "WRN:111" => "An ongoing", "WRN:112" => "A nonactualized",
  "WRN:120" => "Completion of", "WRN:121" => "An ongoing", "WRN:122" => "A nonactualized"
}.freeze
checks.add("third-trit discipline", "completed, active, and nonactualized process phases are expressed exactly",
           phase_prefixes.all? { |id, prefix| process_roots.fetch(id).fetch("invariant_definition").start_with?(prefix) })

checks.add("nonactualized discipline", "lexical 1x2 invariants do not encode planning, scheduling, queues, permission, probability, or futurity",
           %w[WRN:102 WRN:112 WRN:122].all? do |id|
             text = [process_roots.fetch(id).fetch("proposed_title"), process_roots.fetch(id).fetch("invariant_definition")].join(" ")
             text.include?("nonactualized") && !text.match?(/plan|schedul|queue|stage|ready|intend|future|permit|probab/i)
           end)

checks.add("nonactualized title guard", "each 1x2 root explicitly separates nonactualization from modality and runtime uncertainty",
           %w[WRN:102 WRN:112 WRN:122].all? do |id|
             guard = process_roots.fetch(id).fetch("catalogue_title_guard")
             guard.include?("nonactualized") && guard.include?("probability") && guard.include?("schedule") && guard.include?("future time")
           end)

forbidden = /diagnos|detect|monitor|warn|signal|alert|isolat|contain|shutdown|repair|recover|schedul|plan|probab|blame|severity/i
checks.add("collision-free invariants", "process invariants exclude diagnosis, signaling, control, recovery, planning, probability, blame, and severity",
           process_roots.values.none? { |root| root.fetch("invariant_definition").match?(forbidden) })

checks.add("condition/process anchoring", "each process column contrasts with the matching canonical condition column",
           %w[WRN:100 WRN:101 WRN:102].all? { |id| process_roots.fetch(id).fetch("same_family_contrast").include?("intrinsic faults") } &&
             %w[WRN:110 WRN:111 WRN:112].all? { |id| process_roots.fetch(id).fetch("same_family_contrast").include?("distinct external hazards") } &&
             %w[WRN:120 WRN:121 WRN:122].all? { |id| process_roots.fetch(id).fetch("same_family_contrast").include?("correlated distributed faults") })

checks.add("completed-result discipline", "completion adds no persistence, present manifestation, evidence, severity, containment, or repair",
           %w[WRN:100 WRN:110 WRN:120].all? do |id|
             text = process_roots.fetch(id).fetch("same_family_contrast")
             text.include?("reached completion at the reference time") && text.include?("does not entail persistent fault identity") && text.include?("containment") && text.include?("repair")
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
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["WRN"]).to_set && comparisons.values.all? { |value| value.length >= 110 }
           end)

checks.add("example coverage", "each process root has six typed examples with state, contour, registers, and a counterexample",
           process_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per root produce the adverse-transformation winner uniquely",
           process_ids.all? do |id|
             record = score_roots.fetch(id)
             candidates = record.fetch("candidates")
             best = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == best }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "adverse_transformation" &&
               record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)

checks.add("coverage routing", "at least seventy-five unique English concepts use varied, non-forced routes",
           process_stress.length >= 75 && process_stress.map { |test| test.fetch("english_concept") }.uniq.length == process_stress.length &&
             process_stress.map { |test| test.fetch("routing") }.uniq.length >= 10 && process_stress.all? { |test| test.fetch("analysis").length >= 35 })

required_stress = [
  "fault condition versus degradation", "hazard versus target impairment", "distributed fault versus propagation",
  "many unrelated failures", "broadcast warning", "incident closure", "nonactualized versus uncertain",
  "completed impairment with recovered target", "unknown adverse criterion", "beneficial stress"
].freeze
checks.add("focused semantic stress", "coverage includes condition/process, scope, modality, recovery, communication, and evaluative-boundary tests",
           required_stress.all? { |concept| process_stress.any? { |test| test["english_concept"] == concept } })

packet_paths = Dir[File.join(ROOT, "reviews/{WRN_000_022,WRN_100_122}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_wrn_000_022_review.rb build_wrn_100_122_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "both WRN packet builders are idempotent in #{mode} mode", builders_ok && before == after)

checks.add("canonical entity alignment", "canonical WRN:000–022 titles and invariants match the live lexicon",
           entity_ids.all? do |id|
             atom = atoms.fetch(id)
             root = entity_roots.fetch(id)
             atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
           end)

if mode == "canonical"
  checks.add("canonical process alignment", "approved WRN:100–122 titles and invariants match the live lexicon",
             process_ids.all? do |id|
               atom = atoms.fetch(id)
               root = process_roots.fetch(id)
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional WRN:100–122 roots",
             process_spec.dig("metadata", "roots_canonicalized").to_a.empty? && process_roots.values.none? { |root| root["canonicalized"] })
end

checks.add("prior approval immutability", "the WRN:000–022 delegated approval migration remains byte-identical",
           Digest::SHA256.file(File.join(ROOT, "migrations/WRN_000_022_semantic_approval.yaml")).hexdigest == "589d7395d4b9f6956b9fcb2c724919200a8d6d9759408b74a5f4e4d0333eaaaf")

report = checks.markdown(
  title: "WRN:000–122 Combined Adverse-Condition/Transformation Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL WARNING CONDITION AND PROCESS LAYERS SOUND" : "PASS — WRN:100–122 READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**", "Roots audited: **18**", "Generated-form assertions: **144**",
    "Process runtime interpretations: **27**", "Stress tests: **#{entity_stress.length + process_stress.length}** (#{entity_stress.length} condition + #{process_stress.length} process)"
  ]
)
report << "\n## Required interpretation\n\n`WRN:0xx` identifies intrinsic faults, distinct external hazards, and correlated distributed faults. Its persistent member preserves condition identity independently of current manifestation. `WRN:1xx` identifies adverse transformation: inward degradation originates within one reference entity; outward impairment is caused in one target by one distinct source; systemic propagation distributes one correlated adverse condition across multiple participants. A completed process entails only completion at its reference time, not persistence, current manifestation, diagnosis, warning, containment, severity, blame, or repair. Lexical `1x2` is nonactualized only, while runtime `[2]/num` remains assertion-level uncertainty.\n\n"
report << "**#{checks.success? ? 'COMBINED WRN SOUNDNESS CONTRACT SATISFIED' : 'COMBINED WRN SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/WRN_000_122_soundness_audit.md", report)

puts "WRN:000–122 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
