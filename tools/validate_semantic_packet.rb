#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require_relative "lib/era_zero_validation"

include EraZeroValidation

options = { mode: "auto", report: nil }
parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby tools/validate_semantic_packet.rb FAMILY:000-022 [options]"
  opts.on("--mode MODE", %w[auto review canonical], "auto, review, or canonical") do |mode|
    options[:mode] = mode
  end
  opts.on("--report PATH", "write the Markdown result under the project root") do |path|
    options[:report] = path
  end
end
parser.parse!

abort(parser.to_s) unless ARGV.length == 1

begin
  range = EraZeroValidation.normalized_range(ARGV.first)
  ids = EraZeroValidation.ids_for_range(range)
rescue ArgumentError => error
  abort("#{error.message}\n\n#{parser}")
end

stem = EraZeroValidation.stem_for_range(range)
paths = {
  scored: "reviews/#{stem}_scored_candidates.yaml",
  recommended: "reviews/#{stem}_recommended_spec.yaml",
  stress: "reviews/#{stem}_stress_tests.yaml",
  review: "reviews/#{stem}_peer_review.md",
  collision: "reviews/#{stem}_collision_report.md"
}

missing = paths.values.reject { |path| File.file?(File.join(ROOT, path)) }
unless missing.empty?
  warn "Missing packet files:"
  missing.each { |path| warn "- #{path}" }
  exit 1
end

atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
target = ids.map { |id| atoms.fetch(id) }
statuses = target.map { |atom| atom.fetch("status") }.uniq

mode = options[:mode]
if mode == "auto"
  mode = if statuses == ["canonical"]
           "canonical"
         elsif statuses == ["provisional_pending_detailed_semantic_review"]
           "review"
         else
           "mixed"
         end
end

scored = EraZeroValidation.load_yaml(paths.fetch(:scored))
recommended = EraZeroValidation.load_yaml(paths.fetch(:recommended))
stress = EraZeroValidation.load_yaml(paths.fetch(:stress))
scored_roots = scored.fetch("roots")
recommended_roots = recommended.fetch("roots")
stress_tests = stress.fetch("tests")

root_id = lambda do |root|
  root["canonical_id"] || root.dig("fixed_generated_fields", "canonical_id")
end

fixed_fields = lambda do |root|
  root["fixed_generated_fields"] ||
    root.dig("recommended_permanent_specification", "fixed_generated_fields")
end

title = lambda do |root|
  root["proposed_title"] || root["recommended_title"] ||
    root.dig("recommended_permanent_specification", "title") ||
    root.dig("recommended_permanent_specification", "canonical_title")
end

definition = lambda do |root|
  root["invariant_definition"] ||
    root.dig("recommended_permanent_specification", "invariant_definition")
end

examples = lambda do |root|
  direct = root["examples"]
  next direct if direct.is_a?(Array)

  [root["ordinary_language_examples"], root["technical_programming_examples"]]
    .compact.flatten
end

runtime = lambda do |root|
  root["runtime_state_interpretation"] || root["runtime_state_interpretations"] || {}
end

address_explanation = lambda do |root|
  root["address_justification"] || root["address_explanation"] || {}
end

boundaries = lambda do |root|
  root["inclusion_boundary"] || root["semantic_boundaries"] || ""
end

checks = EraZeroValidation::CheckSet.new

yaml_files = Dir[File.join(ROOT, "{lexicon,spec,reviews,migrations,extraction}/**/*.{yaml,yml}")]
syntax_errors = yaml_files.map do |path|
  begin
    YAML.load_file(path)
    nil
  rescue StandardError => error
    "#{path.delete_prefix("#{ROOT}/")}: #{error.message}"
  end
end.compact
checks.add("machine-readable syntax", "all #{yaml_files.length} project YAML files parse", syntax_errors.empty?)

checks.add("packet scope", "both semantic records contain exactly #{range}",
           scored_roots.map { |root| root["canonical_id"] } == ids &&
             recommended_roots.map { |root| root_id.call(root) } == ids)

checks.add("authority mode", "#{range} has a uniform #{mode} authority state",
           %w[review canonical].include?(mode) && statuses.length == 1 &&
             (mode == "canonical" ? statuses.first == "canonical" :
               statuses.first == "provisional_pending_detailed_semantic_review"))

candidate_count = scored_roots.sum { |root| root.fetch("candidates").length }
score_count = scored_roots.sum do |root|
  root.fetch("candidates").sum { |candidate| candidate.fetch("scores").length }
end

checks.add("candidate breadth", "each root has at least four genuinely distinct semantic candidates",
           scored_roots.all? do |root|
             candidates = root.fetch("candidates")
             candidates.length >= 4 &&
               candidates.map { |candidate| candidate.fetch("candidate_id") }.uniq.length == candidates.length &&
               candidates.map { |candidate| candidate.fetch("title") }.uniq.length == candidates.length &&
               candidates.all? { |candidate| candidate.fetch("analysis").is_a?(Hash) && candidate.fetch("analysis").length >= 3 }
           end)

checks.add("candidate scoring", "all candidates have complete 1–10 scores and correct totals",
           scored_roots.all? do |root|
             root.fetch("candidates").all? do |candidate|
               scores = candidate.fetch("scores")
               scores.length >= 8 &&
                 scores.values.all? { |value| value.is_a?(Integer) && value.between?(1, 10) } &&
                 candidate.fetch("total") == scores.values.sum &&
                 candidate.fetch("maximum") == scores.length * 10
             end
           end)

checks.add("winner selection", "each recommendation is a unique highest-scoring candidate",
           scored_roots.all? do |root|
             candidates = root.fetch("candidates")
             maximum = candidates.map { |candidate| candidate.fetch("total") }.max
             winners = candidates.select { |candidate| candidate.fetch("total") == maximum }
             winners.length == 1 && root.fetch("recommended_candidate_id") == winners.first.fetch("candidate_id")
           end)

checks.add("fixed generated fields", "all packet fields match the immutable address algorithms",
           ids.all? do |id|
             atom = atoms.fetch(id)
             scored_root = scored_roots.find { |root| root.fetch("canonical_id") == id }
             spec_root = recommended_roots.find { |root| root_id.call(root) == id }
             scored_root.fetch("fixed_generated_fields") == EraZeroValidation.packet_fixed_projection(atom) &&
               fixed_fields.call(spec_root) == EraZeroValidation.packet_fixed_projection(atom)
           end)

checks.add("invariant specifications", "all roots have one nonempty title and invariant definition",
           recommended_roots.all? do |root|
             !title.call(root).to_s.strip.empty? && !definition.call(root).to_s.strip.empty? &&
               definition.call(root).to_s.strip.end_with?(".")
           end)

checks.add("address justification", "every root separately explains all three lexical axes",
           recommended_roots.all? do |root|
             explanation = address_explanation.call(root)
             explanation.is_a?(Hash) && explanation.length >= 3 &&
               explanation.values.all? { |value| value.to_s.length >= 25 }
           end)

checks.add("semantic boundaries", "every root has inclusion boundaries, exclusions, and neighbors",
           recommended_roots.all? do |root|
             boundary = boundaries.call(root)
             exclusions = root["excluded_meanings"] || []
             neighbors = root["nearest_neighbors"] || root["nearest_motion_contrasts"] ||
               root["nearest_mat_contrasts"] || []
             boundary.to_s.length >= 80 && exclusions.length >= 3 && neighbors.length >= 2
           end)

checks.add("cross-family collision audit", "every root distinguishes all eleven competing families",
           recommended_roots.all? do |root|
             comparisons = root.fetch("cross_family_comparisons")
             comparisons.is_a?(Hash) && comparisons.keys.to_set == (FAMILIES.keys - [range[0, 3]]).to_set &&
               comparisons.values.all? { |value| value.to_s.length >= 30 }
           end)

checks.add("runtime-state interpretation", "every root tailors [0], [1], and [2]/num",
           recommended_roots.all? do |root|
             states = runtime.call(root)
             keys = states.keys.map(&:to_s).to_set
             (%w[0 1].to_set - keys).empty? &&
               (keys.include?("2/num") || keys.include?("2")) &&
               states.values.all? { |value| value.to_s.length >= 20 }
           end)

checks.add("example coverage", "every root has at least six ordinary, technical, compound, or counterexamples",
           recommended_roots.all? do |root|
             root_examples = examples.call(root)
             root_examples.is_a?(Array) && root_examples.length >= 6
           end)

route_names = stress_tests.map { |test| test["routing"].to_s }.to_set
non_atomic_route = route_names.any? do |route|
  route.match?(/compound|grammar|family|gap|unresolved|contour|runtime/)
end
checks.add("coverage stress tests", "at least 25 unique concepts include non-atomic routing",
           stress_tests.length >= 25 &&
             stress_tests.map { |test| test.fetch("english_concept") }.uniq.length == stress_tests.length &&
             stress_tests.all? { |test| !test.fetch("analysis").to_s.strip.empty? } &&
             route_names.length >= 3 && non_atomic_route)

review_text = File.read(File.join(ROOT, paths.fetch(:review)), encoding: "UTF-8")
collision_text = File.read(File.join(ROOT, paths.fetch(:collision)), encoding: "UTF-8")
checks.add("human-readable evidence", "peer review and collision report cover all nine roots",
           ids.all? { |id| review_text.include?(id) && collision_text.include?(id) })

if mode == "review"
  checks.add("pre-approval boundary", "the validator does not canonize provisional roots",
             recommended_roots.none? { |root| root["canonicalized"] == true } &&
               recommended.dig("metadata", "roots_canonicalized").to_a.empty?)
else
  promotions = EraZeroValidation.effective_promotions.to_h do |path, promotion|
    [promotion.fetch("canonical_id"), [path, promotion]]
  end
  checks.add("canonical meanings", "approved titles and definitions match the authoritative lexicon",
             recommended_roots.all? do |root|
               id = root_id.call(root)
               atom = atoms.fetch(id)
               atom.fetch("title") == title.call(root) &&
                 atom.fetch("core_definition") == definition.call(root)
             end)
  checks.add("approval migration", "all nine roots have effective, exact promotion records",
             ids.all? do |id|
               _path, promotion = promotions.fetch(id)
               atom = atoms.fetch(id)
               promotion.fetch("canonical_title") == atom.fetch("title") &&
                 promotion.fetch("invariant_definition") == atom.fetch("core_definition") &&
                 promotion.fetch("fixed_generated_fields") == EraZeroValidation.migration_fixed_projection(atom)
             end)
end

checks.add("downstream boundary", "the packet does not authorize Gate 4 or translator implementation",
           recommended.dig("metadata", "gate4_started") != true &&
             recommended.dig("metadata", "translator_started") != true)

report = checks.markdown(
  title: "#{range} Reusable Semantic-Packet Validation",
  pass_status: mode == "canonical" ? "PASS — CANONICAL PACKET VERIFIED" : "PASS — READY FOR APPROVAL",
  summary: [
    "Mode: **#{mode}**",
    "Roots: **#{ids.length}**",
    "Candidates: **#{candidate_count}**",
    "Score assertions: **#{score_count}**",
    "Stress tests: **#{stress_tests.length}**"
  ]
)
report << "\n**#{checks.success? ? "PACKET CONTRACT SATISFIED" : "PACKET CONTRACT FAILED"}**\n"

EraZeroValidation.write(options[:report], report) if options[:report]
puts "#{range}: #{checks.success? ? "PASS" : "FAIL"}"
puts "Mode: #{mode}; checks passed: #{checks.passed}; checks failed: #{checks.failed}"
puts "Candidates: #{candidate_count}; score assertions: #{score_count}; stress tests: #{stress_tests.length}"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
