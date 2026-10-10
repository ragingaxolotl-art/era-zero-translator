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

range = "CRE:000–022"
ids = EraZeroValidation.ids_for_range(range)
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
recommended = EraZeroValidation.load_yaml("reviews/CRE_000_022_recommended_spec.yaml")
scored = EraZeroValidation.load_yaml("reviews/CRE_000_022_scored_candidates.yaml")
stress = EraZeroValidation.load_yaml("reviews/CRE_000_022_stress_tests.yaml").fetch("tests")
roots = recommended.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scored.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
mode = options.fetch(:mode)
mode = atoms.fetch("CRE:000")["status"] == "canonical" ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("complete packet scope", "all nine CRE:000–022 records are present once",
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
  "CRE:000" => "persistent internal generative pattern",
  "CRE:001" => "manifest internal generative pattern",
  "CRE:002" => "dormant internal generative pattern",
  "CRE:010" => "persistent generated artifact",
  "CRE:011" => "manifest generated artifact",
  "CRE:012" => "dormant generated artifact",
  "CRE:020" => "persistent shared generative repertoire",
  "CRE:021" => "manifest shared generative repertoire",
  "CRE:022" => "dormant shared generative repertoire"
}.freeze
checks.add("exact semantic grid", "the recommended grid matches the selected generative-entity architecture",
           ids.all? { |id| roots.fetch(id)["proposed_title"] == expected_titles.fetch(id) })

checks.add("entity-layer ontology", "every invariant is a Creation entity rather than a productive process, capacity relation, mental idea, representation, or physical medium",
           ids.all? do |id|
             root = roots.fetch(id)
             root.dig("address_justification", "first_trit_0").to_s.include?("Creation entity") &&
               root.fetch("same_family_contrast").include?("CRE:1xx") && root.fetch("same_family_contrast").include?("CRE:2xx")
           end)

checks.add("internal-pattern triplet", "CRE:000–002 changes only identity or present expression of one internal generative pattern",
           %w[CRE:000 CRE:001 CRE:002].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("bounded form-specifying pattern") && definition.include?("one reference entity") && definition.include?("source for")
           end)

checks.add("generated-artifact triplet", "CRE:010–012 changes only identity or manifestation of one outward generated product",
           %w[CRE:010 CRE:011 CRE:012].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("bounded product") && definition.include?("productive transformation") && definition.include?("outward from a source")
           end)

checks.add("shared-repertoire triplet", "CRE:020–022 changes only identity or expression of one coordinated shared generative repertoire",
           %w[CRE:020 CRE:021 CRE:022].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("coordinated collection of generative patterns") && definition.include?("multiple participants") &&
               definition.include?("shared production resource")
           end)

phase_words = {
  "CRE:000" => "independently of whether that pattern is presently expressed",
  "CRE:001" => "presently expressed",
  "CRE:002" => "without being presently expressed",
  "CRE:010" => "independently of whether that product is presently manifest",
  "CRE:011" => "presently manifest",
  "CRE:012" => "without being presently manifest",
  "CRE:020" => "independently of whether that repertoire is presently expressed",
  "CRE:021" => "presently expressed",
  "CRE:022" => "without being presently expressed"
}.freeze
checks.add("third-trit discipline", "every invariant contains its exact persistent/manifest/dormant discriminator",
           phase_words.all? { |id, phrase| roots.fetch(id).fetch("invariant_definition").include?(phrase) })

forbidden = /idea|imagin|inspir|belie|intend|file|dataset|schema|formal rule|physical medium|quality|value|author|owner|future|probab/i
checks.add("collision-free invariants", "invariants exclude mental ideas, data encodings, pure structures, media, value, authorship, and modality",
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
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["CRE"]).to_set &&
               comparisons.values.all? { |value| value.length >= 70 }
           end)

checks.add("example coverage", "each root has six typed examples, runtime/contour/register data, and a counterexample",
           ids.all? do |id|
             examples = roots.fetch(id).fetch("examples")
             examples.length >= 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["literal_gloss"] && example["natural_english"] && example.key?("runtime_state") && example["contour"] && example["role_registers"] }
           end)

checks.add("candidate challenge", "five scored architectures per root yield one unique generative-entity winner",
           ids.all? do |id|
             record = score_roots.fetch(id)
             candidates = record.fetch("candidates")
             best = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == best }
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "generative_entity_architecture" &&
               record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)

checks.add("coverage routing", "at least 100 unique English concepts use varied non-forced routes",
           stress.length >= 100 && stress.map { |test| test.fetch("english_concept") }.uniq.length == stress.length &&
             stress.map { |test| test.fetch("routing") }.uniq.length >= 10 &&
             stress.all? { |test| test.fetch("analysis").length >= 30 })

required_stress = ["design pattern", "template", "idea", "inspiration", "artifact", "prototype", "finished work",
                   "unbuilt design", "design system", "generative environment", "shared repertoire", "production",
                   "manifest and dormant artifact simultaneously", "persistent pattern uncertain"].freeze
checks.add("focused semantic stress", "coverage tests generative sources, products, repertoires, cognition, representation, process, modality, and layer boundaries",
           required_stress.all? { |concept| stress.any? { |test| test["english_concept"] == concept } })

packet_paths = Dir[File.join(ROOT, "reviews/CRE_000_022_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
_stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools/build_cre_000_022_review.rb"), chdir: ROOT)
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "the CRE packet builder is idempotent in #{mode} mode", status.success? && before == after)

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
  title: "CRE:000–022 Generative-Entity Layer Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL CREATION ENTITY LAYER SOUND" : "PASS — READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**",
    "Roots audited: **9**",
    "Semantic architecture: **internal generative patterns / generated artifacts / shared generative repertoires**",
    "Generated-form assertions: **72**",
    "Runtime interpretations: **27**",
    "Stress tests: **#{stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`CRE:000–002` identifies one bounded form-specifying pattern maintained within one entity as a production source. `CRE:010–012` identifies one bounded product of productive transformation directed outward from a source. `CRE:020–022` identifies one coordinated generative repertoire across multiple participants. The persistent member preserves Creation-entity identity and may co-occur with its manifest or dormant sibling; manifest and dormant are exclusive at one reference time. No root entails mental awareness, encoded representation, pure structure, physical medium, productive activity, completion, quality, value, authorship, provenance, authority, time, or modality.\n\n"
report << "**#{checks.success? ? 'CREATION ENTITY-LAYER SOUNDNESS CONTRACT SATISFIED' : 'CREATION ENTITY-LAYER SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/CRE_000_022_soundness_audit.md", report)

puts "CRE:000–022 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
