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

entity_ids = EraZeroValidation.ids_for_range("DAT:000–022")
process_ids = EraZeroValidation.ids_for_range("DAT:100–122")
all_ids = entity_ids + process_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
entity_spec = EraZeroValidation.load_yaml("reviews/DAT_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/DAT_100_122_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/DAT_100_122_scored_candidates.yaml")
entity_stress = EraZeroValidation.load_yaml("reviews/DAT_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/DAT_100_122_stress_tests.yaml").fetch("tests")
entity_roots = entity_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
process_roots = process_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scores.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
statuses = process_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options.fetch(:mode)
mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "DAT entity roots stay canonical and process roots share the requested authority state",
           entity_ids.all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))
checks.add("exact layer scope", "the cumulative audit covers exactly eighteen DAT roots",
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
checks.add("entity/process separation", "DAT:0xx names information entities while DAT:1xx names information-state processes",
           entity_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_0").include?("information entity") } &&
             process_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_1").include?("information-state process") })
checks.add("entity overlap logic", "persistent information entities are manifestation-neutral while manifest and dormant are alternatives",
           %w[DAT:000 DAT:010 DAT:020].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("may co-occur") } &&
             %w[DAT:001 DAT:002 DAT:011 DAT:012 DAT:021 DAT:022].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("mutually exclusive") })
checks.add("internal-transformation triplet", "DAT:100–102 changes only the phase of one internal information transformation",
           %w[DAT:100 DAT:101 DAT:102].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("represented information") && definition.include?("within one reference entity") && definition.include?("without transferring it to a distinct target")
           end)
checks.add("target-transfer triplet", "DAT:110–112 changes only the phase of one bounded transfer to one distinct target",
           %w[DAT:110 DAT:111 DAT:112].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("information transfer") && definition.include?("one source context") && definition.include?("one distinct reference target")
           end)
checks.add("systemic-synchronization triplet", "DAT:120–122 changes only the phase of one coordinated systemic alignment",
           %w[DAT:120 DAT:121 DAT:122].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("coordinated") && definition.include?("align") && definition.include?("multiple participants") &&
               definition.include?("one shared data domain") && definition.include?("one synchronization criterion")
           end)
checks.add("scope separation", "inward transformation, target transfer, and systemic synchronization remain disjoint",
           %w[DAT:100 DAT:101 DAT:102].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("does not require a distinct target") } &&
             %w[DAT:110 DAT:111 DAT:112].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("one source context and one distinct target") } &&
             %w[DAT:120 DAT:121 DAT:122].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("multiple participants under one criterion") })
checks.add("argument-role discipline", "examples expose scope-appropriate semantic roles",
           %w[DAT:100 DAT:101 DAT:102].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("ENTITY=") } &&
             %w[DAT:110 DAT:111 DAT:112].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("SOURCE=") } &&
             %w[DAT:120 DAT:121 DAT:122].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("PARTICIPANTS=") })

phase_prefixes = process_ids.to_h { |id| [id, id.end_with?("0") ? "Completion of" : id.end_with?("1") ? "An ongoing" : "A nonactualized"] }
checks.add("third-trit discipline", "completed, active, and nonactualized phases are expressed exactly",
           phase_prefixes.all? { |id, prefix| process_roots.fetch(id).fetch("invariant_definition").start_with?(prefix) })
checks.add("nonactualized discipline", "lexical 1x2 invariants exclude planning, scheduling, readiness, uncertainty, and futurity",
           %w[DAT:102 DAT:112 DAT:122].all? do |id|
             text = [process_roots.fetch(id).fetch("proposed_title"), process_roots.fetch(id).fetch("invariant_definition")].join(" ")
             text.include?("nonactualized") && !text.match?(/intend|plan|schedul|queue|ready|future|probab|uncertain|possible|permit|access/i)
           end)
forbidden = /success|fidel|acknowledg|true|false|valid|correct|belief|understand|observ|physical|carrier|medium|schedul|queue|plan|probab|future|possible|permit/i
checks.add("result and collision neutrality", "process invariants exclude quality, cognition, physical realization, scheduling, and modality",
           process_roots.values.none? { |root| root.fetch("invariant_definition").match?(forbidden) })
checks.add("layer anchoring", "each process root contrasts DAT entity, process, and reserved affordance layers",
           process_roots.values.all? do |root|
             text = root.fetch("same_family_contrast")
             text.include?("DAT:0xx") && text.include?("information entities") && text.include?("DAT:1xx") &&
               text.include?("transformations, target transfers, and systemic synchronizations") && text.include?("DAT:2xx")
           end)
checks.add("completion neutrality", "completed information processes do not assert external success conditions or persistence",
           %w[DAT:100 DAT:110 DAT:120].all? do |id|
             root = process_roots.fetch(id)
             root.fetch("runtime_state_interpretation").fetch("1").include?("without asserting") &&
               root.fetch("same_family_contrast").include?("does not entail persistence, fidelity, acknowledgment")
           end)
checks.add("boundary completeness", "every process root has substantial boundaries and contrasts",
           process_roots.values.all? do |root|
             root.fetch("inclusion_boundary").length >= 280 && root.fetch("excluded_meanings").length >= 6 &&
               root.fetch("nearest_neighbors").length >= 6 && root.fetch("same_family_contrast").length >= 500
           end)
checks.add("runtime tailoring", "all 27 runtime meanings are specific and preserve lexical/runtime separation",
           process_roots.values.all? do |root|
             states = root.fetch("runtime_state_interpretation")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && states.values.all? { |value| value.length >= 120 } &&
               root.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`")
           end)
checks.add("cross-family routing", "every process root distinguishes all eleven competing families",
           process_roots.values.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["DAT"]).to_set && comparisons.values.all? { |value| value.length >= 90 }
           end)
checks.add("example coverage", "each process root has six typed examples and a counterexample",
           process_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)
checks.add("candidate challenge", "five scored architectures per root produce the information-state-process winner uniquely",
           process_ids.all? do |id|
             record = score_roots.fetch(id)
             candidates = record.fetch("candidates")
             best = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == best }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "information_state_processes" && record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)
checks.add("coverage routing", "at least one hundred unique process concepts use varied, non-forced routes",
           process_stress.length >= 100 && process_stress.map { |test| test.fetch("english_concept") }.uniq.length == process_stress.length &&
             process_stress.map { |test| test.fetch("routing") }.uniq.length >= 10 && process_stress.all? { |test| test.fetch("analysis").length >= 35 })
required_stress = ["encode", "decode", "read", "copy to a target", "send data", "move a file", "acknowledge receipt", "synchronize replicas", "merge concurrent edits", "datum is manifest", "data process scheduled", "data process uncertain", "many independent transfers", "data transfer versus communication", "synchronization versus restoration"]
checks.add("focused semantic stress", "coverage tests process centers, layers, phase, scope, modality, and cross-family boundaries",
           required_stress.all? { |concept| process_stress.any? { |test| test["english_concept"] == concept } })

packet_paths = Dir[File.join(ROOT, "reviews/{DAT_000_022,DAT_100_122}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_dat_000_022_review.rb build_dat_100_122_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "both DAT packet builders are idempotent in #{mode} mode", builders_ok && before == after)
checks.add("canonical entity alignment", "canonical DAT:000–022 titles and invariants match the live lexicon",
           entity_ids.all? { |id| atoms.fetch(id)["title"] == entity_roots.fetch(id)["proposed_title"] && atoms.fetch(id)["core_definition"] == entity_roots.fetch(id)["invariant_definition"] })
if mode == "canonical"
  checks.add("canonical process alignment", "approved DAT:100–122 titles and invariants match the live lexicon",
             process_ids.all? { |id| atoms.fetch(id)["title"] == process_roots.fetch(id)["proposed_title"] && atoms.fetch(id)["core_definition"] == process_roots.fetch(id)["invariant_definition"] })
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional DAT:100–122 roots",
             process_spec.dig("metadata", "roots_canonicalized").to_a.empty? && process_roots.values.none? { |root| root["canonicalized"] })
end
checks.add("prior approval immutability", "the DAT:000–022 migration remains byte-identical",
           Digest::SHA256.file(File.join(ROOT, "migrations/DAT_000_022_semantic_approval.yaml")).hexdigest == "b7249334529b15084753a5e066e3a617b5e6f53538580d19eef826477e01ec24")

report = checks.markdown(
  title: "DAT:000–122 Combined Information-Entity/Information-Process Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL DATA ENTITY AND PROCESS LAYERS SOUND" : "PASS — DAT:100–122 READY FOR DELEGATED APPROVAL",
  summary: ["Mode: **#{mode}**", "Roots audited: **18**", "Generated-form assertions: **144**", "Process runtime interpretations: **27**", "Stress tests: **#{entity_stress.length + process_stress.length}** (#{entity_stress.length} entity + #{process_stress.length} process)"]
)
report << "\n## Required interpretation\n\n`DAT:0xx` identifies bounded information entities: one internal datum, one target-denoting reference, or one shared dataset. `DAT:1xx` identifies bounded represented-information processes: inward transformation within one entity, outward transfer from one source context to one distinct target, or systemic alignment across multiple participants under one synchronization criterion. Completion does not entail fidelity, truth, persistence, acknowledgment, physical transport, communication uptake, understanding, or success under an external criterion. Lexical `1x2` is nonactualized only; runtime `[2]/num` remains uncertainty about the selected phase assertion.\n\n"
report << "**#{checks.success? ? 'COMBINED DAT SOUNDNESS CONTRACT SATISFIED' : 'COMBINED DAT SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/DAT_000_122_soundness_audit.md", report)

puts "DAT:000–122 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
