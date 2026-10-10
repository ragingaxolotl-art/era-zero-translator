#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "open3"
require "optparse"
require "rbconfig"
require_relative "lib/era_zero_validation"

include EraZeroValidation

options = { mode: "auto" }
OptionParser.new { |parser| parser.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode } }.parse!

range = "ORI:000–022"
ids = EraZeroValidation.ids_for_range(range)
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
recommended = EraZeroValidation.load_yaml("reviews/ORI_000_022_recommended_spec.yaml")
scored = EraZeroValidation.load_yaml("reviews/ORI_000_022_scored_candidates.yaml")
stress = EraZeroValidation.load_yaml("reviews/ORI_000_022_stress_tests.yaml").fetch("tests")
roots = recommended.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scored.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
mode = options.fetch(:mode)
mode = atoms.fetch("ORI:000")["status"] == "canonical" ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("complete packet scope", "all nine ORI:000–022 records are present once", roots.keys == ids && score_roots.keys == ids)
checks.add("immutable generated forms", "all 72 generated-form fields match the fixed algorithms", ids.all? do |id|
  atom = atoms.fetch(id)
  EraZeroValidation.generated_field_errors({ id => atom }).empty? &&
    roots.fetch(id).fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atom) &&
    score_roots.fetch(id).fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atom)
end)
checks.add("authority boundary", "review mode leaves nine provisional roots; canonical mode requires all nine approved",
           ids.all? { |id| atoms.fetch(id)["status"] == (mode == "review" ? "provisional_pending_detailed_semantic_review" : "canonical") })

expected_titles = {
  "ORI:000" => "persistent source-ground condition", "ORI:001" => "operative source-ground condition", "ORI:002" => "latent source-ground condition",
  "ORI:010" => "persistent distinct-existence condition", "ORI:011" => "occurrent distinct-existence condition", "ORI:012" => "latent distinct-existence condition",
  "ORI:020" => "persistent shared-world condition", "ORI:021" => "occurrent shared-world condition", "ORI:022" => "latent shared-world condition"
}.freeze
checks.add("exact semantic grid", "the recommendation matches the selected ontological-condition architecture",
           ids.all? { |id| roots.fetch(id)["proposed_title"] == expected_titles.fetch(id) })
checks.add("entity-condition layer", "every root remains an ontological condition and separates process and relation layers", ids.all? do |id|
  root = roots.fetch(id)
  root.dig("address_justification", "first_trit_0").to_s.include?("ontological entity or condition") &&
    root.fetch("same_family_contrast").include?("ORI:1xx") && root.fetch("same_family_contrast").include?("ORI:2xx")
end)

checks.add("source-ground triplet", "ORI:000–002 changes only status of source-grounding", %w[ORI:000 ORI:001 ORI:002].all? do |id|
  d = roots.fetch(id).fetch("invariant_definition")
  d.include?("ontological condition") && d.include?("grounded as a source") && d.include?("state of affairs may originate")
end)
checks.add("distinct-existence triplet", "ORI:010–012 changes only status of one distinct referent in reality", %w[ORI:010 ORI:011 ORI:012].all? do |id|
  d = roots.fetch(id).fetch("invariant_definition")
  d.include?("ontological condition") && d.include?("one distinct referent") && d.include?("relevant reality")
end)
checks.add("shared-world triplet", "ORI:020–022 changes only status of one shared-world condition", %w[ORI:020 ORI:021 ORI:022].all? do |id|
  d = roots.fetch(id).fetch("invariant_definition")
  d.include?("ontological condition") && d.include?("one shared reality")
end)

phase_phrases = {
  "ORI:000" => "independently of whether that grounding is presently operative", "ORI:001" => "presently operative", "ORI:002" => "without being presently operative",
  "ORI:010" => "independently of whether it is presently manifesting or changing", "ORI:011" => "presently manifesting or changing", "ORI:012" => "without presently manifesting or changing",
  "ORI:020" => "independently of whether that condition is presently being expressed through change", "ORI:021" => "presently being expressed through change", "ORI:022" => "without presently being expressed through change"
}.freeze
checks.add("third-trit discipline", "each invariant contains its exact persistent/occurrent-or-operative/latent discriminator",
           phase_phrases.all? { |id, phrase| roots.fetch(id).fetch("invariant_definition").include?(phrase) })

forbidden = /observ|evidence|proposition|database|material object|living|author|manufactur|probab|necessary|counterfactual|schedule|future/i
checks.add("collision-free invariants", "invariants exclude observation, representation, substrate, authorship, and modal force",
           ids.none? { |id| roots.fetch(id).fetch("invariant_definition").match?(forbidden) })
checks.add("boundary completeness", "every root has substantial inclusion, exclusions, and same-family contrast", ids.all? do |id|
  root = roots.fetch(id)
  root.fetch("inclusion_boundary").length >= 250 && root.fetch("excluded_meanings").length >= 6 &&
    root.fetch("nearest_neighbors").length >= 4 && root.fetch("same_family_contrast").length >= 350
end)
checks.add("runtime-state tailoring", "all 27 runtime meanings are specific and separate lexical status from uncertainty", ids.all? do |id|
  root = roots.fetch(id)
  states = root.fetch("runtime_state_interpretation")
  states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set && states.values.all? { |v| v.length >= 100 } &&
    root.fetch("lexical_runtime_distinction").include?("Runtime `[2]/num`")
end)
checks.add("cross-family routing", "every root distinguishes all eleven competing families", ids.all? do |id|
  c = roots.fetch(id).fetch("cross_family_comparisons")
  c.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["ORI"]).to_set && c.values.all? { |v| v.length >= 100 }
end)
checks.add("example coverage", "each root has six typed examples and a counterexample", ids.all? do |id|
  examples = roots.fetch(id).fetch("examples")
  examples.length == 6 && examples.any? { |e| e["use_status"] == "must_not_use_this_root" } &&
    examples.all? { |e| e["semantic_graph"] && e["literal_gloss"] && e["natural_english"] && e.key?("runtime_state") && e["contour"] && e["role_registers"] }
end)
checks.add("candidate challenge", "five scored architectures per root yield one unique ontological-condition winner", ids.all? do |id|
  record = score_roots.fetch(id)
  candidates = record.fetch("candidates")
  best = candidates.map { |c| c.fetch("total") }.max
  winners = candidates.select { |c| c.fetch("total") == best }
  candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "ontological_conditions" && record["recommended_candidate_id"] == "ontological_conditions"
end)
checks.add("coverage routing", "at least 100 unique concepts use varied non-forced routes", stress.length >= 100 &&
           stress.map { |t| t.fetch("english_concept") }.uniq.length == stress.length && stress.map { |t| t.fetch("routing") }.uniq.length >= 10 &&
           stress.all? { |t| t.fetch("analysis").length >= 30 })
required = ["exists", "source", "origin", "fact", "caused by", "possible", "natural law", "counterfactual object",
            "persistent and occurrent", "occurrent and latent", "latent condition affirmed", "unknown existence", "nothing"]
checks.add("focused semantic stress", "tests ontology against cause, time, truth, observation, modality, and runtime status",
           required.all? { |concept| stress.any? { |test| test["english_concept"] == concept } })

packet_paths = Dir[File.join(ROOT, "reviews/ORI_000_022_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
_out, _err, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools/build_ori_000_022_review.rb"), chdir: ROOT)
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "the ORI packet builder is idempotent in #{mode} mode", status.success? && before == after)

if mode == "canonical"
  checks.add("canonical meaning alignment", "approved titles and invariants match live authority", ids.all? do |id|
    atom = atoms.fetch(id); root = roots.fetch(id)
    atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
  end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional roots",
             recommended.dig("metadata", "roots_canonicalized").to_a.empty? && roots.values.none? { |root| root["canonicalized"] })
end

report = checks.markdown(
  title: "ORI:000–022 Ontological-Condition Layer Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL ORIGIN CONDITION LAYER SOUND" : "PASS — READY FOR DELEGATED APPROVAL",
  summary: ["Mode: **#{mode}**", "Roots audited: **9**", "Generated-form assertions: **72**", "Runtime interpretations: **27**", "Stress tests: **#{stress.length}**"]
)
report << "\n## Required interpretation\n\n`ORI:000–002` qualifies source-grounding, `ORI:010–012` qualifies one distinct referent's existence in a relevant reality, and `ORI:020–022` qualifies a shared-world condition. Persistent status may coexist with occurrence or latency; occurrence and latency are exclusive at one reference time. No root entails cause, beginning, observation, representation, proposition, physical substrate, modal force, provenance, authorship, or productive process.\n\n"
report << "**#{checks.success? ? 'ORIGIN CONDITION-LAYER SOUNDNESS CONTRACT SATISFIED' : 'ORIGIN CONDITION-LAYER SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/ORI_000_022_soundness_audit.md", report)
puts "ORI:000–022 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
