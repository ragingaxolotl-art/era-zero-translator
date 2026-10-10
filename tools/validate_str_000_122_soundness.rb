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
OptionParser.new do |opts|
  opts.banner = "Usage: ruby tools/validate_str_000_122_soundness.rb [--mode review|canonical]"
  opts.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode }
end.parse!

entity_ids = EraZeroValidation.ids_for_range("STR:000–022")
process_ids = EraZeroValidation.ids_for_range("STR:100–122")
all_ids = entity_ids + process_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
entity_spec = EraZeroValidation.load_yaml("reviews/STR_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/STR_100_122_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/STR_100_122_scored_candidates.yaml")
entity_stress = EraZeroValidation.load_yaml("reviews/STR_000_022_stress_tests.yaml").fetch("tests")
stress = EraZeroValidation.load_yaml("reviews/STR_100_122_stress_tests.yaml").fetch("tests")
entity_roots = entity_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
process_roots = process_spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scores.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
statuses = process_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options[:mode]
mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "STR:000–022 stays canonical and STR:100–122 has the requested uniform authority state",
           entity_ids.all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))

checks.add("exact layer scope", "the combined audit covers exactly eighteen STR roots",
           entity_roots.keys == entity_ids && process_roots.keys == process_ids && all_ids.uniq.length == 18)

checks.add("generated-form integrity", "all 144 fixed-field assertions match the deterministic address algorithms",
           all_ids.all? do |id|
             spec = entity_roots[id] || process_roots[id]
             spec.fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atoms.fetch(id))
           end)

checks.add("semantic uniqueness", "all eighteen titles and invariant definitions are nonempty and unique",
           begin
             roots = entity_roots.values + process_roots.values
             titles = roots.map { |root| root.fetch("proposed_title") }
             definitions = roots.map { |root| root.fetch("invariant_definition") }
             titles.uniq.length == 18 && definitions.uniq.length == 18 && definitions.all? { |definition| definition.end_with?(".") }
           end)

checks.add("entity/process separation", "STR:0xx names loci or arrangements while STR:1xx names transformations",
           entity_roots.values.all? { |root| !root.fetch("invariant_definition").match?(/transformation|process|reconfigur|incorporat|integrat/i) } &&
             process_roots.values.all? { |root| root.fetch("invariant_definition").match?(/structural transformation/) })

checks.add("entity triplet overlap logic", "persistent STR:0x0 roots are realization-neutral while active and dormant siblings are time-indexed alternatives",
           entity_spec.dig("metadata", "triplet_logic", "persistent_member").to_s.include?("realization-neutral") &&
             entity_spec.dig("metadata", "triplet_logic", "active_dormant_members").to_s.include?("mutually exclusive") &&
             %w[STR:000 STR:010 STR:020].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("may co-occur") } &&
             %w[STR:001 STR:002 STR:011 STR:012 STR:021 STR:022].all? { |id| entity_roots.fetch(id).fetch("same_family_contrast").include?("mutually exclusive") })

checks.add("entity column-specific boundaries", "each STR:0xx boundary stays inside its own inward, outward, or systemic structural column",
           %w[STR:000 STR:001 STR:002].all? { |id| entity_roots.fetch(id).fetch("inclusion_boundary").include?("one constituent position internal") } &&
             %w[STR:010 STR:011 STR:012].all? { |id| entity_roots.fetch(id).fetch("inclusion_boundary").include?("one boundary locus") && entity_roots.fetch(id).fetch("inclusion_boundary").include?("does not by itself make that target a constituent") } &&
             %w[STR:020 STR:021 STR:022].all? { |id| entity_roots.fetch(id).fetch("inclusion_boundary").include?("object of structural identity") && entity_roots.fetch(id).fetch("inclusion_boundary").include?("separate DAT, MIN, LOG, or ORI claim") })

checks.add("internal reconfiguration triplet", "STR:100–102 changes only completion phase of constituent reassignment",
           %w[STR:100 STR:101 STR:102].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("reference structure's own constituents") && definition.include?("internal positions")
           end)

checks.add("target incorporation triplet", "STR:110–112 changes only completion phase of one-target incorporation",
           %w[STR:110 STR:111 STR:112].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("distinct target") && definition.include?("incorporated into a reference structure")
           end)

checks.add("systemic integration triplet", "STR:120–122 changes only completion phase of multi-structure integration",
           %w[STR:120 STR:121 STR:122].all? do |id|
             definition = process_roots.fetch(id).fetch("invariant_definition")
             definition.include?("multiple structures") && definition.include?("one composite arrangement")
           end)

checks.add("incorporation/integration separation", "outward incorporation preserves one reference whole while systemic integration creates a distinct higher-order whole",
           %w[STR:110 STR:111 STR:112].all? do |id|
             boundary = process_roots.fetch(id).fetch("inclusion_boundary")
             boundary.include?("reference remains the organizing whole") && boundary.include?("use systemic integration")
           end &&
             %w[STR:120 STR:121 STR:122].all? do |id|
               boundary = process_roots.fetch(id).fetch("inclusion_boundary")
               boundary.include?("co-constituents of a higher-order") && boundary.include?("use target incorporation")
             end)

checks.add("process argument-role discipline", "examples distinguish own constituents, one target, and multiple input structures",
           %w[STR:100 STR:101 STR:102].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("CONSTITUENTS=") } &&
             %w[STR:110 STR:111 STR:112].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("TARGET=") } &&
             %w[STR:120 STR:121 STR:122].all? { |id| process_roots.fetch(id).fetch("examples").first.fetch("semantic_graph").include?("INPUT_STRUCTURES=") })

phase_phrases = {
  "STR:100" => "Completion of", "STR:101" => "An ongoing", "STR:102" => "A nonactualized",
  "STR:110" => "Completion of", "STR:111" => "An ongoing", "STR:112" => "A nonactualized",
  "STR:120" => "Completion of", "STR:121" => "An ongoing", "STR:122" => "A nonactualized"
}.freeze
checks.add("third-trit discipline", "completed, active, and nonactualized phases are expressed exactly",
           phase_phrases.all? { |id, phrase| process_roots.fetch(id).fetch("invariant_definition").start_with?(phrase) })

checks.add("nonactualized-process discipline", "lexical 1x2 invariants do not encode planning, scheduling, queues, permission, or futurity",
           %w[STR:102 STR:112 STR:122].all? do |id|
             text = [process_roots.fetch(id).fetch("proposed_title"), process_roots.fetch(id).fetch("invariant_definition")].join(" ")
             text.include?("nonactualized") && !text.match?(/plan|schedul|queue|stage|ready|intend|future|permit|probab/i)
           end)

checks.add("nonactualized title guard", "the catalogue word potential is explicitly constrained to nonactualization rather than modal strength",
           %w[STR:102 STR:112 STR:122].all? do |id|
             guard = process_roots.fetch(id).fetch("catalogue_title_guard")
             guard.include?("shorthand") && guard.include?("nonactualized") && guard.include?("capability") && guard.include?("probability") && guard.include?("schedule")
           end)

checks.add("collision-free invariants", "process invariants exclude construction, deployment, physical, institutional, functional, and reparative mixtures",
           process_roots.values.none? do |root|
             root.fetch("invariant_definition").match?(/build|construct|deploy|rollout|repair|reinforc|stabili|institution|role|communicat|schema|material|physical|function/i)
           end)

checks.add("canonical STR:0xx anchoring", "each process column composes with the matching canonical entity column",
           process_roots.values_at("STR:100", "STR:101", "STR:102").all? { |root| root.fetch("same_family_contrast").include?("constituent positions") } &&
             process_roots.values_at("STR:110", "STR:111", "STR:112").all? { |root| root.fetch("same_family_contrast").include?("structural interfaces") } &&
             process_roots.values_at("STR:120", "STR:121", "STR:122").all? { |root| root.fetch("same_family_contrast").include?("composite arrangements") })

checks.add("completed-result discipline", "completion asserts only the invariant result at its reference time and does not smuggle in persistence or relations",
           %w[STR:100 STR:110 STR:120].all? do |id|
             contrast = process_roots.fetch(id).fetch("same_family_contrast")
             contrast.include?("only the structural result stated in its invariant") && contrast.include?("does not entail persistence") && contrast.include?("STR:2xx relation")
           end)

checks.add("boundary completeness", "every process root has substantial inclusion, exclusions, and same-family contrasts",
           process_roots.values.all? do |root|
             root.fetch("inclusion_boundary").length >= 220 && root.fetch("excluded_meanings").length >= 6 &&
               root.fetch("nearest_neighbors").length >= 6 && root.fetch("same_family_contrast").length >= 300
           end)

checks.add("runtime-state tailoring", "all 27 process runtime meanings are specific and preserve lexical/runtime separation",
           process_roots.values.all? do |root|
             states = root.fetch("runtime_state_interpretation")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && states.values.all? { |value| value.length >= 130 } &&
               root.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`")
           end)

checks.add("cross-family routing", "every process root distinguishes all eleven competing families",
           process_roots.values.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["STR"]).to_set && comparisons.values.all? { |value| value.length >= 130 }
           end)

checks.add("example coverage", "each process root has six typed examples with state, contour, registers, and a counterexample",
           process_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per address yield the reconfiguration/incorporation/integration winner uniquely",
           process_ids.all? do |id|
             root = score_roots.fetch(id)
             candidates = root.fetch("candidates")
             maximum = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == maximum }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "reconfiguration_incorporation_integration" &&
               root["recommended_candidate_id"] == winners.first["candidate_id"]
           end)

checks.add("coverage routing", "at least sixty unique English concepts use varied non-forced routes",
           stress.length >= 60 && stress.map { |test| test.fetch("english_concept") }.uniq.length == stress.length &&
             stress.map { |test| test.fetch("routing") }.uniq.length >= 10 && stress.all? { |test| test.fetch("analysis").length >= 45 })

checks.add("focused overlap stress tests", "the entity packet tests compatible persistence, exclusive live states, dormant identity, and engagement without incorporation",
           %w[persistent\ and\ occupied\ same\ position persistent\ and\ vacant\ same\ position occupied\ and\ vacant\ at\ the\ same\ time dormant\ arrangement\ and\ blueprint engaged\ interface\ without\ incorporation].all? do |concept|
             entity_stress.any? { |test| test["english_concept"] == concept }
           end)

checks.add("focused scope stress tests", "the process packet tests preserved-reference incorporation, higher-order integration, result time, modal restraint, and relation non-entailment",
           ["incorporate subsystem into existing host", "integrate hosts into a new cluster", "incorporate one structure or integrate two", "completed integration with current result", "potential incorporation means likely", "incorporation without attachment", "engagement becomes incorporation"].all? do |concept|
             stress.any? { |test| test["english_concept"] == concept }
           end)

packet_paths = Dir[File.join(ROOT, "reviews/{STR_000_022,STR_100_122}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_str_000_022_review.rb build_str_100_122_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "both STR packet builders are idempotent in #{mode} mode", builders_ok && before == after)

checks.add("canonical entity alignment", "canonical STR:000–022 titles and invariants match the live lexicon",
           entity_ids.all? do |id|
             atom = atoms.fetch(id)
             root = entity_roots.fetch(id)
             atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
           end)

if mode == "canonical"
checks.add("canonical process alignment", "approved STR:100–122 titles and invariants match the live lexicon",
             process_ids.all? do |id|
               atom = atoms.fetch(id)
               root = process_roots.fetch(id)
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional STR:100–122 roots",
             process_spec.dig("metadata", "roots_canonicalized").to_a.empty? && process_roots.values.none? { |root| root["canonicalized"] })
end

checks.add("approval-record immutability", "both delegated approval migrations remain byte-identical during documentation cleanup",
           Digest::SHA256.file(File.join(ROOT, "migrations/STR_000_022_semantic_approval.yaml")).hexdigest == "8838255265e74746648c0fcfc33d8c320b92f7f74fd8145b7326ff9b99593d70" &&
             Digest::SHA256.file(File.join(ROOT, "migrations/STR_100_122_semantic_approval.yaml")).hexdigest == "150cbc94c66001a156109145b40184b7968d2a96a383ffe5e4f2eb142caa5268")

report = checks.markdown(
  title: "STR:000–122 Combined Structural Entity/Process Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL STRUCTURAL ENTITY AND PROCESS LAYERS SOUND" : "PASS — STR:100–122 READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**", "Roots audited: **18**", "Generated-form assertions: **144**", "Process runtime interpretations: **27**", "Stress tests: **#{entity_stress.length + stress.length}** (#{entity_stress.length} entity + #{stress.length} process)"
  ]
)
report << "\n## Required interpretation\n\n`STR:0xx` identifies constituent positions, structural interfaces, and composite arrangements. Each persistent `...0` root is neutral about current realization and may co-occur with its `...1` or `...2` sibling; only the active and dormant conditions are exclusive at one reference time. A dormant arrangement is the structurally identified arrangement, not the blueprint or rule that describes it.\n\n`STR:1xx` transforms constituent organization. Internal reconfiguration preserves one whole and reassigns its own constituents. Target incorporation preserves one whole while one external target becomes its constituent. Systemic integration places two or more input structures beneath a higher-order whole distinct from every single input. A completed process asserts its invariant result at the completion reference time but does not entail persistence, function, integrity, or a continuing relation. Lexical `1x2` is nonactualized only; the catalogue word *potential* adds no modal strength, and runtime `[2]/num` remains separate.\n\n"
report << "**#{checks.success? ? 'COMBINED STR SOUNDNESS CONTRACT SATISFIED' : 'COMBINED STR SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/STR_000_122_soundness_audit.md", report)

puts "STR:000–122 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
