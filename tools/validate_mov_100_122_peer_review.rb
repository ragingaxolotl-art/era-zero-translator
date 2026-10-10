#!/usr/bin/env ruby

require "yaml"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
EXPECTED_IDS = %w[
  MOV:100 MOV:101 MOV:102
  MOV:110 MOV:111 MOV:112
  MOV:120 MOV:121 MOV:122
].freeze
SCORE_CATEGORIES = %w[
  atomicity
  address_fit
  family_fit
  neighbor_separation
  cross_family_separation
  compound_usefulness
  everyday_language_coverage
  technical_coverage
].freeze
SPEC_FIELDS = %w[
  canonical_title
  invariant_definition
  semantic_boundaries
  excluded_meanings
  nearest_neighbors
  cross_family_comparisons
  address_explanation
  runtime_states
  natural_language_examples
  programming_examples
  future_compound_examples
  era_evolution_notes
].freeze
CROSS_FAMILIES = %w[MAT MIN CON STR DAT CRE ORI].freeze

checks = []

def check(checks, label, condition, detail = nil)
  checks << {
    "label" => label,
    "passed" => !!condition,
    "detail" => detail
  }
end

paths = {
  "peer_review_markdown" => File.join(ROOT, "reviews/MOV_100_122_peer_review.md"),
  "scored_candidates" => File.join(ROOT, "reviews/MOV_100_122_scored_candidates.yaml"),
  "recommended_spec" => File.join(ROOT, "reviews/MOV_100_122_recommended_spec.yaml"),
  "stress_tests" => File.join(ROOT, "reviews/MOV_100_122_peer_stress_tests.yaml")
}

paths.each do |name, path|
  check(checks, "#{name} exists", File.file?(path), path)
end

candidates_doc = YAML.load_file(paths.fetch("scored_candidates"))
spec_doc = YAML.load_file(paths.fetch("recommended_spec"))
stress_doc = YAML.load_file(paths.fetch("stress_tests"))
atoms_doc = YAML.load_file(File.join(ROOT, "lexicon/atoms.yaml"))

candidate_roots = candidates_doc.fetch("roots")
spec_roots = spec_doc.fetch("roots")
ownership_rows = stress_doc.fetch("ownership_matrix")
stress_tests = stress_doc.fetch("english_motion_stress_tests")
atom_by_id = atoms_doc.fetch("atoms").to_h { |atom| [atom.fetch("canonical_id"), atom] }

check(
  checks,
  "candidate scope is exactly MOV:100–122 block",
  candidate_roots.map { |root| root.fetch("canonical_id") } == EXPECTED_IDS
)
check(
  checks,
  "recommended-spec scope is exactly MOV:100–122 block",
  spec_roots.map { |root| root.fetch("canonical_id") } == EXPECTED_IDS
)
check(
  checks,
  "ownership matrix has exactly nine scoped roots",
  ownership_rows.map { |row| row.fetch("root") } == EXPECTED_IDS
)

candidate_roots.each do |root|
  id = root.fetch("canonical_id")
  candidates = root.fetch("candidates")
  current = candidates.select { |candidate| candidate.fetch("is_current_phase2_candidate") }
  alternatives = candidates.reject { |candidate| candidate.fetch("is_current_phase2_candidate") }
  winners = candidates.select { |candidate| candidate.fetch("recommended_winner") }

  check(checks, "#{id} has one identified current Phase 2 candidate", current.length == 1)
  check(checks, "#{id} has at least three alternatives", alternatives.length >= 3, "#{alternatives.length} alternatives")
  check(checks, "#{id} has exactly one recommended winner", winners.length == 1)
  check(
    checks,
    "#{id} winner pointer is consistent",
    winners.first&.fetch("candidate_id") == root.fetch("recommendation").fetch("winner_candidate_id")
  )

  candidates.each do |candidate|
    candidate_id = candidate.fetch("candidate_id")
    scores = candidate.fetch("scores")
    check(
      checks,
      "#{id}/#{candidate_id} has exactly eight required score categories",
      scores.keys.sort == SCORE_CATEGORIES.sort
    )
    check(
      checks,
      "#{id}/#{candidate_id} scores are integers from 1 to 10",
      scores.values.all? { |value| value.is_a?(Integer) && value.between?(1, 10) }
    )
    check(
      checks,
      "#{id}/#{candidate_id} total score is arithmetically correct",
      candidate.fetch("total_score") == scores.values.sum
    )
  end

  atom = atom_by_id.fetch(id)
  fixed = root.fetch("fixed_generated_fields")
  expected_fixed = {
    "canonical_id" => atom.fetch("canonical_id"),
    "universal_slot" => atom.fetch("universal_slot"),
    "family_qualified_transliteration" => atom.fetch("canonical_transliteration"),
    "local_compact_root" => atom.fetch("local_compact_root"),
    "formal_carrier" => atom.fetch("formal_carrier"),
    "harmonic_signature_semitones" => atom.fetch("harmonic_signature_semitones"),
    "relative_note_path_semitones" => atom.fetch("note_path_semitones")
  }
  check(checks, "#{id} fixed generated fields match lexicon/atoms.yaml", fixed == expected_fixed)
  check(
    checks,
    "#{id} current title matches the Phase 2 lexicon candidate",
    current.first.fetch("title") == atom.fetch("title")
  )
  check(
    checks,
    "#{id} current definition matches the Phase 2 lexicon candidate",
    current.first.fetch("invariant_candidate") == atom.fetch("core_definition")
  )
end

spec_roots.each do |root|
  id = root.fetch("canonical_id")
  spec = root.fetch("recommended_permanent_specification")
  fixed = root.fetch("fixed_generated_fields")
  candidate_fixed = candidate_roots.find { |entry| entry.fetch("canonical_id") == id }
                                  .fetch("fixed_generated_fields")

  check(checks, "#{id} recommended specification has every requested field", (SPEC_FIELDS - spec.keys).empty?)
  check(checks, "#{id} repeats fixed fields without drift", fixed == candidate_fixed)
  check(checks, "#{id} has singular nonempty invariant definition", spec.fetch("invariant_definition").is_a?(String) && !spec.fetch("invariant_definition").strip.empty?)
  check(checks, "#{id} supplies all seven cross-family comparisons", spec.fetch("cross_family_comparisons").keys.sort == CROSS_FAMILIES.sort)
  check(checks, "#{id} supplies tailored runtime states 0/1/2", spec.fetch("runtime_states").keys.sort == %w[0 1 2])
  check(checks, "#{id} has at least three natural-language examples", spec.fetch("natural_language_examples").length >= 3)
  check(checks, "#{id} has at least two programming examples", spec.fetch("programming_examples").length >= 2)
  check(checks, "#{id} has at least three future-compound reservation sketches", spec.fetch("future_compound_examples").length >= 3)
end

check(checks, "stress test contains at least 25 English Motion concepts", stress_tests.length >= 25, "#{stress_tests.length} concepts")
check(
  checks,
  "stress-test concepts are unique",
  stress_tests.map { |test| test.fetch("english_concept") }.uniq.length == stress_tests.length
)
required_stress_concepts = [
  "leave", "depart", "go", "approach", "arrive", "follow a route",
  "wait", "pause", "stop", "continue", "cross", "return", "redirect",
  "move together", "circulate", "repeat a route", "schedule", "delay",
  "transition", "transport"
]
stress_names = stress_tests.map { |test| test.fetch("english_concept") }
check(
  checks,
  "stress test includes all required baseline concepts",
  (required_stress_concepts - stress_names).empty?,
  "missing: #{(required_stress_concepts - stress_names).join(", ")}"
)

check(
  checks,
  "candidate packet remains explicitly noncanonical",
  candidates_doc.fetch("metadata").fetch("canonicalized") == false
)
check(
  checks,
  "recommended specification remains explicitly noncanonical",
  spec_doc.fetch("metadata").fetch("canonicalized") == false &&
    spec_doc.fetch("authority").fetch("explicit_user_approval_required") == true
)
check(
  checks,
  "stress-test packet remains explicitly noncanonical",
  stress_doc.fetch("metadata").fetch("canonicalized") == false
)

status_counts = atoms_doc.fetch("atoms").each_with_object(Hash.new(0)) do |atom, counts|
  counts[atom.fetch("status")] += 1
end
check(
  checks,
  "lexicon authority counts remain 36 canonical and 288 provisional-pending-review",
  status_counts == {
    "canonical" => 36,
    "provisional_pending_detailed_semantic_review" => 288
  },
  status_counts.inspect
)
check(
  checks,
  "all nine reviewed Phase 2 roots remain provisional in the lexicon",
  EXPECTED_IDS.all? do |id|
    atom_by_id.fetch(id).fetch("status") == "provisional_pending_detailed_semantic_review"
  end
)

markdown = File.read(paths.fetch("peer_review_markdown"))
EXPECTED_IDS.each do |id|
  check(checks, "Markdown contains #{id} review", markdown.include?("## #{id} — peer review"))
end
check(checks, "Markdown contains ownership comparison matrix", markdown.include?("## Block comparison matrix"))
check(checks, "Markdown contains English Motion stress test", markdown.include?("## English Motion stress test"))
check(checks, "Markdown states no other block was reviewed", markdown.include?("**Other blocks reviewed:** none."))
check(checks, "Markdown states no compounds were canonized", markdown.include?("**Compounds canonized:** none."))
check(checks, "Markdown states Gate 4 was not begun", markdown.include?("**Gate 4 begun:** no."))

failed = checks.reject { |entry| entry.fetch("passed") }
report_path = File.join(ROOT, "reports/MOV_100_122_peer_review_validation.md")
FileUtils.mkdir_p(File.dirname(report_path))

report = []
report << "# MOV:100–122 Peer-Review Validation"
report << ""
report << "Result: **#{failed.empty? ? "PASS" : "FAIL"}**"
report << ""
report << "- Checks: #{checks.length}"
report << "- Passed: #{checks.length - failed.length}"
report << "- Failed: #{failed.length}"
report << "- Candidate meanings compared: #{candidate_roots.sum { |root| root.fetch("candidates").length }}"
report << "- English Motion concepts stress-tested: #{stress_tests.length}"
report << "- Scope: MOV:100–122 only"
report << "- Canonicalization performed: no"
report << ""
report << "## Checks"
report << ""
checks.each do |entry|
  mark = entry.fetch("passed") ? "PASS" : "FAIL"
  detail = entry["detail"]
  report << "- **#{mark}:** #{entry.fetch("label")}#{detail.nil? || detail.empty? ? "" : " — #{detail}"}"
end
report << ""
report << "## Authority conclusion"
report << ""
report << "The review packet proposes semantic winners but does not change canonical status. The 36 source-developed roots remain canonical, the 288 Phase 2 roots remain provisional, and all nine MOV:100–122 meanings still require explicit user approval."
report << ""

File.write(report_path, report.join("\n"))

puts "MOV:100–122 peer-review validation: #{failed.empty? ? "PASS" : "FAIL"}"
puts "Checks: #{checks.length}; failed: #{failed.length}"
puts "Report: #{report_path}"

unless failed.empty?
  failed.each { |entry| warn "FAIL: #{entry.fetch("label")} — #{entry["detail"]}" }
  exit 1
end
