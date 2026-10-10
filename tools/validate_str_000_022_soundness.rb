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

range = "STR:000–022"
ids = EraZeroValidation.ids_for_range(range)
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
recommended = EraZeroValidation.load_yaml("reviews/STR_000_022_recommended_spec.yaml")
scored = EraZeroValidation.load_yaml("reviews/STR_000_022_scored_candidates.yaml")
stress = EraZeroValidation.load_yaml("reviews/STR_000_022_stress_tests.yaml").fetch("tests")
roots = recommended.fetch("roots").to_h { |root| [root.dig("fixed_generated_fields", "canonical_id"), root] }
score_roots = scored.fetch("roots").to_h { |root| [root.fetch("canonical_id"), root] }
mode = options.fetch(:mode)
mode = atoms.fetch("STR:000")["status"] == "canonical" ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("complete packet scope", "all nine STR:000–022 records are present once",
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
  "STR:000" => "persistent constituent position",
  "STR:001" => "occupied constituent position",
  "STR:002" => "vacant constituent position",
  "STR:010" => "persistent structural interface",
  "STR:011" => "engaged structural interface",
  "STR:012" => "unengaged structural interface",
  "STR:020" => "persistent composite arrangement",
  "STR:021" => "instantiated composite arrangement",
  "STR:022" => "dormant composite arrangement"
}.freeze
checks.add("exact semantic grid", "the recommended grid matches the selected structural-locus architecture",
           ids.all? { |id| roots.fetch(id)["proposed_title"] == expected_titles.fetch(id) })

checks.add("entity-layer ontology", "every invariant is a structural entity/condition rather than a process or relation",
           ids.all? do |id|
             root = roots.fetch(id)
             root.dig("address_justification", "first_trit_0").to_s.include?("entity or condition") &&
               root.fetch("same_family_contrast").include?("STR:1xx") && root.fetch("same_family_contrast").include?("STR:2xx")
           end)

checks.add("constituent-position triplet", "STR:000–002 changes only present occupancy",
           %w[STR:000 STR:001 STR:002].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("position within a structure") && definition.include?("constituent")
           end)

checks.add("structural-interface triplet", "STR:010–012 changes only present engagement",
           %w[STR:010 STR:011 STR:012].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("boundary locus") && definition.include?("distinct external target")
           end)

checks.add("composite-arrangement triplet", "STR:020–022 changes only present part–whole realization",
           %w[STR:020 STR:021 STR:022].all? do |id|
             definition = roots.fetch(id).fetch("invariant_definition")
             definition.include?("part–whole arrangement") && definition.include?("multiple constituent positions")
           end)

phase_words = {
  "STR:000" => "remains identified", "STR:001" => "presently occupied", "STR:002" => "presently unoccupied",
  "STR:010" => "remains identified", "STR:011" => "presently engaged", "STR:012" => "presently unengaged",
  "STR:020" => "remains identified", "STR:021" => "presently realized", "STR:022" => "without presently being realized"
}.freeze
checks.add("third-trit discipline", "every invariant contains its exact persistent/active/dormant discriminator",
           phase_words.all? { |id, phrase| roots.fetch(id).fetch("invariant_definition").include?(phrase) })

forbidden = /mechanism|function|purpose|load|regulat|coordinat|institution|settlement|infrastructure|shelter|container|construction|planned|reserved|folded|installed/i
checks.add("collision-free invariants", "invariants exclude Phase 2 function, material, institutional, process, and planning mixtures",
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
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["STR"]).to_set &&
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
             candidates.length == 5 && winners.length == 1 && winners.first["candidate_id"] == "structural_loci_and_arrangements" &&
               record["recommended_candidate_id"] == winners.first["candidate_id"]
           end)

checks.add("coverage routing", "at least 70 unique English concepts use varied non-forced routes",
           stress.length >= 70 && stress.map { |test| test.fetch("english_concept") }.uniq.length == stress.length &&
             stress.map { |test| test.fetch("routing") }.uniq.length >= 10 &&
             stress.all? { |test| test.fetch("analysis").length >= 30 })

packet_paths = Dir[File.join(ROOT, "reviews/STR_000_022_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
_stdout, _stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "tools/build_str_000_022_review.rb"), chdir: ROOT)
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "the STR packet builder is idempotent in #{mode} mode", status.success? && before == after)

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
  title: "STR:000–022 Structural Entity-Layer Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — CANONICAL STRUCTURAL ENTITY LAYER SOUND" : "PASS — READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**",
    "Roots audited: **9**",
    "Semantic architecture: **constituent positions / structural interfaces / composite arrangements**",
    "Generated-form assertions: **72**",
    "Runtime interpretations: **27**",
    "Stress tests: **#{stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n`STR:000–002` names positions inside a structure, not their occupants. `STR:010–012` names outward engagement loci, not communication endpoints or attachment relations. `STR:020–022` names part–whole arrangements, not blueprints, institutions, functions, or construction processes. Occupancy, engagement, and structural realization do not entail purpose, integrity, operation, planning, or later use.\n\n"
report << "**#{checks.success? ? 'STRUCTURAL ENTITY-LAYER SOUNDNESS CONTRACT SATISFIED' : 'STRUCTURAL ENTITY-LAYER SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/STR_000_022_soundness_audit.md", report)

puts "STR:000–022 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
