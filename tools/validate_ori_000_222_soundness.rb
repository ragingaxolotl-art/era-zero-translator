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
OptionParser.new { |p| p.on("--mode MODE", %w[auto review canonical]) { |v| options[:mode] = v } }.parse!
ranges = %w[ORI:000–022 ORI:100–122 ORI:200–222]
ids = ranges.to_h { |range| [range, EraZeroValidation.ids_for_range(range)] }
all_ids = ids.values.flatten
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
specs = ranges.to_h { |range| [range, EraZeroValidation.load_yaml("reviews/#{EraZeroValidation.stem_for_range(range)}_recommended_spec.yaml")] }
scores = EraZeroValidation.load_yaml("reviews/ORI_200_222_scored_candidates.yaml")
stresses = ranges.to_h { |range| [range, EraZeroValidation.load_yaml("reviews/#{EraZeroValidation.stem_for_range(range)}_stress_tests.yaml").fetch("tests")] }
map = ->(spec) { spec.fetch("roots").to_h { |r| [r.dig("fixed_generated_fields", "canonical_id"), r] } }
roots = specs.transform_values { |spec| map.call(spec) }
relation_ids = ids.fetch("ORI:200–222")
relation_roots = roots.fetch("ORI:200–222")
score_roots = scores.fetch("roots").to_h { |r| [r.fetch("canonical_id"), r] }
statuses = relation_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options.fetch(:mode)
mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "earlier Origin layers remain canonical and relation roots share requested authority", ids.values_at("ORI:000–022", "ORI:100–122").flatten.all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 && (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))
checks.add("exact scope", "audit covers exactly twenty-seven Origin roots", roots.values.flat_map(&:keys) == all_ids && all_ids.uniq.length == 27)
checks.add("generated-form integrity", "all 216 fixed generated fields follow deterministic algorithms", all_ids.all? { |id| roots.values.find { |group| group.key?(id) }.fetch(id).fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atoms.fetch(id)) })
checks.add("semantic uniqueness", "all Origin titles and invariant definitions are unique", begin
  list = roots.values.flat_map(&:values)
  list.map { |r| r.fetch("proposed_title") }.uniq.length == 27 && list.map { |r| r.fetch("invariant_definition") }.uniq.length == 27
end)
checks.add("three-layer separation", "ORI:0xx conditions, ORI:1xx transitions, and ORI:2xx relations remain distinct", roots.fetch("ORI:000–022").values.all? { |r| r.dig("address_justification", "first_trit_0").to_s.include?("ontological entity or condition") } && roots.fetch("ORI:100–122").values.all? { |r| r.dig("address_justification", "first_trit_1").to_s.include?("bounded ontological transition") } && relation_roots.values.all? { |r| r.dig("address_justification", "first_trit_2").to_s.include?("ontological relation") })
checks.add("source-capacity triplet", "ORI:200–202 changes only status of source-grounding capacity", %w[ORI:200 ORI:201 ORI:202].all? { |id| (d=relation_roots.fetch(id).fetch("invariant_definition")).include?("ontological capacity") && d.include?("source") && d.include?("ground") && d.include?("specified state of affairs") })
checks.add("target-dependence triplet", "ORI:210–212 changes only status of target-ground dependence", %w[ORI:210 ORI:211 ORI:212].all? { |id| (d=relation_roots.fetch(id).fetch("invariant_definition")).include?("ontological relation") && d.include?("target's obtaining") && d.include?("specified ground") })
checks.add("world-constraint triplet", "ORI:220–222 changes only status of shared-world constraint", %w[ORI:220 ORI:221 ORI:222].all? { |id| (d=relation_roots.fetch(id).fetch("invariant_definition")).include?("ontological relation") && d.include?("shared reality") && d.match?(/limit|admissible order/) })
checks.add("third-trit discipline", "persistent, operative, and latent lexical statuses are exact", relation_ids.all? do |id|
  d = relation_roots.fetch(id).fetch("invariant_definition")
  id.end_with?("0") ? d.match?(/persistent/i) : id.end_with?("1") ? d.match?(/presently operative|presently conditioning|presently limiting/i) : d.match?(/without .*presently operative|without presently limiting/i)
end)
checks.add("latency neutrality", "lexical 2x2 excludes uncertainty, scheduling, and unrestricted modality", %w[ORI:202 ORI:212 ORI:222].all? { |id| !relation_roots.fetch(id).fetch("invariant_definition").match?(/uncertain|unknown|intend|plan|schedul|queue|future|probab/i) })
forbidden = /observ|evidence|database|software|material|biological|author|manufactur|probab|counterfactual|schedule|future/i
checks.add("collision-neutral invariants", "invariants exclude observation, representation, implementation, substrate, and probability", relation_roots.values.none? { |r| r.fetch("invariant_definition").match?(forbidden) })
checks.add("layer anchoring", "every relation root distinguishes all three ORI layers", relation_roots.values.all? { |r| (t=r.fetch("same_family_contrast")).include?("ORI:0xx") && t.include?("ORI:1xx") && t.include?("ORI:2xx") })
checks.add("boundary completeness", "every relation root has substantial boundaries and neighbors", relation_roots.values.all? { |r| r.fetch("inclusion_boundary").length >= 300 && r.fetch("excluded_meanings").length >= 6 && r.fetch("nearest_neighbors").length >= 6 && r.fetch("same_family_contrast").length >= 400 })
checks.add("runtime tailoring", "all runtime meanings are specific and separate from lexical status", relation_roots.values.all? { |r| (s=r.fetch("runtime_state_interpretation")).keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && s.values.all? { |v| v.length >= 100 } && r.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`") })
checks.add("cross-family routing", "every relation root distinguishes all eleven competing families", relation_roots.values.all? { |r| (c=r.fetch("cross_family_comparisons")).keys.to_set == (EraZeroValidation::FAMILIES.keys-["ORI"]).to_set && c.values.all? { |v| v.length >= 80 } })
checks.add("example coverage", "each relation root has six typed examples and a counterexample", relation_roots.values.all? { |r| (e=r.fetch("examples")).length == 6 && e.any? { |x| x["use_status"] == "must_not_use_this_root" } && e.all? { |x| x["semantic_graph"] && x["literal_gloss"] && x["natural_english"] && x.key?("runtime_state") && x["contour"] && x["role_registers"] } })
checks.add("candidate challenge", "five architectures yield one grounded-relations winner", relation_ids.all? { |id| (cs=score_roots.fetch(id).fetch("candidates")); best=cs.map { |c| c["total"] }.max; cs.length == 5 && cs.count { |c| c["total"] == best } == 1 && cs.find { |c| c["total"] == best }["candidate_id"] == "grounded_relations" && score_roots.fetch(id)["recommended_candidate_id"] == "grounded_relations" })
relation_stress = stresses.fetch("ORI:200–222")
checks.add("coverage routing", "at least one hundred unique concepts use varied non-forced routes", relation_stress.length >= 100 && relation_stress.map { |t| t["english_concept"] }.uniq.length == relation_stress.length && relation_stress.map { |t| t["routing"] }.uniq.length >= 10 && relation_stress.all? { |t| t["analysis"].length >= 30 })
required = ["capacity", "can ground", "depends on", "necessary condition", "world law", "cause", "possible world", "logical entailment", "database dependency", "latent relation affirmed", "operative relation uncertain"]
checks.add("focused semantic stress", "tests capacities, dependencies, constraints, modality, causation, and implementation collisions", required.all? { |concept| relation_stress.any? { |t| t["english_concept"] == concept } })

paths = Dir[File.join(ROOT, "reviews/ORI_{000_022,100_122,200_222}_*{yaml,md}")].sort
before = paths.to_h { |p| [p, Digest::SHA256.file(p).hexdigest] }
builders_ok = %w[build_ori_000_022_review.rb build_ori_100_122_review.rb build_ori_200_222_review.rb].all? { |b| Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools", b), chdir: ROOT)[2].success? }
after = paths.to_h { |p| [p, Digest::SHA256.file(p).hexdigest] }
checks.add("review-builder rerun safety", "all three Origin packet builders are idempotent", builders_ok && before == after)
checks.add("prior layer alignment", "approved ORI:000–122 meanings match live authority", ids.values_at("ORI:000–022", "ORI:100–122").flatten.all? do |id|
  r = roots.values.find { |group| group.key?(id) }.fetch(id)
  atoms.fetch(id)["title"] == r["proposed_title"] && atoms.fetch(id)["core_definition"] == r["invariant_definition"]
end)
if mode == "canonical"
  checks.add("canonical relation alignment", "approved ORI:200–222 meanings match live authority", relation_ids.all? { |id| atoms.fetch(id)["title"] == relation_roots.fetch(id)["proposed_title"] && atoms.fetch(id)["core_definition"] == relation_roots.fetch(id)["invariant_definition"] })
else
  checks.add("pre-approval isolation", "review leaves ORI:200–222 provisional", specs.fetch("ORI:200–222").dig("metadata", "roots_canonicalized").to_a.empty? && relation_roots.values.none? { |r| r["canonicalized"] })
end

report = checks.markdown(title: "ORI:000–222 Full Origin-Family Soundness Audit", pass_status: mode == "canonical" ? "PASS — COMPLETE CANONICAL ORIGIN FAMILY SOUND" : "PASS — ORI:200–222 READY FOR DELEGATED APPROVAL", summary: ["Mode: **#{mode}**", "Roots audited: **27**", "Generated-form assertions: **216**", "Relation runtime interpretations: **27**", "Stress tests: **#{stresses.values.sum(&:length)}**"])
report << "\n## Required interpretation\n\n`ORI:0xx` identifies ontological conditions. `ORI:1xx` identifies bounded transitions that establish or change those conditions. `ORI:2xx` identifies substrate-neutral ontological relations and capacities: source-grounding capacity, target-ground dependence, and shared-world constraint. None entails causal mechanism, time, modality, observation, representation, physical realization, formal proof, or implementation. Lexical `2x2` is latent membership only; runtime `[2]/num` remains assertion-level uncertainty.\n\n"
report << "**#{checks.success? ? 'FULL ORIGIN SOUNDNESS CONTRACT SATISFIED' : 'FULL ORIGIN SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/ORI_000_222_soundness_audit.md", report)
puts "ORI:000–222 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
