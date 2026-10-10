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

range = "REP:000–022"
ids = EraZeroValidation.ids_for_range(range)
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
recommended = EraZeroValidation.load_yaml("reviews/REP_000_022_recommended_spec.yaml")
scored = EraZeroValidation.load_yaml("reviews/REP_000_022_scored_candidates.yaml")
stress = EraZeroValidation.load_yaml("reviews/REP_000_022_stress_tests.yaml").fetch("tests")
roots = recommended.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scored.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
mode = options.fetch(:mode)
mode = atoms.fetch("REP:000")["status"] == "canonical" ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("complete packet scope", "all nine REP:000–022 records are present once",
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
  "REP:000" => "persistent internal restoration condition",
  "REP:001" => "manifest internal restoration condition",
  "REP:002" => "dormant internal restoration condition",
  "REP:010" => "persistent target restoration condition",
  "REP:011" => "manifest target restoration condition",
  "REP:012" => "dormant target restoration condition",
  "REP:020" => "persistent shared restoration condition",
  "REP:021" => "manifest shared restoration condition",
  "REP:022" => "dormant shared restoration condition"
}.freeze
checks.add("exact semantic grid", "the recommended grid matches the selected restoration-condition architecture",
           ids.all? { |id| roots.fetch(id)["proposed_title"] == expected_titles.fetch(id) })

checks.add("entity-layer ontology", "every invariant is a restoration condition rather than a process, capacity, resource, record, or rule",
           ids.all? do |id|
             root = roots.fetch(id)
             root.dig("address_justification", "first_trit_0").to_s.include?("entity or condition") &&
               root.fetch("same_family_contrast").include?("REP:1xx") && root.fetch("same_family_contrast").include?("REP:2xx")
           end)

checks.add("internal-condition triplet", "REP:000–002 changes only identity or present realization of one internal restoration condition",
           %w[REP:000 REP:001 REP:002].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("acceptable condition internal to one reference entity")
           end)

checks.add("target-condition triplet", "REP:010–012 changes only identity or present realization of one target restoration condition",
           %w[REP:010 REP:011 REP:012].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("acceptable condition of one distinct reference target")
           end)

checks.add("shared-condition triplet", "REP:020–022 changes only identity or present realization of one correlated shared restoration condition",
           %w[REP:020 REP:021 REP:022].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("correlated acceptable condition") &&
               definition.include?("multiple participant entities") && definition.include?("shared system")
           end)

phase_words = {
  "REP:000" => "independently of whether it is presently realized",
  "REP:001" => "presently realized",
  "REP:002" => "without being presently realized",
  "REP:010" => "independently of whether it is presently realized",
  "REP:011" => "presently realized",
  "REP:012" => "without being presently realized",
  "REP:020" => "independently of its present realization pattern",
  "REP:021" => "presently realized",
  "REP:022" => "without being presently realized"
}.freeze
checks.add("third-trit discipline", "every invariant contains its exact persistent/manifest/dormant discriminator",
           phase_words.all? { |id, phrase| roots.fetch(id).fetch("invariant_definition").include?(phrase) })

forbidden = /repairing|healing|recovering|recalibrating|maintaining|rebuilding|replacing|capacity|affordance|resource|backup|checkpoint|record|evidence|belief|schedule|future|damage|fault|hazard|injury|illness/i
checks.add("collision-free invariants", "invariants exclude restoration processes, capacities, resources, records, observer states, schedules, and adverse-domain facts",
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
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["REP"]).to_set &&
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
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "restoration_condition_entities" &&
               record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)

checks.add("coverage routing", "at least 75 unique English concepts use varied non-forced routes",
           stress.length >= 75 && stress.map { |test| test.fetch("english_concept") }.uniq.length == stress.length &&
             stress.map { |test| test.fetch("routing") }.uniq.length >= 10 &&
             stress.all? { |test| test.fetch("analysis").length >= 30 })

packet_paths = Dir[File.join(ROOT, "reviews/REP_000_022_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
_stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools/build_rep_000_022_review.rb"), chdir: ROOT)
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "the REP packet builder is idempotent in #{mode} mode", status.success? && before == after)

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
  title: "REP:000–022 Restoration-Condition Entity-Layer Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL REPAIR ENTITY LAYER SOUND" : "PASS — READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**",
    "Roots audited: **9**",
    "Semantic architecture: **internal / target / shared restoration conditions**",
    "Generated-form assertions: **72**",
    "Runtime interpretations: **27**",
    "Stress tests: **#{stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`REP:000–002` identifies one acceptable restoration condition internal to an entity. `REP:010–012` identifies the restoration condition of one distinct target. `REP:020–022` identifies one correlated restoration condition across multiple system participants. The persistent member preserves identity and may co-occur with its manifest or dormant sibling; manifest and dormant are exclusive at one reference time. No root entails domain-specific health or integrity, absence of fault, a record or rule, restoration activity, recoverability, resources, scheduling, or causation.\n\n"
report << "**#{checks.success? ? 'REPAIR ENTITY-LAYER SOUNDNESS CONTRACT SATISFIED' : 'REPAIR ENTITY-LAYER SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/REP_000_022_soundness_audit.md", report)

puts "REP:000–022 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
