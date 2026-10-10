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

range = "DAT:000–022"
ids = EraZeroValidation.ids_for_range(range)
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
recommended = EraZeroValidation.load_yaml("reviews/DAT_000_022_recommended_spec.yaml")
scored = EraZeroValidation.load_yaml("reviews/DAT_000_022_scored_candidates.yaml")
stress = EraZeroValidation.load_yaml("reviews/DAT_000_022_stress_tests.yaml").fetch("tests")
roots = recommended.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scored.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
mode = options.fetch(:mode)
mode = atoms.fetch("DAT:000")["status"] == "canonical" ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("complete packet scope", "all nine DAT:000–022 records are present once",
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
  "DAT:000" => "persistent internal datum",
  "DAT:001" => "manifest internal datum",
  "DAT:002" => "dormant internal datum",
  "DAT:010" => "persistent target reference",
  "DAT:011" => "manifest target reference",
  "DAT:012" => "dormant target reference",
  "DAT:020" => "persistent shared dataset",
  "DAT:021" => "manifest shared dataset",
  "DAT:022" => "dormant shared dataset"
}.freeze
checks.add("exact semantic grid", "the recommended grid matches the selected information-object architecture",
           ids.all? { |id| roots.fetch(id)["proposed_title"] == expected_titles.fetch(id) })

checks.add("entity-layer ontology", "every invariant is an information entity rather than a data process, access relation, or physical medium",
           ids.all? do |id|
             root = roots.fetch(id)
             root.dig("address_justification", "first_trit_0").to_s.include?("information entity") &&
               root.fetch("same_family_contrast").include?("DAT:1xx") && root.fetch("same_family_contrast").include?("DAT:2xx")
           end)

checks.add("internal-datum triplet", "DAT:000–002 changes only identity or present manifestation of one internal datum",
           %w[DAT:000 DAT:001 DAT:002].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("bounded information object") && definition.include?("one reference entity")
           end)

checks.add("target-reference triplet", "DAT:010–012 changes only identity or manifestation of one datum referring to one target",
           %w[DAT:010 DAT:011 DAT:012].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("bounded information object") && definition.include?("one distinct reference target") &&
               definition.match?(/denotes|reference/)
           end)

checks.add("shared-dataset triplet", "DAT:020–022 changes only identity or manifestation of one coordinated shared dataset",
           %w[DAT:020 DAT:021 DAT:022].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("coordinated collection of information objects") && definition.include?("multiple participants") &&
               definition.include?("one information domain") && definition.include?("shared dataset")
           end)

phase_words = {
  "DAT:000" => "independently of whether that information object is presently manifest",
  "DAT:001" => "presently manifest",
  "DAT:002" => "without being presently manifest",
  "DAT:010" => "independently of whether that referential content is presently manifest",
  "DAT:011" => "presently manifests",
  "DAT:012" => "without presently manifesting",
  "DAT:020" => "independently of whether that dataset is presently manifest",
  "DAT:021" => "presently manifest",
  "DAT:022" => "without being presently manifest"
}.freeze
checks.add("third-trit discipline", "every invariant contains its exact persistent/manifest/dormant discriminator",
           phase_words.all? { |id, phrase| roots.fetch(id).fetch("invariant_definition").include?(phrase) })

forbidden = /truth|false|valid|proof|belie|understand|access|observ|transmit|deliver|receive|process|mutat|copy|index|physical|medium|authority|schedule|future|possible|probab/i
checks.add("collision-free invariants", "invariants exclude truth, belief, access, observation, transmission, processing, media, authority, and modality",
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
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["DAT"]).to_set &&
               comparisons.values.all? { |value| value.length >= 70 }
           end)

checks.add("example coverage", "each root has six typed examples, runtime/contour/register data, and a counterexample",
           ids.all? do |id|
             examples = roots.fetch(id).fetch("examples")
             examples.length >= 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per root yield one unique information-object winner",
           ids.all? do |id|
             record = score_roots.fetch(id)
             candidates = record.fetch("candidates")
             best = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == best }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "information_object_entities" &&
               record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)

checks.add("coverage routing", "at least 100 unique English concepts use varied non-forced routes",
           stress.length >= 100 && stress.map { |test| test.fetch("english_concept") }.uniq.length == stress.length &&
             stress.map { |test| test.fetch("routing") }.uniq.length >= 10 &&
             stress.all? { |test| test.fetch("analysis").length >= 30 })

required_stress = ["datum", "record", "reference", "dataset", "message", "stream", "accessible", "known",
                   "deleted", "persistent internal datum", "manifest and dormant datum simultaneously",
                   "data entity versus medium", "data entity versus processing", "manifest datum uncertain"].freeze
checks.add("focused semantic stress", "coverage tests information identity, manifestation, reference, collection, process, access, modality, and layer boundaries",
           required_stress.all? { |concept| stress.any? { |test| test["english_concept"] == concept } })

packet_paths = Dir[File.join(ROOT, "reviews/DAT_000_022_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
_stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools/build_dat_000_022_review.rb"), chdir: ROOT)
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
  title: "DAT:000–022 Information-Entity Layer Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL DATA ENTITY LAYER SOUND" : "PASS — READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**",
    "Roots audited: **9**",
    "Semantic architecture: **internal data / target references / shared datasets**",
    "Generated-form assertions: **72**",
    "Runtime interpretations: **27**",
    "Stress tests: **#{stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`DAT:000–002` identifies one bounded information object maintained within one entity. `DAT:010–012` identifies one information object whose content denotes one distinct referent. `DAT:020–022` identifies one coordinated shared dataset across multiple participants in one information domain. The persistent member preserves information-object identity and may co-occur with its manifest or dormant sibling; manifest and dormant are exclusive at one reference time. No root entails physical medium, access, observation, belief, truth, transmission, delivery, processing, mutation, provenance, authority, time, or modality.\n\n"
report << "**#{checks.success? ? 'DATA ENTITY-LAYER SOUNDNESS CONTRACT SATISFIED' : 'DATA ENTITY-LAYER SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/DAT_000_022_soundness_audit.md", report)

puts "DAT:000–022 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
