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
  opts.banner = "Usage: ruby tools/validate_log_000_222_soundness.rb [--mode review|canonical]"
  opts.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode }
end.parse!

condition_ids = EraZeroValidation.ids_for_range("DAT:000–022")
process_ids = EraZeroValidation.ids_for_range("DAT:100–122")
affordance_ids = EraZeroValidation.ids_for_range("DAT:200–222")
all_ids = condition_ids + process_ids + affordance_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
condition_spec = EraZeroValidation.load_yaml("reviews/DAT_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/DAT_100_122_recommended_spec.yaml")
affordance_spec = EraZeroValidation.load_yaml("reviews/DAT_200_222_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/DAT_200_222_scored_candidates.yaml")
condition_stress = EraZeroValidation.load_yaml("reviews/DAT_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/DAT_100_122_stress_tests.yaml").fetch("tests")
affordance_stress = EraZeroValidation.load_yaml("reviews/DAT_200_222_stress_tests.yaml").fetch("tests")

to_map = lambda do |spec|
  spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
end
condition_roots = to_map.call(condition_spec)
process_roots = to_map.call(process_spec)
affordance_roots = to_map.call(affordance_spec)
score_roots = scores.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
statuses = affordance_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options[:mode]
mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "DAT:000–122 stays canonical and DAT:200–222 has one requested authority state",
           (condition_ids + process_ids).all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))

checks.add("exact family scope", "the audit covers exactly all twenty-seven DAT roots",
           condition_roots.keys == condition_ids && process_roots.keys == process_ids &&
             affordance_roots.keys == affordance_ids && all_ids.uniq.length == 27)

checks.add("generated-form integrity", "all 216 generated-field assertions match the immutable address algorithms",
           all_ids.all? do |id|
             root = condition_roots[id] || process_roots[id] || affordance_roots[id]
             root.fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atoms.fetch(id))
           end)

checks.add("semantic uniqueness", "all titles and invariant definitions are unique across the complete family",
           begin
             roots = condition_roots.values + process_roots.values + affordance_roots.values
             titles = roots.map { |root| root.fetch("proposed_title") }
             definitions = roots.map { |root| root.fetch("invariant_definition") }
             titles.uniq.length == 27 && definitions.uniq.length == 27 && definitions.all? { |definition| definition.end_with?(".") }
           end)

checks.add("entity/process/affordance separation", "DAT:0xx names information entities, DAT:1xx information processes, and DAT:2xx process capacities or transfer relations",
           condition_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_0").include?("information entity") } &&
             process_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_1").include?("information-state process") } &&
             affordance_roots.values.all? { |root| root.fetch("invariant_definition").match?(/capacity|information-transfer relation/) } &&
             affordance_roots.values.none? { |root| root.fetch("invariant_definition").match?(/completion of|an ongoing|a nonactualized bounded/i) })

checks.add("inward affordance triplet", "DAT:200–202 changes only status of internal data transformability",
           %w[DAT:200 DAT:201 DAT:202].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("capacity of represented information") && definition.include?("within one reference entity") && definition.include?("internal data transformation")
           end)

checks.add("outward affordance triplet", "DAT:210–212 changes only status of one source-target information-transfer relation",
           %w[DAT:210 DAT:211 DAT:212].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("information-transfer relation") && definition.include?("one source context") &&
               definition.include?("one distinct reference target") && definition.include?("target data transfer")
           end)

checks.add("systemic affordance triplet", "DAT:220–222 changes only status of systemic data synchronizability",
           %w[DAT:220 DAT:221 DAT:222].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("capacity of information states") && definition.include?("multiple participants") &&
               definition.include?("one shared data domain") && definition.include?("one synchronization criterion") && definition.include?("coordinated alignment")
           end)

phase_phrases = {
  "DAT:200" => "A persistent capacity", "DAT:201" => "A capacity", "DAT:202" => "A capacity",
  "DAT:210" => "A persistent information-transfer relation", "DAT:211" => "An information-transfer relation",
  "DAT:212" => "An information-transfer relation", "DAT:220" => "A persistent capacity",
  "DAT:221" => "A capacity", "DAT:222" => "A capacity"
}.freeze
checks.add("third-trit discipline", "persistent, operative, and latent lexical statuses are expressed exactly",
           phase_phrases.all? { |id, phrase| affordance_roots.fetch(id).fetch("invariant_definition").start_with?(phrase) } &&
             %w[DAT:201 DAT:211 DAT:221].all? { |id| affordance_roots.fetch(id).fetch("invariant_definition").include?("presently") } &&
             %w[DAT:202 DAT:212 DAT:222].all? { |id| affordance_roots.fetch(id).fetch("invariant_definition").match?(/without (?:being )?presently|not presently/) })

checks.add("scope identity separation", "outward keeps one source context and target distinct while systemic requires one shared criterion across participants",
           %w[DAT:210 DAT:211 DAT:212].all? do |id|
             boundary = affordance_roots.fetch(id).fetch("inclusion_boundary")
             boundary.include?("one source context") && boundary.include?("one distinct target")
           end &&
             %w[DAT:220 DAT:221 DAT:222].all? do |id|
               boundary = affordance_roots.fetch(id).fetch("inclusion_boundary")
               boundary.include?("multiple participants") && boundary.include?("one shared criterion")
             end)

checks.add("layer non-entailment", "each affordance root explicitly separates conditions, actual processes, and persistent relations",
           affordance_roots.values.all? do |root|
             contrast = root.fetch("same_family_contrast")
             contrast.include?("DAT:0xx") && contrast.include?("DAT:1xx") && contrast.include?("DAT:2xx") &&
               contrast.include?("does not entail")
           end)

forbidden = /detect|observ|evidence|belie|understand|algorithm|resource|record|integrity|provenance|access|retriev|referen.*resol|consistent|compatible|permit|authori|probab|schedule|plan|future|possible/i
checks.add("collision-free invariants", "winner invariants exclude evidence, knowledge, algorithms, resources, access, integrity, provenance, permission, probability, and planning",
           affordance_roots.values.none? { |root| root.fetch("invariant_definition").match?(forbidden) })

checks.add("boundary completeness", "every affordance root has substantial inclusion, exclusions, and same-family contrast",
           affordance_roots.values.all? do |root|
             root.fetch("inclusion_boundary").length >= 350 && root.fetch("excluded_meanings").length >= 6 &&
               root.fetch("nearest_neighbors").length >= 6 && root.fetch("same_family_contrast").length >= 450
           end)

checks.add("runtime-state tailoring", "all 27 affordance runtime meanings are specific and preserve lexical/runtime separation",
           affordance_roots.values.all? do |root|
             states = root.fetch("runtime_state_interpretation")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && states.values.all? { |value| value.length >= 110 } &&
               root.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`")
           end)

checks.add("lexical-2/runtime-2 contrast", "focused tests distinguish lexical latency from runtime uncertainty",
           affordance_stress.any? { |test| test["english_concept"] == "operative data affordance uncertain" && test["analysis"].include?("DAT:201/211/221[2]/num") } &&
             affordance_stress.any? { |test| test["english_concept"] == "latent data affordance affirmed" && test["analysis"].include?("DAT:202/212/222[1]") } &&
             affordance_stress.any? { |test| test["english_concept"] == "hidden transferability" } &&
             affordance_stress.any? { |test| test["english_concept"] == "unknown data affordance" })

checks.add("cross-family routing", "every affordance root distinguishes all eleven competing families",
           affordance_roots.values.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["DAT"]).to_set &&
               comparisons.values.all? { |value| value.length >= 110 }
           end)

checks.add("example coverage", "each affordance root has six typed examples with graphs, glosses, state, contour, roles, and a counterexample",
           affordance_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per address yield one unique information-process-affordance winner",
           affordance_ids.all? do |id|
             root = score_roots.fetch(id)
             candidates = root.fetch("candidates")
             maximum = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == maximum }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "information_process_affordances" &&
               root["recommended_candidate_id"] == "information_process_affordances" && candidates.map { |candidate| candidate["total"] }.uniq.length >= 4
           end)

checks.add("coverage routing", "at least ninety unique concepts use varied non-forced routes",
           affordance_stress.length >= 90 && affordance_stress.map { |test| test.fetch("english_concept") }.uniq.length == affordance_stress.length &&
             affordance_stress.map { |test| test.fetch("routing") }.uniq.length >= 10 &&
             affordance_stress.all? { |test| test.fetch("analysis").length >= 45 })

checks.add("focused layer stress tests", "the packet tests entity/process/affordance separation, scope identity, and cross-family collisions",
           ["data affordance versus entity", "data affordance versus process", "transformability versus understanding",
            "transferability versus communication", "synchronizability versus consistency", "data affordance versus general possibility"].all? do |concept|
             affordance_stress.any? { |test| test["english_concept"] == concept }
           end)

packet_paths = Dir[File.join(ROOT, "reviews/{DAT_000_022,DAT_100_122,DAT_200_222}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_dat_000_022_review.rb build_dat_100_122_review.rb build_dat_200_222_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "all three DAT packet builders are idempotent in #{mode} mode", builders_ok && before == after)

checks.add("canonical lower-layer alignment", "canonical DAT:000–122 titles and invariants match the authoritative lexicon",
           condition_roots.merge(process_roots).all? do |id, root|
             atom = atoms.fetch(id)
             atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
           end)

if mode == "canonical"
  checks.add("canonical affordance alignment", "approved DAT:200–222 titles and invariants match the authoritative lexicon",
             affordance_roots.all? do |id, root|
               atom = atoms.fetch(id)
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional DAT:200–222 roots",
             affordance_spec.dig("metadata", "roots_canonicalized").to_a.empty? && affordance_roots.values.none? { |root| root["canonicalized"] })
end

checks.add("prior approval immutability", "DAT:000–022 and DAT:100–122 approval migrations remain byte-identical",
           Digest::SHA256.file(File.join(ROOT, "migrations/DAT_000_022_semantic_approval.yaml")).hexdigest == "b7249334529b15084753a5e066e3a617b5e6f53538580d19eef826477e01ec24" &&
             Digest::SHA256.file(File.join(ROOT, "migrations/DAT_100_122_semantic_approval.yaml")).hexdigest == "3e24f74a6ad841cfa3a91de21f82224844d822189d26055396b09cdb047f7411")

report = checks.markdown(
  title: "DAT:000–222 Full-Family Data Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — COMPLETE CANONICAL DATA FAMILY SOUND" : "PASS — DAT:200–222 READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**", "Roots audited: **27**", "Generated-form assertions: **216**",
    "Affordance runtime interpretations: **27**", "Stress tests: **#{condition_stress.length + process_stress.length + affordance_stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`DAT:0xx` identifies bounded information entities. `DAT:1xx` identifies actual information transformations, target transfers, and systemic synchronizations. `DAT:2xx` states only the corresponding information-process affordance: transformability within one entity, one source context's transferability to one distinct target, or coordinated synchronizability across multiple participants under one criterion. No layer entails another.\n\n"
report << "Persistent, operative, and latent lexical thirds are part of root identity. Persistent identity may co-occur with operation or latency; operative and latent are exclusive for the same affordance at one reference time. Runtime `[0]`, `[1]`, or `[2]/num` qualifies an assertion and never changes lexical status. In particular `DAT:200[2]/num` is uncertainty about persistent transformability, while `DAT:202[1]` affirms latent transformability. Access, permission, integrity, provenance, reference resolution, algorithms, media, resources, results, and modality remain separate.\n\n"
report << "**#{checks.success? ? 'COMPLETE DAT FAMILY SOUNDNESS CONTRACT SATISFIED' : 'COMPLETE DAT FAMILY SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/DAT_000_222_soundness_audit.md", report)

puts "DAT:000–222 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
