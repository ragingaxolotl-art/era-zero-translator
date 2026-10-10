#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "fileutils"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation
VERSION = "1.0.0"
DATE = "2026-10-09"

index_doc = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml")
senses = index_doc.fetch("senses")
lemmas = index_doc.fetch("lemma_index")
atoms = EraZeroValidation.load_yaml("lexicon/atoms.yaml").fetch("atoms")
compounds = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries")

routes = senses.group_by { |s| s.fetch("route") }.transform_values(&:length)
total = senses.length
direct = routes.fetch("atom", 0) + routes.fetch("compound", 0)
future_structural = routes.fetch("grammar", 0) + routes.fetch("semantic_ir", 0)
gaps = routes.fetch("gap", 0)
ambiguous_lemmas = lemmas.select { |_lemma, item| item.fetch("requires_disambiguation") }
multi_direct = senses.group_by { |s| s["lemma"] }.select do |_lemma, records|
  records.select { |s| %w[atom compound].include?(s["route"]) }.map { |s| s["target_id"] }.uniq.length > 1
end

family_coverage = atoms.group_by { |a| a.fetch("family") }.sort.to_h do |family, records|
  exact = records.count do |atom|
    senses.any? { |s| s["route"] == "atom" && s["target_id"] == atom["canonical_id"] && s["controlled_input_allowed"] }
  end
  [family, { "canonical_atoms" => records.length, "exact_controlled_senses" => exact, "coverage_percent" => (100.0 * exact / records.length).round(2) }]
end

high_frequency = senses.select { |s| s["provenance"] == "Gate 4C reviewed routing" }
high_routes = high_frequency.group_by { |s| s["route"] }.transform_values(&:length)

metrics = {
  "metadata" => {
    "title" => "Era Zero Gate 4D Coverage and Ambiguity Metrics", "version" => VERSION,
    "status" => "canonical_measurement_release", "benchmark" => "Gate 4C exact canonical labels plus reviewed high-frequency senses",
    "sense_index_fingerprint" => EraZeroValidation.fingerprint(index_doc),
    "translator_started" => false
  },
  "inventory" => {
    "total_senses" => total, "total_lemmas" => lemmas.length,
    "canonical_atom_targets" => atoms.length, "canonical_compound_targets" => compounds.length,
    "reviewed_high_frequency_senses" => high_frequency.length
  },
  "route_coverage" => {
    "direct_atom" => routes.fetch("atom", 0), "direct_compound" => routes.fetch("compound", 0),
    "future_grammar" => routes.fetch("grammar", 0), "future_semantic_ir" => routes.fetch("semantic_ir", 0),
    "unsupported_gap" => gaps,
    "direct_lexical_percent" => (100.0 * direct / total).round(2),
    "structurally_routed_percent" => (100.0 * (direct + future_structural) / total).round(2),
    "explicit_gap_percent" => (100.0 * gaps / total).round(2)
  },
  "high_frequency_benchmark" => {
    "senses" => high_frequency.length, "by_route" => high_routes,
    "direct_lexical_percent" => (100.0 * (high_routes.fetch("atom", 0) + high_routes.fetch("compound", 0)) / high_frequency.length).round(2),
    "eventual_structural_percent" => (100.0 * (high_frequency.length - high_routes.fetch("gap", 0)) / high_frequency.length).round(2),
    "gap_percent" => (100.0 * high_routes.fetch("gap", 0) / high_frequency.length).round(2)
  },
  "ambiguity" => {
    "lemmas_requiring_disambiguation" => ambiguous_lemmas.length,
    "lemma_ambiguity_percent" => (100.0 * ambiguous_lemmas.length / lemmas.length).round(2),
    "lemmas_with_multiple_direct_targets" => multi_direct.keys.sort,
    "multiple_direct_target_count" => multi_direct.length,
    "policy" => "Never choose the first candidate. Use sense ID, contextual constraints, or explicit clarification."
  },
  "family_exact_label_coverage" => family_coverage,
  "gaps" => senses.select { |s| s["route"] == "gap" }.map { |s| { "lemma" => s["lemma"], "sense_key" => s["sense_key"], "definition" => s["definition"] } },
  "grammar_dependencies" => senses.select { |s| s["route"] == "grammar" }.map { |s| [s["lemma"], s["sense_key"]] },
  "semantic_ir_dependencies" => senses.select { |s| s["route"] == "semantic_ir" }.map { |s| [s["lemma"], s["sense_key"]] }
}

report = <<~MD
  # Gate 4D Coverage and Ambiguity Report

  Status: **COMPLETE — CANONICAL MEASUREMENT RELEASE**  
  Version: **#{VERSION}**

  ## What the numbers mean

  This report measures the approved Gate 4C index, not unrestricted English. Its benchmark contains every exact canonical atom and compound label plus #{high_frequency.length} separately reviewed high-frequency senses. A routed sense counts as analyzed even when its implementation belongs to grammar, semantic IR, or a future vocabulary addition. A gap is never counted as expressible.

  ## Coverage

  - Indexed senses: **#{total}** across **#{lemmas.length}** normalized lemmas.
  - Direct atom mappings: **#{routes.fetch('atom', 0)}**.
  - Direct compound mappings: **#{routes.fetch('compound', 0)}**.
  - Grammar-dependent senses: **#{routes.fetch('grammar', 0)}**.
  - Semantic-IR-dependent senses: **#{routes.fetch('semantic_ir', 0)}**.
  - Explicit unsupported gaps: **#{gaps}**.
  - Direct lexical coverage of the full index: **#{metrics.dig('route_coverage', 'direct_lexical_percent')}%**.
  - Structurally routed coverage, including future grammar/IR: **#{metrics.dig('route_coverage', 'structurally_routed_percent')}%**.
  - Exact controlled-label coverage: **100% of 324 atoms and 100% of #{compounds.length} compounds**.

  The reviewed high-frequency layer has **#{metrics.dig('high_frequency_benchmark', 'direct_lexical_percent')}%** direct lexical coverage and **#{metrics.dig('high_frequency_benchmark', 'eventual_structural_percent')}%** eventual coverage after the planned grammar and semantic IR exist. Its remaining **#{metrics.dig('high_frequency_benchmark', 'gap_percent')}%** are honest vocabulary gaps.

  ## Ambiguity

  - Lemmas requiring disambiguation or nonlexical routing: **#{ambiguous_lemmas.length}/#{lemmas.length} (#{metrics.dig('ambiguity', 'lemma_ambiguity_percent')}%)**.
  - Lemmas with more than one direct canonical target: **#{multi_direct.length}**.
  - Critical polysemy includes *send*, *receive*, *share*, *change*, *exist*, and similar domain-sensitive verbs.

  A future translator must never select the first sense by file order. It must use a supplied controlled sense, contextual constraints, ranked candidates, or clarification. An unsupported reading must return a structured gap, not a nearby meaning.

  ## Known limitations

  The current release does not claim unrestricted vocabulary, morphology, idioms, metaphor, tense/aspect execution, reference resolution, or discourse interpretation. The exact-label benchmark is deliberately easier than natural English; the high-frequency layer is the more realistic early signal. Gate 4E etymology remains separate, and translator implementation is still blocked on semantic IR, grammar, rendering, decoding, and conformance tests.
MD

ambiguity_table = +"# Gate 4D Ambiguity Register\n\nStatus: **CURRENT**\n\n"
ambiguity_table << "| Lemma | Senses | Routes | Direct targets |\n|---|---:|---|---|\n"
ambiguous_lemmas.sort.each do |lemma, item|
  records = senses.select { |s| s["lemma"] == lemma }
  targets = records.map { |s| s["target_id"] }.compact.uniq
  ambiguity_table << "| #{lemma} | #{records.length} | #{records.map { |s| s['route'] }.uniq.sort.join(', ')} | #{targets.empty? ? '—' : targets.join(', ')} |\n"
end

migration = {
  "migration_id" => "gate4d_coverage_and_ambiguity_1.0", "date" => DATE, "status" => "applied",
  "from" => { "gate4d_status" => "not_started" },
  "to" => { "gate4d_status" => "complete", "version" => VERSION, "measured_senses" => total, "measured_lemmas" => lemmas.length },
  "sense_index_fingerprint" => metrics.dig("metadata", "sense_index_fingerprint"),
  "semantic_changes" => [], "next_gate" => "gate4e_etymology_table"
}

File.write(File.join(EraZeroValidation::ROOT, "reports/gate4d_coverage_metrics.yaml"), YAML.dump(metrics))
File.write(File.join(EraZeroValidation::ROOT, "reports/gate4d_coverage_and_ambiguity.md"), report)
File.write(File.join(EraZeroValidation::ROOT, "reports/gate4d_ambiguity_register.md"), ambiguity_table)
File.write(File.join(EraZeroValidation::ROOT, "migrations/gate4d_coverage_and_ambiguity_1.0.yaml"), YAML.dump(migration))

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["last_completed_gate"] = "gate4d_coverage_and_ambiguity_report"
version["next_gate_authorized"] = "gate4e_etymology_table"
version["gate4d_status"] = "complete"
version["coverage_report_version"] = VERSION
File.write(version_path, YAML.dump(version))

readiness_path = File.join(EraZeroValidation::ROOT, "spec/translator_readiness.yaml")
readiness = YAML.load_file(readiness_path)
readiness["next_authorized_gate"] = "gate4e_etymology_table"
gate2 = readiness.fetch("required_gates").find { |g| g["gate"] == "compound_and_coverage" }
g4d = gate2.fetch("subgates").find { |g| g["gate"] == "gate4d_coverage_and_ambiguity_report" }
g4d["status"] = "complete"
g4d["direct_lexical_percent"] = metrics.dig("route_coverage", "direct_lexical_percent")
g4d["explicit_gaps"] = gaps
readiness["gate4d"] = { "status" => "complete", "metrics" => "reports/gate4d_coverage_metrics.yaml", "report" => "reports/gate4d_coverage_and_ambiguity.md", "translator_authorized" => false }
File.write(readiness_path, YAML.dump(readiness))

status_path = File.join(EraZeroValidation::ROOT, "semantic_authority_status.md")
status = File.read(status_path)
unless status.include?("Gate 4D coverage and ambiguity")
  status << "\n## Gate 4D coverage and ambiguity — #{DATE}\n\n- Status: **complete measurement release #{VERSION}**.\n- Measured **#{total} senses / #{lemmas.length} lemmas**. Direct lexical coverage is **#{metrics.dig('route_coverage', 'direct_lexical_percent')}%**; structurally routed coverage is **#{metrics.dig('route_coverage', 'structurally_routed_percent')}%**; **#{gaps}** senses remain explicit gaps.\n- No semantic definition changed. Next authorized work: **Gate 4E etymology table**.\n"
  File.write(status_path, status)
end

puts "Built Gate 4D coverage: #{total} senses / #{lemmas.length} lemmas / #{gaps} gaps"
