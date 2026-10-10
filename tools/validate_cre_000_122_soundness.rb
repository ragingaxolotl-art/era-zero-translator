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
OptionParser.new { |parser| parser.on("--mode MODE", %w[auto review canonical]) { |value| options[:mode] = value } }.parse!

entity_ids = EraZeroValidation.ids_for_range("CRE:000–022")
process_ids = EraZeroValidation.ids_for_range("CRE:100–122")
all_ids = entity_ids + process_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
entity_spec = EraZeroValidation.load_yaml("reviews/CRE_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/CRE_100_122_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/CRE_100_122_scored_candidates.yaml")
entity_stress = EraZeroValidation.load_yaml("reviews/CRE_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/CRE_100_122_stress_tests.yaml").fetch("tests")
entity_roots = entity_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
process_roots = process_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scores.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
statuses = process_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options.fetch(:mode)
mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "CRE entities remain canonical and process roots share the requested authority state",
           entity_ids.all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))
checks.add("exact scope", "the cumulative audit covers exactly eighteen Creation roots",
           entity_roots.keys == entity_ids && process_roots.keys == process_ids && all_ids.uniq.length == 18)
checks.add("generated-form integrity", "all 144 fixed generated fields follow the deterministic algorithms",
           all_ids.all? do |id|
             root = entity_roots[id] || process_roots[id]
             EraZeroValidation.generated_field_errors({ id => atoms.fetch(id) }).empty? &&
               root.fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atoms.fetch(id))
           end)
checks.add("semantic uniqueness", "all titles and invariant definitions are complete and unique",
           begin
             roots = entity_roots.values + process_roots.values
             titles = roots.map { |root| root.fetch("proposed_title") }
             definitions = roots.map { |root| root.fetch("invariant_definition") }
             titles.uniq.length == 18 && definitions.uniq.length == 18 && definitions.all? { |definition| definition.end_with?(".") }
           end)
checks.add("entity/process separation", "CRE:0xx owns generative entities and CRE:1xx owns productive transformations",
           entity_roots.values.all? { |root| root.dig("address_justification", "first_trit_0").to_s.include?("Creation entity") } &&
             process_roots.values.all? { |root| root.dig("address_justification", "first_trit_1").to_s.include?("productive transformation") })

checks.add("internal-pattern triplet", "CRE:100–102 changes only the phase of retained internal pattern formation",
           %w[CRE:100 CRE:101 CRE:102].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("productive transformation") && definition.include?("generative pattern") &&
               definition.include?("within one reference entity") && definition.include?("retaining it within that entity")
           end)
checks.add("artifact-generation triplet", "CRE:110–112 changes only the phase of outward artifact generation",
           %w[CRE:110 CRE:111 CRE:112].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("productive transformation") && definition.include?("outward from one source") &&
               definition.include?("one generated artifact") && definition.include?("manifestation")
           end)
checks.add("systemic-co-generation triplet", "CRE:120–122 changes only the phase of coordinated joint generation",
           %w[CRE:120 CRE:121 CRE:122].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("coordinated productive transformation") && definition.include?("multiple participants") &&
               definition.include?("one shared production domain") && definition.include?("one jointly constituted result")
           end)
checks.add("scope separation", "inward, outward, and systemic process scopes remain disjoint",
           %w[CRE:100 CRE:101 CRE:102].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("does not itself produce an outward artifact") } &&
             %w[CRE:110 CRE:111 CRE:112].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("one source and one outward generated product") } &&
             %w[CRE:120 CRE:121 CRE:122].all? { |id| process_roots.fetch(id).fetch("inclusion_boundary").include?("multiple participants") })

phase_prefix = process_ids.to_h do |id|
  prefix = id.end_with?("0") ? "Completion of" : id.end_with?("1") ? "An ongoing" : "A nonactualized"
  [id, prefix]
end
checks.add("third-trit discipline", "completed, active, and nonactualized phases are exact",
           phase_prefix.all? { |id, prefix| process_roots.fetch(id).fetch("invariant_definition").start_with?(prefix) })
checks.add("nonactualized neutrality", "lexical 1x2 invariants do not smuggle in planning, scheduling, readiness, modality, or futurity",
           %w[CRE:102 CRE:112 CRE:122].all? do |id|
             text = [process_roots.fetch(id).fetch("proposed_title"), process_roots.fetch(id).fetch("invariant_definition")].join(" ")
             text.include?("nonactualized") && !text.match?(/intend|plan|schedul|queue|ready|future|probab|uncertain|possible|permit|access/i)
           end)
forbidden = /success|quality|original|accept|author|owner|schedule|queue|plan|probab|future|possible|permit|understand|belief|physical medium|algorithm/i
checks.add("collision-neutral invariants", "process invariants exclude evaluation, ownership, cognition, implementation, scheduling, and modality",
           process_roots.values.none? { |root| root.fetch("invariant_definition").match?(forbidden) })
checks.add("layer anchoring", "every process root distinguishes entity, process, and affordance-relation layers",
           process_roots.values.all? do |root|
             text = root.fetch("same_family_contrast")
             text.include?("CRE:0xx") && text.include?("CRE:1xx") && text.include?("CRE:2xx") &&
               text.include?("pattern formation") && text.include?("artifact generation") && text.include?("systemic co-generation")
           end)
checks.add("completion neutrality", "completed productive processes do not entail quality, value, persistence, acceptance, or authorship",
           %w[CRE:100 CRE:110 CRE:120].all? do |id|
             state = process_roots.fetch(id).fetch("runtime_state_interpretation").fetch("1")
             %w[quality value persistence acceptance authorship].all? { |term| state.include?(term) }
           end)
checks.add("boundary completeness", "each process root has substantial boundaries and neighbor contrasts",
           process_roots.values.all? do |root|
             root.fetch("inclusion_boundary").length >= 300 && root.fetch("excluded_meanings").length >= 6 &&
               root.fetch("nearest_neighbors").length >= 6 && root.fetch("same_family_contrast").length >= 400
           end)
checks.add("runtime tailoring", "all 27 runtime meanings are specific and distinct from lexical phase",
           process_roots.values.all? do |root|
             states = root.fetch("runtime_state_interpretation")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && states.values.all? { |value| value.length >= 120 } &&
               root.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`")
           end)
checks.add("cross-family routing", "every process root distinguishes all eleven competing families",
           process_roots.values.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["CRE"]).to_set &&
               comparisons.values.all? { |value| value.length >= 90 }
           end)
checks.add("example coverage", "each process root has six typed examples with graph, gloss, state, contour, registers, and counterexample",
           process_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)
checks.add("candidate challenge", "five genuinely different scored architectures per root yield one unique productive-transformation winner",
           process_ids.all? do |id|
             record = score_roots.fetch(id)
             candidates = record.fetch("candidates")
             best = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == best }
             candidates.length == 5 && candidates.all? { |candidate| candidate.fetch("scores").keys == EraZeroValidation::SCORE_KEYS } &&
               winners.length == 1 && winners.first["candidate_id"] == "productive_transformation_processes" &&
               record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)
checks.add("coverage routing", "at least one hundred unique concepts use varied, non-forced routes",
           process_stress.length >= 100 && process_stress.map { |test| test.fetch("english_concept") }.uniq.length == process_stress.length &&
             process_stress.map { |test| test.fetch("routing") }.uniq.length >= 10 &&
             process_stress.all? { |test| test.fetch("analysis").length >= 35 })
required_stress = ["form a design pattern", "imagine", "generate an artifact", "build", "transform data", "co-create", "collaborate",
                   "generation completed", "generation active", "generation pending", "queued rendering", "possible creation", "failed creation",
                   "completed process uncertain", "pattern versus pattern formation", "artifact versus artifact generation",
                   "repertoire versus co-generation", "creation versus computation"]
checks.add("focused semantic stress", "tests cover process centers, layers, phase, scope, modality, and collisions",
           required_stress.all? { |concept| process_stress.any? { |test| test["english_concept"] == concept } })

packet_paths = Dir[File.join(ROOT, "reviews/{CRE_000_022,CRE_100_122}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_cre_000_022_review.rb build_cre_100_122_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "both Creation packet builders are idempotent in #{mode} mode", builders_ok && before == after)
checks.add("canonical entity alignment", "approved CRE:000–022 titles and invariants match live authority",
           entity_ids.all? do |id|
             atoms.fetch(id)["title"] == entity_roots.fetch(id)["proposed_title"] &&
               atoms.fetch(id)["core_definition"] == entity_roots.fetch(id)["invariant_definition"]
           end)
if mode == "canonical"
  checks.add("canonical process alignment", "approved CRE:100–122 titles and invariants match live authority",
             process_ids.all? do |id|
               atoms.fetch(id)["title"] == process_roots.fetch(id)["proposed_title"] &&
                 atoms.fetch(id)["core_definition"] == process_roots.fetch(id)["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts leave CRE:100–122 provisional",
             process_spec.dig("metadata", "roots_canonicalized").to_a.empty? && process_roots.values.none? { |root| root["canonicalized"] })
end

report = checks.markdown(
  title: "CRE:000–122 Combined Generative-Entity/Productive-Process Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL CREATION ENTITY AND PROCESS LAYERS SOUND" : "PASS — CRE:100–122 READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**", "Roots audited: **18**", "Generated-form assertions: **144**",
    "Process runtime interpretations: **27**", "Stress tests: **#{entity_stress.length + process_stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`CRE:0xx` identifies generative entities: internal generative patterns, generated artifacts, and shared generative repertoires. `CRE:1xx` identifies productive transformations: inward pattern formation, outward artifact generation, and systemic co-generation. Completion does not entail quality, value, originality, persistence, acceptance, authorship, publication, physical realization, data representation, or success under an external criterion. Lexical `1x2` is nonactualized only; runtime `[2]/num` remains uncertainty about the selected phase assertion.\n\n"
report << "**#{checks.success? ? 'COMBINED CREATION SOUNDNESS CONTRACT SATISFIED' : 'COMBINED CREATION SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/CRE_000_122_soundness_audit.md", report)

puts "CRE:000–122 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
