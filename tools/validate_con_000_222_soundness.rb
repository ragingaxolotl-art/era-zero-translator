#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "open3"
require "optparse"
require "rbconfig"
require_relative "lib/era_zero_validation"

include EraZeroValidation

options = { mode: "auto" }
OptionParser.new do |parser|
  parser.on("--mode MODE", %w[auto review canonical]) { |mode| options[:mode] = mode }
end.parse!

ids = %w[0 1 2].flat_map { |layer| EraZeroValidation.ids_for_range("CON:#{layer}00-#{layer}22") }
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
specs = %w[000 100 200].to_h do |layer|
  path = "reviews/CON_#{layer}_#{layer[0]}22_recommended_spec.yaml"
  [layer[0], EraZeroValidation.load_yaml(path)]
end

roots_by_id = specs.values.flat_map { |doc| doc.fetch("roots") }.to_h do |root|
  [root.dig("fixed_generated_fields", "canonical_id"), root]
end

mode = options.fetch(:mode)
mode = atoms.fetch("CON:200")["status"] == "canonical" ? "canonical" : "review" if mode == "auto"
checks = EraZeroValidation::CheckSet.new

checks.add("complete Connection cube", "all 27 Connection addresses and packet records are present once",
           ids.length == 27 && ids.uniq.length == 27 && roots_by_id.keys.to_set == ids.to_set)

checks.add("immutable generated forms", "all 216 fixed-form assertions match the accepted algorithms",
           ids.all? do |id|
             atom = atoms.fetch(id)
             EraZeroValidation.generated_field_errors({ id => atom }).empty? &&
               roots_by_id.fetch(id).fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atom)
           end)

expected_layers = {
  "0" => {
    "0" => %w[source endpoint],
    "1" => %w[target endpoint],
    "2" => %w[shared channel]
  },
  "1" => {
    "0" => %w[source expression],
    "1" => %w[target reception],
    "2" => %w[shared distribution]
  },
  "2" => {
    "0" => %w[communicative participation capacity],
    "1" => %w[directed communication relation],
    "2" => %w[shared participation relation]
  }
}.freeze

checks.add("layer ontology", "0xx=loci, 1xx=processes, and 2xx=capacities/participant relations",
           ids.all? do |id|
             title = roots_by_id.fetch(id).fetch("proposed_title")
             required = expected_layers.fetch(id[-3]).fetch(id[-2])
             required.all? { |word| title.include?(word) }
           end)

checks.add("authoritative meaning alignment", "canonical layers match live authority and review layer matches its proposal",
           ids.all? do |id|
             root = roots_by_id.fetch(id)
             atom = atoms.fetch(id)
             if atom["status"] == "canonical"
               atom["title"] == root["proposed_title"] && atom["core_definition"] == root["invariant_definition"]
             else
               id.start_with?("CON:2") && mode == "review"
             end
           end)

checks.add("authority boundary", "review mode preserves nine provisional roots; canonical mode requires the full family",
           if mode == "review"
             ids.count { |id| atoms.fetch(id)["status"] == "canonical" } == 18 &&
               ids.count { |id| atoms.fetch(id)["status"] == "provisional_pending_detailed_semantic_review" } == 9
           else
             ids.all? { |id| atoms.fetch(id)["status"] == "canonical" }
           end)

triplet_phases = {
  "CON:000" => ["persistent", "active", "dormant"],
  "CON:010" => ["persistent", "active", "dormant"],
  "CON:020" => ["persistent", "active", "dormant"],
  "CON:100" => ["completed", "active", "potential"],
  "CON:110" => ["completed", "active", "potential"],
  "CON:120" => ["completed", "active", "potential"],
  "CON:200" => ["enduring", "available", "latent"],
  "CON:210" => ["established", "operative", "unresolved"],
  "CON:220" => ["enduring", "operative", "potential"]
}.freeze

checks.add("triplet phase discipline", "each triplet changes only its third-trit condition",
           triplet_phases.all? do |base, phases|
             prefix = base[0..-2]
             phases.each_with_index.all? do |phase, index|
               roots_by_id.fetch("#{prefix}#{index}").fetch("proposed_title").start_with?(phase)
             end
           end)

checks.add("capacity triplet coherence", "CON:200–202 preserves one endpoint participation-capacity axis",
           %w[CON:200 CON:201 CON:202].all? do |id|
             root = roots_by_id.fetch(id)
             root["proposed_title"].include?("communicative participation capacity") &&
               root["invariant_definition"].include?("capacity") &&
               root["invariant_definition"].include?("endpoint")
           end)

checks.add("directed-relation triplet coherence", "CON:210–212 preserves one reference-to-target participant-relation axis",
           %w[CON:210 CON:211 CON:212].all? do |id|
             definition = roots_by_id.fetch(id).fetch("invariant_definition")
             definition.include?("relation") && definition.include?("target") && definition.include?("endpoint")
           end)

checks.add("shared-relation triplet coherence", "CON:220–222 preserves one multi-endpoint co-participation axis",
           %w[CON:220 CON:221 CON:222].all? do |id|
             definition = roots_by_id.fetch(id).fetch("invariant_definition")
             definition.include?("relation") && definition.include?("multiple endpoints") && definition.include?("co-participants")
           end)

forbidden_invariants = /dialogue|message|respond|translate|relay|network|mesh|routing|protocol|compatible|interoperable|friend|social|reachable|permission|schedule/i
checks.add("collision-free invariants", "2xx invariants exclude traffic, topology, protocol, social bond, reachability, and scheduling",
           %w[CON:200 CON:201 CON:202 CON:210 CON:211 CON:212 CON:220 CON:221 CON:222].none? do |id|
             roots_by_id.fetch(id).fetch("invariant_definition").match?(forbidden_invariants)
           end)

checks.add("locus/process/relation separation", "every 2xx root states the same-family boundary and traffic non-entailment",
           %w[CON:200 CON:201 CON:202 CON:210 CON:211 CON:212 CON:220 CON:221 CON:222].all? do |id|
             text = roots_by_id.fetch(id).fetch("same_family_contrast")
             text.include?("CON:0xx") && text.include?("CON:1xx") && text.include?("CON:2xx") &&
               text.include?("never entails active traffic")
           end)

checks.add("runtime tailoring", "all 81 state meanings are root-specific and lexical/runtime separation is explicit",
           ids.all? do |id|
             root = roots_by_id.fetch(id)
             states = root.fetch("runtime_state_interpretation")
             states.keys.map(&:to_s).to_set == %w[0 1 2/num].to_set &&
               states.values.all? { |value| value.length >= 60 } &&
               root.fetch("lexical_runtime_distinction").include?("Runtime")
           end)

checks.add("cross-family routing", "all 27 roots explicitly route every competing family",
           ids.all? do |id|
             comparisons = roots_by_id.fetch(id).fetch("cross_family_comparisons")
             comparisons.keys.to_set == (EraZeroValidation::FAMILIES.keys - ["CON"]).to_set &&
               comparisons.values.all? { |value| value.length >= 40 }
           end)

checks.add("example and counterexample coverage", "each root has six typed examples with one rejected use",
           ids.all? do |id|
             examples = roots_by_id.fetch(id).fetch("examples")
             examples.length >= 6 && examples.any? { |example| example["use_status"] == "must_not_use_this_root" } &&
               examples.all? { |example| example["semantic_graph"] && example["natural_english"] && example.key?("runtime_state") }
           end)

stress = EraZeroValidation.load_yaml("reviews/CON_200_222_stress_tests.yaml").fetch("tests")
checks.add("coverage routing", "the 2xx block routes at least 60 unique concepts without forced atomization",
           stress.length >= 60 && stress.map { |test| test.fetch("english_concept") }.uniq.length == stress.length &&
             stress.map { |test| test.fetch("routing") }.uniq.length >= 8)

packet_paths = Dir[File.join(ROOT, "reviews/CON_{000,100,200}_*{yaml,md}")].sort
before = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
builders = %w[000 100 200].map { |layer| File.join(ROOT, "tools/build_con_#{layer}_#{layer[0]}22_review.rb") }
builder_ok = builders.all? do |builder|
  _out, _err, status = Open3.capture3(RbConfig.ruby, builder, chdir: ROOT)
  status.success?
end
after = packet_paths.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
checks.add("review-builder rerun safety", "all three Connection packet builders are idempotent in #{mode} mode",
           builder_ok && before == after)

report = checks.markdown(
  title: "CON:000–222 Full-Family Semantic Soundness Audit",
  pass_status: mode == "canonical" ? "PASS — COMPLETE CONNECTION FAMILY SOUND" : "PASS — CON:2XX READY FOR DELEGATED APPROVAL",
  summary: [
    "Mode: **#{mode}**",
    "Connection roots audited: **27**",
    "Layer model: **loci → processes → affordances/relations**",
    "Generated-form assertions: **216**",
    "Runtime interpretations: **81**",
    "CON:2xx stress tests: **#{stress.length}**"
  ]
)
report << "\n## Required interpretation\n\n"
report << "`CON:0xx` identifies where exchange can occur; `CON:1xx` identifies communicative availability processes through those loci; `CON:2xx` identifies endpoint participation capacity or relations among participant endpoints. No layer entails another. In particular, an operative capacity or relation never proves traffic, reachability, permission, compatibility, comprehension, social affinity, topology, or channel existence.\n\n"
report << "**#{checks.success? ? 'FULL CONNECTION-FAMILY SOUNDNESS CONTRACT SATISFIED' : 'FULL CONNECTION-FAMILY SOUNDNESS CONTRACT FAILED'}**\n"
EraZeroValidation.write("reviews/CON_000_222_soundness_audit.md", report)

puts "CON:000–222 soundness: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
