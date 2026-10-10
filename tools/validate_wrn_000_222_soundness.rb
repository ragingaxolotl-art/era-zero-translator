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
  opts.banner = "Usage: ruby tools/validate_wrn_000_222_soundness.rb [--mode review|canonical]"
  opts.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode }
end.parse!

entity_ids = EraZeroValidation.ids_for_range("WRN:000–022")
process_ids = EraZeroValidation.ids_for_range("WRN:100–122")
affordance_ids = EraZeroValidation.ids_for_range("WRN:200–222")
all_ids = entity_ids + process_ids + affordance_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
entity_spec = EraZeroValidation.load_yaml("reviews/WRN_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/WRN_100_122_recommended_spec.yaml")
affordance_spec = EraZeroValidation.load_yaml("reviews/WRN_200_222_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/WRN_200_222_scored_candidates.yaml")
entity_stress = EraZeroValidation.load_yaml("reviews/WRN_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/WRN_100_122_stress_tests.yaml").fetch("tests")
affordance_stress = EraZeroValidation.load_yaml("reviews/WRN_200_222_stress_tests.yaml").fetch("tests")

to_map = lambda do |spec|
  spec.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
end
entity_roots = to_map.call(entity_spec)
process_roots = to_map.call(process_spec)
affordance_roots = to_map.call(affordance_spec)
score_roots = scores.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
statuses = affordance_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options[:mode]
mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "WRN:000–122 stays canonical and WRN:200–222 has one requested authority state",
           (entity_ids + process_ids).all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))

checks.add("exact family scope", "the audit covers exactly all twenty-seven WRN roots",
           entity_roots.keys == entity_ids && process_roots.keys == process_ids && affordance_roots.keys == affordance_ids && all_ids.uniq.length == 27)

checks.add("generated-form integrity", "all 216 generated-field assertions match the immutable address algorithms",
           all_ids.all? do |id|
             root = entity_roots[id] || process_roots[id] || affordance_roots[id]
             root.fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atoms.fetch(id))
           end)

checks.add("semantic uniqueness", "all titles and invariant definitions are nonempty and unique across the complete family",
           begin
             roots = entity_roots.values + process_roots.values + affordance_roots.values
             titles = roots.map { |root| root.fetch("proposed_title") }
             definitions = roots.map { |root| root.fetch("invariant_definition") }
             titles.uniq.length == 27 && definitions.uniq.length == 27 && definitions.all? { |definition| definition.end_with?(".") }
           end)

checks.add("condition/process/affordance separation", "WRN:0xx names adverse conditions, WRN:1xx adverse transformations, and WRN:2xx adverse capacities or enabling relations",
           entity_roots.values.all? { |root| root.fetch("address_justification").fetch("first_trit_0").include?("entity or condition") } &&
             process_roots.values.all? { |root| root.fetch("invariant_definition").include?("adverse transformation") } &&
             affordance_roots.values.all? { |root| root.fetch("invariant_definition").match?(/susceptibility|exposure relation|pathway relation/) } &&
             affordance_roots.values.none? { |root| root.fetch("invariant_definition").match?(/completion of|an ongoing|a nonactualized adverse transformation/i) })

checks.add("inward affordance triplet", "WRN:200–202 changes only persistent/operative/latent status of internal susceptibility",
           %w[WRN:200 WRN:201 WRN:202].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("susceptibility of one reference entity") && definition.include?("internally originating degradation")
           end)

checks.add("outward affordance triplet", "WRN:210–212 changes only status of one source-target exposure relation",
           %w[WRN:210 WRN:211 WRN:212].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("one distinct hazard source") && definition.include?("one reference target") && definition.include?("target impairment")
           end)

checks.add("systemic affordance triplet", "WRN:220–222 changes only status of one correlated-condition propagation pathway",
           %w[WRN:220 WRN:221 WRN:222].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("multiple participants") && definition.include?("one shared system") &&
               definition.include?("one correlated adverse condition") && definition.include?("distributed")
           end)

phase_phrases = {
  "WRN:200" => "A persistent susceptibility", "WRN:201" => "A susceptibility", "WRN:202" => "A susceptibility",
  "WRN:210" => "A persistent exposure relation", "WRN:211" => "An exposure relation", "WRN:212" => "An exposure relation",
  "WRN:220" => "A persistent pathway relation", "WRN:221" => "A pathway relation", "WRN:222" => "A pathway relation"
}.freeze
checks.add("third-trit discipline", "persistent, operative, and latent lexical statuses are expressed exactly",
           phase_phrases.all? { |id, phrase| affordance_roots.fetch(id).fetch("invariant_definition").start_with?(phrase) } &&
             %w[WRN:201 WRN:211 WRN:221].all? { |id| affordance_roots.fetch(id).fetch("invariant_definition").include?("presently") } &&
             %w[WRN:202 WRN:212 WRN:222].all? { |id| affordance_roots.fetch(id).fetch("invariant_definition").match?(/without (?:being )?presently|not presently/) })

checks.add("scope identity separation", "outward keeps one source and target distinct while systemic requires one correlated condition across multiple participants",
           %w[WRN:210 WRN:211 WRN:212].all? do |id|
             boundary = affordance_roots.fetch(id).fetch("inclusion_boundary")
             boundary.include?("one distinct hazard source") && boundary.include?("one reference target")
           end &&
             %w[WRN:220 WRN:221 WRN:222].all? do |id|
               boundary = affordance_roots.fetch(id).fetch("inclusion_boundary")
               boundary.include?("multiple participants") && boundary.include?("one correlated adverse condition")
             end)

checks.add("layer non-entailment", "each affordance root explicitly separates entities, actual processes, and persistent relations",
           affordance_roots.values.all? do |root|
             contrast = root.fetch("same_family_contrast")
             contrast.include?("WRN:0xx") && contrast.include?("WRN:1xx") && contrast.include?("WRN:2xx") &&
               contrast.include?("does not entail")
           end)

checks.add("collision-free invariants", "winner invariants exclude evidence, observer knowledge, protection, probability, severity, planning, and process realization",
           affordance_roots.values.none? do |root|
             root.fetch("invariant_definition").match?(/detect|observ|diagnos|evidence|belie|warn|signal|alert|resist|protect|shield|contain|repair|recover|probab|likelihood|severity|schedule|plan|future/i)
           end)

checks.add("boundary completeness", "every affordance root has substantial inclusion, exclusions, and same-family contrast",
           affordance_roots.values.all? do |root|
             root.fetch("inclusion_boundary").length >= 300 && root.fetch("excluded_meanings").length >= 6 &&
               root.fetch("nearest_neighbors").length >= 6 && root.fetch("same_family_contrast").length >= 400
           end)

checks.add("runtime-state tailoring", "all 27 affordance runtime meanings are specific and preserve lexical/runtime separation",
           affordance_roots.values.all? do |root|
             states = root.fetch("runtime_state_interpretation")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && states.values.all? { |value| value.length >= 110 } &&
               root.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`")
           end)

checks.add("lexical-2/runtime-2 contrast", "focused tests distinguish lexical latency from runtime [2]/num uncertainty",
           affordance_stress.any? { |test| test["english_concept"] == "persistent susceptibility currently uncertain" && test["analysis"].include?("WRN:200[2]/num") } &&
             affordance_stress.any? { |test| test["english_concept"] == "latent susceptibility affirmed" && test["analysis"].include?("WRN:202[1]") } &&
             affordance_stress.any? { |test| test["english_concept"] == "latent exposure affirmed" && test["analysis"].include?("WRN:212[1]") } &&
             affordance_stress.any? { |test| test["english_concept"] == "latent versus uncertain" })

checks.add("cross-family routing", "every affordance root distinguishes all eleven competing families",
           affordance_roots.values.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["WRN"]).to_set && comparisons.values.all? { |value| value.length >= 130 }
           end)

checks.add("example coverage", "each affordance root has six typed examples with graphs, glosses, state, contour, roles, and a counterexample",
           affordance_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per address yield one unique adverse-affordance winner",
           affordance_ids.all? do |id|
             root = score_roots.fetch(id)
             candidates = root.fetch("candidates")
             maximum = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == maximum }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "adverse_affordance" &&
               root["recommended_candidate_id"] == "adverse_affordance" && candidates.map { |candidate| candidate["total"] }.uniq.length >= 4
           end)

checks.add("coverage routing", "at least seventy-five unique concepts use varied non-forced routes",
           affordance_stress.length >= 75 && affordance_stress.map { |test| test.fetch("english_concept") }.uniq.length == affordance_stress.length &&
             affordance_stress.map { |test| test.fetch("routing") }.uniq.length >= 12 &&
             affordance_stress.all? { |test| test.fetch("analysis").length >= 55 })

checks.add("focused layer stress tests", "the packet tests condition/process/affordance separation, scope identity, and cross-family collisions",
           ["affordance versus condition", "affordance versus process", "exposure without impairment", "many unrelated failures", "pathway versus route", "susceptibility versus risk score"].all? do |concept|
             affordance_stress.any? { |test| test["english_concept"] == concept }
           end)

packet_paths = Dir[File.join(ROOT, "reviews/{WRN_000_022,WRN_100_122,WRN_200_222}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_wrn_000_022_review.rb build_wrn_100_122_review.rb build_wrn_200_222_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "all three WRN packet builders are idempotent in #{mode} mode", builders_ok && before == after)

checks.add("canonical lower-layer alignment", "canonical WRN:000–122 titles and invariants match the authoritative lexicon",
           (entity_roots.merge(process_roots)).all? do |id, root|
             atom = atoms.fetch(id)
             atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
           end)

if mode == "canonical"
  checks.add("canonical affordance alignment", "approved WRN:200–222 titles and invariants match the authoritative lexicon",
             affordance_roots.all? do |id, root|
               atom = atoms.fetch(id)
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional WRN:200–222 roots",
             affordance_spec.dig("metadata", "roots_canonicalized").to_a.empty? && affordance_roots.values.none? { |root| root["canonicalized"] })
end

checks.add("prior approval immutability", "WRN:000–022 and WRN:100–122 approval migrations remain byte-identical",
           Digest::SHA256.file(File.join(ROOT, "migrations/WRN_000_022_semantic_approval.yaml")).hexdigest == "589d7395d4b9f6956b9fcb2c724919200a8d6d9759408b74a5f4e4d0333eaaaf" &&
             Digest::SHA256.file(File.join(ROOT, "migrations/WRN_100_122_semantic_approval.yaml")).hexdigest == "576fc6f5b2365ef6a23093e9075554c745e3dc390dcb15db419e7a080a279eb7")

report = checks.markdown(
  title: "WRN:000–222 Full-Family Warning Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — COMPLETE CANONICAL WARNING FAMILY SOUND" : "PASS — WRN:200–222 READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**", "Roots audited: **27**", "Generated-form assertions: **216**",
    "Affordance runtime interpretations: **27**", "Stress tests: **#{entity_stress.length + process_stress.length + affordance_stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`WRN:0xx` identifies adverse conditions. `WRN:1xx` identifies actual adverse transformations. `WRN:2xx` states only the corresponding adverse affordance: one entity's susceptibility to internal degradation, one source-target exposure relation that can enable impairment, or one pathway that can enable a correlated adverse condition to propagate across system participants. No layer entails another.\n\n"
report << "Persistent, operative, and latent lexical thirds are part of root identity. Persistent identity may co-occur with operation or latency; operative and latent are exclusive for the same affordance at one reference time. Runtime `[0]`, `[1]`, or `[2]/num` qualifies an assertion and never changes lexical status. In particular `WRN:200[2]/num` is uncertainty about persistent susceptibility, while `WRN:202[1]` affirms latent susceptibility.\n\n"
report << "**#{checks.success? ? 'COMPLETE WRN FAMILY SOUNDNESS CONTRACT SATISFIED' : 'COMPLETE WRN FAMILY SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/WRN_000_222_soundness_audit.md", report)

puts "WRN:000–222 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
