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
  opts.banner = "Usage: ruby tools/validate_rep_000_222_soundness.rb [--mode review|canonical]"
  opts.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode }
end.parse!

condition_ids = EraZeroValidation.ids_for_range("REP:000–022")
process_ids = EraZeroValidation.ids_for_range("REP:100–122")
affordance_ids = EraZeroValidation.ids_for_range("REP:200–222")
all_ids = condition_ids + process_ids + affordance_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
condition_spec = EraZeroValidation.load_yaml("reviews/REP_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/REP_100_122_recommended_spec.yaml")
affordance_spec = EraZeroValidation.load_yaml("reviews/REP_200_222_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/REP_200_222_scored_candidates.yaml")
condition_stress = EraZeroValidation.load_yaml("reviews/REP_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/REP_100_122_stress_tests.yaml").fetch("tests")
affordance_stress = EraZeroValidation.load_yaml("reviews/REP_200_222_stress_tests.yaml").fetch("tests")

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

checks.add("authority mode", "REP:000–122 stays canonical and REP:200–222 has one requested authority state",
           (condition_ids + process_ids).all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))

checks.add("exact family scope", "the audit covers exactly all twenty-seven REP roots",
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

checks.add("condition/process/affordance separation", "REP:0xx names restoration conditions, REP:1xx transformations, and REP:2xx capacities or enabling relations",
           condition_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_0").include?("entity or condition") } &&
             process_roots.values.all? { |root| root.fetch("invariant_definition").include?("restorative transformation") } &&
             affordance_roots.values.all? { |root| root.fetch("invariant_definition").match?(/capacity|applicability relation|pathway relation/) } &&
             affordance_roots.values.none? { |root| root.fetch("invariant_definition").match?(/completion of|an ongoing|a nonactualized restorative transformation/i) })

checks.add("inward affordance triplet", "REP:200–202 changes only persistent/operative/latent status of internal recoverability",
           %w[REP:200 REP:201 REP:202].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("capacity of one reference entity") && definition.include?("internally originating restoration")
           end)

checks.add("outward affordance triplet", "REP:210–212 changes only status of one source-target restorative-applicability relation",
           %w[REP:210 REP:211 REP:212].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("restorative applicability relation") && definition.include?("one distinct source") &&
               definition.include?("one reference target") && definition.include?("target restoration")
           end)

checks.add("systemic affordance triplet", "REP:220–222 changes only status of one shared restoration pathway",
           %w[REP:220 REP:221 REP:222].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("pathway relation") && definition.include?("multiple participants") &&
               definition.include?("one shared system") && definition.include?("one shared restoration condition")
           end)

phase_phrases = {
  "REP:200" => "A persistent capacity", "REP:201" => "A capacity", "REP:202" => "A capacity",
  "REP:210" => "A persistent restorative applicability relation", "REP:211" => "A restorative applicability relation",
  "REP:212" => "A restorative applicability relation", "REP:220" => "A persistent pathway relation",
  "REP:221" => "A pathway relation", "REP:222" => "A pathway relation"
}.freeze
checks.add("third-trit discipline", "persistent, operative, and latent lexical statuses are expressed exactly",
           phase_phrases.all? { |id, phrase| affordance_roots.fetch(id).fetch("invariant_definition").start_with?(phrase) } &&
             %w[REP:201 REP:211 REP:221].all? { |id| affordance_roots.fetch(id).fetch("invariant_definition").include?("presently") } &&
             %w[REP:202 REP:212 REP:222].all? { |id| affordance_roots.fetch(id).fetch("invariant_definition").match?(/without (?:being )?presently|not presently/) })

checks.add("scope identity separation", "outward keeps one source and target distinct while systemic requires one shared condition across multiple participants",
           %w[REP:210 REP:211 REP:212].all? do |id|
             boundary = affordance_roots.fetch(id).fetch("inclusion_boundary")
             boundary.include?("one distinct source") && boundary.include?("one reference target")
           end &&
             %w[REP:220 REP:221 REP:222].all? do |id|
               boundary = affordance_roots.fetch(id).fetch("inclusion_boundary")
               boundary.include?("multiple participants") && boundary.include?("one shared restoration condition")
             end)

checks.add("layer non-entailment", "each affordance root explicitly separates conditions, actual processes, and persistent relations",
           affordance_roots.values.all? do |root|
             contrast = root.fetch("same_family_contrast")
             contrast.include?("REP:0xx") && contrast.include?("REP:1xx") && contrast.include?("REP:2xx") &&
               contrast.include?("does not entail")
           end)

forbidden = /detect|observ|diagnos|evidence|belie|protect|shield|resist|maintain|maintenance|backup|resource|record|probab|likelihood|schedule|plan|future/i
checks.add("collision-free invariants", "winner invariants exclude evidence, knowledge, protection, maintenance, backups, resources, probability, and planning",
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
           affordance_stress.any? { |test| test["english_concept"] == "persistent recoverability uncertain" && test["analysis"].include?("REP:200[2]/num") } &&
             affordance_stress.any? { |test| test["english_concept"] == "latent recoverability affirmed" && test["analysis"].include?("REP:202[1]") } &&
             affordance_stress.any? { |test| test["english_concept"] == "latent relation affirmed" && test["analysis"].include?("REP:212[1]") } &&
             affordance_stress.any? { |test| test["english_concept"] == "latent versus unknown" })

checks.add("cross-family routing", "every affordance root distinguishes all eleven competing families",
           affordance_roots.values.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["REP"]).to_set &&
               comparisons.values.all? { |value| value.length >= 110 }
           end)

checks.add("example coverage", "each affordance root has six typed examples with graphs, glosses, state, contour, roles, and a counterexample",
           affordance_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per address yield one unique restoration-affordance winner",
           affordance_ids.all? do |id|
             root = score_roots.fetch(id)
             candidates = root.fetch("candidates")
             maximum = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == maximum }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "restoration_affordance" &&
               root["recommended_candidate_id"] == "restoration_affordance" && candidates.map { |candidate| candidate["total"] }.uniq.length >= 4
           end)

checks.add("coverage routing", "at least ninety unique concepts use varied non-forced routes",
           affordance_stress.length >= 90 && affordance_stress.map { |test| test.fetch("english_concept") }.uniq.length == affordance_stress.length &&
             affordance_stress.map { |test| test.fetch("routing") }.uniq.length >= 10 &&
             affordance_stress.all? { |test| test.fetch("analysis").length >= 45 })

checks.add("focused layer stress tests", "the packet tests condition/process/affordance separation, scope identity, and cross-family collisions",
           ["affordance versus condition", "affordance versus process", "recoverability versus resistance",
            "restorative relation versus service relation", "restoration pathway versus network", "restoration affordance versus backup"].all? do |concept|
             affordance_stress.any? { |test| test["english_concept"] == concept }
           end)

packet_paths = Dir[File.join(ROOT, "reviews/{REP_000_022,REP_100_122,REP_200_222}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_rep_000_022_review.rb build_rep_100_122_review.rb build_rep_200_222_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "all three REP packet builders are idempotent in #{mode} mode", builders_ok && before == after)

checks.add("canonical lower-layer alignment", "canonical REP:000–122 titles and invariants match the authoritative lexicon",
           condition_roots.merge(process_roots).all? do |id, root|
             atom = atoms.fetch(id)
             atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
           end)

if mode == "canonical"
  checks.add("canonical affordance alignment", "approved REP:200–222 titles and invariants match the authoritative lexicon",
             affordance_roots.all? do |id, root|
               atom = atoms.fetch(id)
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional REP:200–222 roots",
             affordance_spec.dig("metadata", "roots_canonicalized").to_a.empty? && affordance_roots.values.none? { |root| root["canonicalized"] })
end

checks.add("prior approval immutability", "REP:000–022 and REP:100–122 approval migrations remain byte-identical",
           Digest::SHA256.file(File.join(ROOT, "migrations/REP_000_022_semantic_approval.yaml")).hexdigest == "21f3909f3f52bbd0f1b1ba916de1a1adf91a270a7001b1b91f6c8e1ae8d1db16" &&
             Digest::SHA256.file(File.join(ROOT, "migrations/REP_100_122_semantic_approval.yaml")).hexdigest == "5953bad0a9cf9130a3da9b6de24da11183217f5bdf86005b253123a7f257cfb4")

report = checks.markdown(
  title: "REP:000–222 Full-Family Repair Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — COMPLETE CANONICAL REPAIR FAMILY SOUND" : "PASS — REP:200–222 READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**", "Roots audited: **27**", "Generated-form assertions: **216**",
    "Affordance runtime interpretations: **27**", "Stress tests: **#{condition_stress.length + process_stress.length + affordance_stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`REP:0xx` identifies restoration conditions. `REP:1xx` identifies actual restorative transformations. `REP:2xx` states only the corresponding restorative affordance: one entity's internal recoverability, one source-target restorative-applicability relation, or one pathway that can enable one shared restoration condition across system participants. No layer entails another.\n\n"
report << "Persistent, operative, and latent lexical thirds are part of root identity. Persistent identity may co-occur with operation or latency; operative and latent are exclusive for the same affordance at one reference time. Runtime `[0]`, `[1]`, or `[2]/num` qualifies an assertion and never changes lexical status. In particular `REP:200[2]/num` is uncertainty about persistent recoverability, while `REP:202[1]` affirms latent recoverability.\n\n"
report << "**#{checks.success? ? 'COMPLETE REP FAMILY SOUNDNESS CONTRACT SATISFIED' : 'COMPLETE REP FAMILY SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/REP_000_222_soundness_audit.md", report)

puts "REP:000–222 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
