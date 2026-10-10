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
  opts.banner = "Usage: ruby tools/validate_str_000_222_soundness.rb [--mode review|canonical]"
  opts.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode }
end.parse!

entity_ids = EraZeroValidation.ids_for_range("STR:000–022")
process_ids = EraZeroValidation.ids_for_range("STR:100–122")
affordance_ids = EraZeroValidation.ids_for_range("STR:200–222")
all_ids = entity_ids + process_ids + affordance_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
entity_spec = EraZeroValidation.load_yaml("reviews/STR_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/STR_100_122_recommended_spec.yaml")
affordance_spec = EraZeroValidation.load_yaml("reviews/STR_200_222_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/STR_200_222_scored_candidates.yaml")
entity_stress = EraZeroValidation.load_yaml("reviews/STR_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/STR_100_122_stress_tests.yaml").fetch("tests")
affordance_stress = EraZeroValidation.load_yaml("reviews/STR_200_222_stress_tests.yaml").fetch("tests")

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

checks.add("authority mode", "STR:000–122 stays canonical and STR:200–222 has one requested authority state",
           (entity_ids + process_ids).all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))

checks.add("exact family scope", "the audit covers exactly all twenty-seven STR roots",
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

checks.add("entity/process/affordance separation", "STR:0xx names loci or arrangements, STR:1xx transformations, and STR:2xx capacities or qualifying relations",
           entity_roots.values.none? { |root| root.fetch("invariant_definition").match?(/transformation|capacity|qualif|reconfigurability|incorporability|integrability/i) } &&
             process_roots.values.all? { |root| root.fetch("invariant_definition").include?("structural transformation") } &&
             affordance_roots.values.all? { |root| root.fetch("invariant_definition").match?(/capacity|relation|possibility/) } &&
             affordance_roots.values.none? { |root| root.fetch("invariant_definition").match?(/completion of|ongoing structural transformation|nonactualized structural transformation/i) })

checks.add("inward affordance triplet", "STR:200–202 changes only endurance/availability of internal reconfiguration capacity",
           %w[STR:200 STR:201 STR:202].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("capacity of a reference structure") && definition.include?("reassign its own constituents") &&
               definition.include?("internal positions") && definition.include?("reference whole")
           end)

checks.add("outward affordance triplet", "STR:210–212 changes only status of one target's qualification for incorporation into a preserved host",
           %w[STR:210 STR:211 STR:212].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("one distinct target") && definition.include?("incorporation as a constituent") &&
               (id == "STR:212" || definition.include?("preserving the reference as the organizing whole"))
           end)

checks.add("systemic affordance triplet", "STR:220–222 changes only status of multi-structure qualification for a higher-order composite",
           %w[STR:220 STR:221 STR:222].all? do |id|
             definition = affordance_roots.fetch(id).fetch("invariant_definition")
             definition.include?("multiple structures") && definition.include?("peer constituents") &&
               definition.include?("higher-order composite") && definition.include?("distinct from every input")
           end)

phase_phrases = {
  "STR:200" => "A persistent capacity", "STR:201" => "A capacity", "STR:202" => "A capacity",
  "STR:210" => "A persistent structural relation", "STR:211" => "A structural relation", "STR:212" => "An unresolved structural relation",
  "STR:220" => "A persistent structural relation", "STR:221" => "A structural relation", "STR:222" => "An unrealized structural possibility"
}.freeze
checks.add("third-trit discipline", "stable, active, and dormant/unresolved lexical statuses are expressed exactly",
           phase_phrases.all? { |id, phrase| affordance_roots.fetch(id).fetch("invariant_definition").start_with?(phrase) } &&
             affordance_roots.fetch("STR:201").fetch("invariant_definition").include?("presently available") &&
             affordance_roots.fetch("STR:202").fetch("invariant_definition").include?("without being presently available") &&
             affordance_roots.fetch("STR:211").fetch("invariant_definition").include?("presently qualifies") &&
             affordance_roots.fetch("STR:212").fetch("invariant_definition").include?("remains undetermined") &&
             affordance_roots.fetch("STR:221").fetch("invariant_definition").include?("presently qualifies"))

checks.add("outward/systemic identity separation", "outward preserves one host while systemic treats all inputs as peers beneath a distinct higher-order whole",
           %w[STR:210 STR:211 STR:212].all? do |id|
             contrast = affordance_roots.fetch(id).fetch("same_family_contrast")
             contrast.include?("preserves one reference") && contrast.include?("exactly one distinct target")
           end &&
             %w[STR:220 STR:221 STR:222].all? do |id|
               contrast = affordance_roots.fetch(id).fetch("same_family_contrast")
               contrast.include?("multiple inputs as peer candidates") && contrast.include?("distinct from every input")
             end)

checks.add("layer non-entailment", "each affordance root explicitly separates entities, actual processes, and persistent relations",
           affordance_roots.values.all? do |root|
             contrast = root.fetch("same_family_contrast")
             contrast.include?("STR:0xx") && contrast.include?("STR:1xx") && contrast.include?("STR:2xx") &&
               contrast.include?("does not entail")
           end)

checks.add("collision-free invariants", "winner invariants exclude rejected load/support/governance and cross-family semantic mixtures",
           affordance_roots.values.none? do |root|
             root.fetch("invariant_definition").match?(/load|support|contain|attach|govern|authority|communicat|repair|resilien|schema|type|permission|probab|schedule|future|material|physical/i)
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

checks.add("lexical-2/runtime-2 contrast", "focused examples distinguish a lexical third trit of 2 from runtime [2]/num on a stable sibling",
           affordance_stress.any? { |test| test["english_concept"] == "stable capacity currently uncertain" && test["analysis"].include?("STR:200[2]/num") } &&
             affordance_stress.any? { |test| test["english_concept"] == "latent capacity affirmed" && test["analysis"].include?("STR:202[1]") } &&
             affordance_stress.any? { |test| test["english_concept"] == "unresolved fit affirmed" && test["analysis"].include?("STR:212[1]") })

checks.add("cross-family routing", "every affordance root distinguishes all eleven competing families",
           affordance_roots.values.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["STR"]).to_set && comparisons.values.all? { |value| value.length >= 130 }
           end)

checks.add("example coverage", "each affordance root has six typed examples with graphs, glosses, state, contour, roles, and a counterexample",
           affordance_roots.values.all? do |root|
             examples = root.fetch("examples")
             examples.length == 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per address yield one unique transformation-affordance winner",
           affordance_ids.all? do |id|
             root = score_roots.fetch(id)
             candidates = root.fetch("candidates")
             maximum = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == maximum }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "transformation_affordance" &&
               root["recommended_candidate_id"] == "transformation_affordance" && candidates.map { |candidate| candidate["total"] }.uniq.length >= 4
           end)

checks.add("coverage routing", "at least seventy-five unique concepts use varied non-forced routes",
           affordance_stress.length >= 75 && affordance_stress.map { |test| test.fetch("english_concept") }.uniq.length == affordance_stress.length &&
             affordance_stress.map { |test| test.fetch("routing") }.uniq.length >= 12 &&
             affordance_stress.all? { |test| test.fetch("analysis").length >= 55 })

checks.add("focused layer stress tests", "the packet tests capacity/process, fit/incorporation, integrability/integration, and scope identity",
           ["capacity versus active process", "fit relation versus incorporation", "integrability relation versus integration", "one host absorbs one subsystem", "two hosts can form a new cluster"].all? do |concept|
             affordance_stress.any? { |test| test["english_concept"] == concept }
           end)

packet_paths = Dir[File.join(ROOT, "reviews/{STR_000_022,STR_100_122,STR_200_222}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders_ok = %w[build_str_000_022_review.rb build_str_100_122_review.rb build_str_200_222_review.rb].all? do |builder|
  _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", builder), chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "all three STR packet builders are idempotent in #{mode} mode", builders_ok && before == after)

checks.add("canonical lower-layer alignment", "canonical STR:000–122 titles and invariants match the authoritative lexicon",
           (entity_roots.merge(process_roots)).all? do |id, root|
             atom = atoms.fetch(id)
             atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
           end)

if mode == "canonical"
  checks.add("canonical affordance alignment", "approved STR:200–222 titles and invariants match the authoritative lexicon",
             affordance_roots.all? do |id, root|
               atom = atoms.fetch(id)
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional STR:200–222 roots",
             affordance_spec.dig("metadata", "roots_canonicalized").to_a.empty? && affordance_roots.values.none? { |root| root["canonicalized"] })
end

checks.add("prior approval immutability", "STR:000–022 and STR:100–122 approval migrations remain byte-identical",
           Digest::SHA256.file(File.join(ROOT, "migrations/STR_000_022_semantic_approval.yaml")).hexdigest == "8838255265e74746648c0fcfc33d8c320b92f7f74fd8145b7326ff9b99593d70" &&
             Digest::SHA256.file(File.join(ROOT, "migrations/STR_100_122_semantic_approval.yaml")).hexdigest == "150cbc94c66001a156109145b40184b7968d2a96a383ffe5e4f2eb142caa5268")

report = checks.markdown(
  title: "STR:000–222 Full-Family Structural Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — COMPLETE CANONICAL STRUCTURE FAMILY SOUND" : "PASS — STR:200–222 READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**", "Roots audited: **27**", "Generated-form assertions: **216**",
    "Affordance runtime interpretations: **27**", "Stress tests: **#{entity_stress.length + process_stress.length + affordance_stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`STR:0xx` identifies structural loci and arrangements. `STR:1xx` changes constituent organization. `STR:2xx` states only the corresponding affordance: reconfigurability of one structure's own constituents, qualification of one target for incorporation into a preserved host, or qualification of multiple peer inputs for a higher-order composite. No layer entails another.\n\n"
report << "Stable, active, and dormant/unresolved lexical thirds are part of the root identity. Runtime `[0]`, `[1]`, or `[2]/num` qualifies an assertion about that root and never changes lexical status. In particular `STR:200[2]/num` is uncertainty about enduring capacity, while `STR:202[1]` affirms latent capacity.\n\n"
report << "**#{checks.success? ? 'COMPLETE STR FAMILY SOUNDNESS CONTRACT SATISFIED' : 'COMPLETE STR FAMILY SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/STR_000_222_soundness_audit.md", report)

puts "STR:000–222 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
