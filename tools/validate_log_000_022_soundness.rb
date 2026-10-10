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

range = "LOG:000–022"
ids = EraZeroValidation.ids_for_range(range)
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
recommended = EraZeroValidation.load_yaml("reviews/LOG_000_022_recommended_spec.yaml")
scored = EraZeroValidation.load_yaml("reviews/LOG_000_022_scored_candidates.yaml")
stress = EraZeroValidation.load_yaml("reviews/LOG_000_022_stress_tests.yaml").fetch("tests")
roots = recommended.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scored.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
mode = options.fetch(:mode)
mode = atoms.fetch("LOG:000")["status"] == "canonical" ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("complete packet scope", "all nine LOG:000–022 records are present once",
           roots.keys == ids && score_roots.keys == ids)

checks.add("immutable generated forms", "all 72 generated-form fields match the fixed algorithms",
           ids.all? do |id|
             atom = atoms.fetch(id)
             EraZeroValidation.generated_field_errors({ id => atom }).empty? &&
               roots.fetch(id).fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atom) &&
               score_roots.fetch(id).fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atom)
           end)

checks.add("authority boundary", "review mode leaves nine provisional roots; canonical mode requires all nine approved",
           if mode == "review"
             ids.all? { |id| atoms.fetch(id)["status"] == "provisional_pending_detailed_semantic_review" }
           else
             ids.all? { |id| atoms.fetch(id)["status"] == "canonical" }
           end)

expected_titles = {
  "LOG:000" => "persistent internal formal criterion",
  "LOG:001" => "operative internal formal criterion",
  "LOG:002" => "dormant internal formal criterion",
  "LOG:010" => "persistent target-directed formal constraint",
  "LOG:011" => "operative target-directed formal constraint",
  "LOG:012" => "dormant target-directed formal constraint",
  "LOG:020" => "persistent shared formal regime",
  "LOG:021" => "operative shared formal regime",
  "LOG:022" => "dormant shared formal regime"
}.freeze
checks.add("exact semantic grid", "the recommended grid matches the selected formal-constraint architecture",
           ids.all? { |id| roots.fetch(id)["proposed_title"] == expected_titles.fetch(id) })

checks.add("entity-layer ontology", "every invariant is a formal constraint entity rather than an evaluation process, result, or relation",
           ids.all? do |id|
             root = roots.fetch(id)
             root.dig("address_justification", "first_trit_0").to_s.include?("formal rule or constraint entity") &&
               root.fetch("same_family_contrast").include?("LOG:1xx") && root.fetch("same_family_contrast").include?("LOG:2xx")
           end)

checks.add("internal-criterion triplet", "LOG:000–002 changes only identity or present operation of one internal formal criterion",
           %w[LOG:000 LOG:001 LOG:002].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("formal criterion within the logical specification of one reference entity") &&
               definition.include?("admissible states")
           end)

checks.add("target-constraint triplet", "LOG:010–012 changes only identity or present operation of one target-directed formal constraint",
           %w[LOG:010 LOG:011 LOG:012].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("formal constraint assigned to one distinct reference target") &&
               definition.include?("admissible states")
           end)

checks.add("shared-regime triplet", "LOG:020–022 changes only identity or present operation of one shared formal regime",
           %w[LOG:020 LOG:021 LOG:022].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("formal regime") && definition.include?("multiple participants") &&
               definition.include?("shared rule domain") && definition.include?("admissibility criteria")
           end)

phase_words = {
  "LOG:000" => "independently of whether the criterion is presently operative",
  "LOG:001" => "presently operative",
  "LOG:002" => "without presently operating",
  "LOG:010" => "independently of whether the constraint is presently operative",
  "LOG:011" => "presently operative",
  "LOG:012" => "without presently operating",
  "LOG:020" => "independently of whether the regime is presently operative",
  "LOG:021" => "presently operative",
  "LOG:022" => "without presently operating"
}.freeze
checks.add("third-trit discipline", "every invariant contains its exact persistent/operative/dormant discriminator",
           phase_words.all? { |id, phrase| roots.fetch(id).fetch("invariant_definition").include?(phrase) })

forbidden = /truth|false|satisf|violat|valid|invalid|proof|infer|evaluat|execut|record|schema|symbol|value|belief|authority|enforce|sanction|schedule|future|possible|necessary|probab/i
checks.add("collision-free invariants", "invariants exclude truth values, evaluation results, data representations, beliefs, authority, enforcement, and modality",
           ids.none? { |id| roots.fetch(id).fetch("invariant_definition").match?(forbidden) })

checks.add("boundary completeness", "every root has substantial inclusion, exclusions, and same-family contrasts",
           ids.all? do |id|
             root = roots.fetch(id)
             root.fetch("inclusion_boundary").length >= 180 && root.fetch("excluded_meanings").length >= 6 &&
               root.fetch("nearest_neighbors").length >= 4 && root.fetch("same_family_contrast").length >= 180
           end)

checks.add("runtime-state tailoring", "all 27 runtime meanings are specific and lexical/runtime separation is explicit",
           ids.all? do |id|
             root = roots.fetch(id)
             states = root.fetch("runtime_state_interpretation")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set &&
               states.values.all? { |value| value.length >= 90 } &&
               root.fetch("lexical_runtime_distinction").include?("Runtime")
           end)

checks.add("cross-family routing", "every root distinguishes all eleven competing families",
           ids.all? do |id|
             comparisons = roots.fetch(id).fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["LOG"]).to_set &&
               comparisons.values.all? { |value| value.length >= 70 }
           end)

checks.add("example coverage", "each root has six typed examples, runtime/contour/register data, and a counterexample",
           ids.all? do |id|
             examples = roots.fetch(id).fetch("examples")
             examples.length >= 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per root yield one unique winner",
           ids.all? do |id|
             record = score_roots.fetch(id)
             candidates = record.fetch("candidates")
             best = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == best }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "formal_constraint_entities" &&
               record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)

checks.add("coverage routing", "at least 100 unique English concepts use varied non-forced routes",
           stress.length >= 100 && stress.map { |test| test.fetch("english_concept") }.uniq.length == stress.length &&
             stress.map { |test| test.fetch("routing") }.uniq.length >= 10 &&
             stress.all? { |test| test.fetch("analysis").length >= 30 })

required_stress = ["rule", "permission", "truth", "satisfied constraint", "suspended rule", "deleted rule",
                   "type constraint", "schema", "program", "formal system", "rule versus execution",
                   "rule versus applicability", "operative and dormant rule simultaneously", "persistent rule uncertain"].freeze
checks.add("focused semantic stress", "coverage tests rule identity, operation, results, data, modality, and layer boundaries",
           required_stress.all? { |concept| stress.any? { |test| test["english_concept"] == concept } })

packet_paths = Dir[File.join(ROOT, "reviews/LOG_000_022_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
_stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools/build_log_000_022_review.rb"), chdir: ROOT)
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "the LOG packet builder is idempotent in #{mode} mode", status.success? && before == after)

if mode == "canonical"
  checks.add("canonical meaning alignment", "approved titles and invariants match live authority",
             ids.all? do |id|
               atom = atoms.fetch(id)
               root = roots.fetch(id)
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             end)
else
  checks.add("pre-approval isolation", "review artifacts do not canonize provisional roots",
             recommended.dig("metadata", "roots_canonicalized").to_a.empty? && roots.values.none? { |root| root["canonicalized"] })
end

report = checks.markdown(
  title: "LOG:000–022 Formal-Constraint Entity-Layer Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL LOGIC ENTITY LAYER SOUND" : "PASS — READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**",
    "Roots audited: **9**",
    "Semantic architecture: **internal criteria / target constraints / shared formal regimes**",
    "Generated-form assertions: **72**",
    "Runtime interpretations: **27**",
    "Stress tests: **#{stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`LOG:000–002` identifies one formal criterion within a reference entity's logical specification. `LOG:010–012` identifies one formal constraint assigned to one distinct target. `LOG:020–022` identifies one correlated formal regime across multiple participants in a shared rule domain. The persistent member preserves rule identity and may co-occur with its operative or dormant sibling; operative and dormant are exclusive at one reference time. No root entails proposition truth, satisfaction, violation, evaluation, proof, execution, represented data, belief, authority, enforcement, or modality.\n\n"
report << "**#{checks.success? ? 'LOGIC ENTITY-LAYER SOUNDNESS CONTRACT SATISFIED' : 'LOGIC ENTITY-LAYER SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/LOG_000_022_soundness_audit.md", report)

puts "LOG:000–022 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
