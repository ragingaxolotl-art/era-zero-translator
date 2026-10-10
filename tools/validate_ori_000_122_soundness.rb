#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"; require "open3"; require "optparse"; require "rbconfig"; require "set"
require_relative "lib/era_zero_validation"
include EraZeroValidation

options = { mode: "auto" }
OptionParser.new { |p| p.on("--mode MODE", %w[auto review canonical]) { |v| options[:mode] = v } }.parse!
entity_ids = EraZeroValidation.ids_for_range("ORI:000–022")
process_ids = EraZeroValidation.ids_for_range("ORI:100–122")
all_ids = entity_ids + process_ids
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
entity_spec = EraZeroValidation.load_yaml("reviews/ORI_000_022_recommended_spec.yaml")
process_spec = EraZeroValidation.load_yaml("reviews/ORI_100_122_recommended_spec.yaml")
scores = EraZeroValidation.load_yaml("reviews/ORI_100_122_scored_candidates.yaml")
entity_stress = EraZeroValidation.load_yaml("reviews/ORI_000_022_stress_tests.yaml").fetch("tests")
process_stress = EraZeroValidation.load_yaml("reviews/ORI_100_122_stress_tests.yaml").fetch("tests")
map = ->(spec) { spec.fetch("roots").to_h { |r| [r.dig("fixed_generated_fields", "canonical_id"), r] } }
entity_roots = map.call(entity_spec); process_roots = map.call(process_spec)
score_roots = scores.fetch("roots").to_h { |r| [r.fetch("canonical_id"), r] }
statuses = process_ids.map { |id| atoms.fetch(id).fetch("status") }.uniq
mode = options.fetch(:mode); mode = statuses == ["canonical"] ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("authority mode", "ORI conditions remain canonical and processes share requested authority", entity_ids.all? { |id| atoms.fetch(id)["status"] == "canonical" } && statuses.length == 1 && (mode == "canonical" ? statuses.first == "canonical" : statuses.first == "provisional_pending_detailed_semantic_review"))
checks.add("exact scope", "audit covers exactly eighteen Origin roots", entity_roots.keys == entity_ids && process_roots.keys == process_ids && all_ids.uniq.length == 18)
checks.add("generated-form integrity", "all 144 fixed generated fields follow deterministic algorithms", all_ids.all? { |id| (entity_roots[id] || process_roots[id]).fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atoms.fetch(id)) })
checks.add("semantic uniqueness", "all titles and invariant definitions are unique", begin
  roots = entity_roots.values + process_roots.values
  roots.map { |r| r.fetch("proposed_title") }.uniq.length == 18 && roots.map { |r| r.fetch("invariant_definition") }.uniq.length == 18
end)
checks.add("condition/process separation", "ORI:0xx owns conditions and ORI:1xx owns ontological transitions", entity_roots.values.all? { |r| r.dig("address_justification", "first_trit_0").to_s.include?("ontological entity or condition") } && process_roots.values.all? { |r| r.dig("address_justification", "first_trit_1").to_s.include?("bounded ontological transition") })
checks.add("source-ground process triplet", "ORI:100–102 changes only phase of source-ground establishment", %w[ORI:100 ORI:101 ORI:102].all? { |id| (d=process_roots.fetch(id).fetch("invariant_definition")).include?("bounded ontological transition") && d.include?("ground") && d.include?("source") && d.include?("state of affairs may originate") })
checks.add("distinct-actualization triplet", "ORI:110–112 changes only phase of distinct actualization", %w[ORI:110 ORI:111 ORI:112].all? { |id| (d=process_roots.fetch(id).fetch("invariant_definition")).include?("bounded ontological transition") && d.include?("one distinct referent") && d.include?("relevant reality") })
checks.add("shared-world triplet", "ORI:120–122 changes only phase of shared-world transition", %w[ORI:120 ORI:121 ORI:122].all? { |id| (d=process_roots.fetch(id).fetch("invariant_definition")).include?("bounded ontological transition") && d.include?("one shared reality") && d.include?("jointly applicable world condition") })
phase = process_ids.to_h { |id| [id, id.end_with?("0") ? "Completion of" : id.end_with?("1") ? "An ongoing" : "A nonactualized"] }
checks.add("third-trit discipline", "completed, active, and nonactualized phases are exact", phase.all? { |id,prefix| process_roots.fetch(id).fetch("invariant_definition").start_with?(prefix) })
checks.add("nonactualized neutrality", "lexical 1x2 excludes planning, modality, and futurity", %w[ORI:102 ORI:112 ORI:122].all? { |id| (t=process_roots.fetch(id).fetch("invariant_definition")).include?("nonactualized") && !t.match?(/intend|plan|schedul|queue|ready|future|probab|possible|permit/i) })
forbidden = /observ|evidence|database|material|biological|author|manufactur|probab|necessary|counterfactual|schedule|future|possible/i
checks.add("collision-neutral invariants", "invariants exclude observation, representation, substrate, production, and modality", process_roots.values.none? { |r| r.fetch("invariant_definition").match?(forbidden) })
checks.add("layer anchoring", "every process root distinguishes ORI entity, process, and relation layers", process_roots.values.all? { |r| (t=r.fetch("same_family_contrast")).include?("ORI:0xx") && t.include?("ORI:1xx") && t.include?("ORI:2xx") })
checks.add("boundary completeness", "every process root has substantial boundaries and neighbors", process_roots.values.all? { |r| r.fetch("inclusion_boundary").length >= 300 && r.fetch("excluded_meanings").length >= 6 && r.fetch("nearest_neighbors").length >= 6 && r.fetch("same_family_contrast").length >= 400 })
checks.add("runtime tailoring", "all runtime meanings are specific and separate from lexical phase", process_roots.values.all? { |r| (s=r.fetch("runtime_state_interpretation")).keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && s.values.all? { |v| v.length >= 110 } && r.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`") })
checks.add("cross-family routing", "every process root distinguishes all eleven competing families", process_roots.values.all? { |r| (c=r.fetch("cross_family_comparisons")).keys.to_set == (EraZeroValidation::FAMILIES.keys-["ORI"]).to_set && c.values.all? { |v| v.length >= 90 } })
checks.add("example coverage", "each process root has six typed examples and a counterexample", process_roots.values.all? { |r| (e=r.fetch("examples")).length == 6 && e.any? { |x| x["use_status"] == "must_not_use_this_root" } && e.all? { |x| x["semantic_graph"] && x["literal_gloss"] && x["natural_english"] && x.key?("runtime_state") && x["contour"] && x["role_registers"] } })
checks.add("candidate challenge", "five architectures yield one ontological-transition winner", process_ids.all? { |id| (cs=score_roots.fetch(id).fetch("candidates")); best=cs.map { |c| c["total"] }.max; cs.length == 5 && cs.count { |c| c["total"] == best } == 1 && cs.find { |c| c["total"] == best }["candidate_id"] == "ontological_transitions" && score_roots.fetch(id)["recommended_candidate_id"] == "ontological_transitions" })
checks.add("coverage routing", "at least one hundred unique concepts use varied non-forced routes", process_stress.length >= 100 && process_stress.map { |t| t["english_concept"] }.uniq.length == process_stress.length && process_stress.map { |t| t["routing"] }.uniq.length >= 10 && process_stress.all? { |t| t["analysis"].length >= 30 })
required = ["begin", "become", "actualize", "originate", "entity came into existence", "world changed", "artifact created", "caused", "scheduled to begin", "possible actualization", "active transition uncertain", "nonactualized transition affirmed", "annihilate"]
checks.add("focused semantic stress", "tests process centers, phases, modality, causation, and collisions", required.all? { |c| process_stress.any? { |t| t["english_concept"] == c } })

paths = Dir[File.join(ROOT, "reviews/{ORI_000_022,ORI_100_122}_*{yaml,md}")].sort
before = paths.to_h { |p| [p,Digest::SHA256.file(p).hexdigest] }
builders_ok = %w[build_ori_000_022_review.rb build_ori_100_122_review.rb].all? { |b| Open3.capture3(RbConfig.ruby,File.join(ROOT,"tools",b),chdir:ROOT)[2].success? }
after = paths.to_h { |p| [p,Digest::SHA256.file(p).hexdigest] }
checks.add("review-builder rerun safety", "both Origin packet builders are idempotent", builders_ok && before == after)
checks.add("canonical condition alignment", "approved ORI:000–022 meanings match live authority", entity_ids.all? { |id| atoms.fetch(id)["title"] == entity_roots.fetch(id)["proposed_title"] && atoms.fetch(id)["core_definition"] == entity_roots.fetch(id)["invariant_definition"] })
if mode == "canonical"
  checks.add("canonical process alignment", "approved ORI:100–122 meanings match live authority", process_ids.all? { |id| atoms.fetch(id)["title"] == process_roots.fetch(id)["proposed_title"] && atoms.fetch(id)["core_definition"] == process_roots.fetch(id)["invariant_definition"] })
else
  checks.add("pre-approval isolation", "review leaves ORI:100–122 provisional", process_spec.dig("metadata","roots_canonicalized").to_a.empty? && process_roots.values.none? { |r| r["canonicalized"] })
end

report = checks.markdown(title:"ORI:000–122 Combined Condition/Transition Soundness Audit", pass_status: mode == "canonical" ? "PASS — CANONICAL ORIGIN CONDITION AND TRANSITION LAYERS SOUND" : "PASS — ORI:100–122 READY FOR DELEGATED APPROVAL", summary:["Mode: **#{mode}**","Roots audited: **18**","Generated-form assertions: **144**","Process runtime interpretations: **27**","Stress tests: **#{entity_stress.length+process_stress.length}**"])
report << "\n## Required interpretation\n\n`ORI:0xx` identifies source-ground, distinct-existence, and shared-world conditions. `ORI:1xx` identifies the corresponding bounded ontological transitions: source-ground establishment, distinct actualization, and shared-world transition. Completion does not entail persistence, observation, physical realization, production, truth, or success. Lexical `1x2` is nonactualized only; runtime `[2]/num` remains assertion-level uncertainty.\n\n"
report << "**#{checks.success? ? 'COMBINED ORIGIN SOUNDNESS CONTRACT SATISFIED' : 'COMBINED ORIGIN SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/ORI_000_122_soundness_audit.md",report)
puts "ORI:000–122 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"; puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"; checks.failures.each { |f| warn f }; exit(checks.success? ? 0 : 1)
