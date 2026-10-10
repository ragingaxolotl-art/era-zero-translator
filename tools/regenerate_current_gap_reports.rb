#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require_relative "lib/era_zero_validation"

include EraZeroValidation

atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
phase2 = EraZeroValidation.load_yaml("spec/phase2_provisional_spec.yaml")
old_gap = EraZeroValidation.load_yaml("reports/atomic_root_gaps.yaml")

canonical_ids = atoms.values.select { |record| record["status"] == "canonical" }
                     .map { |record| record.fetch("canonical_id") }.to_set
provisional_ids = atoms.values.select do |record|
  record["status"] == "provisional_pending_detailed_semantic_review"
end.map { |record| record.fetch("canonical_id") }.to_set

descriptions = old_gap.fetch("chunks", []).to_h do |chunk|
  [chunk.fetch("range"), chunk["description"]]
end

remaining_chunks = phase2.fetch("review_chunks").select do |chunk|
  chunk.fetch("ids").all? { |id| provisional_ids.include?(id) }
end

chunks = remaining_chunks.each_with_index.map do |chunk, index|
  {
    "chunk_number" => index + 1,
    "original_phase2_chunk_number" => chunk.fetch("number"),
    "family" => chunk.fetch("family"),
    "layer" => chunk.fetch("layer").to_i,
    "range" => chunk.fetch("range"),
    "description" => descriptions[chunk.fetch("range")] || "pending detailed semantic review",
    "root_ids" => chunk.fetch("ids"),
    "status" => "provisional_pending_detailed_semantic_review"
  }
end

raise "address inventory is not 324" unless atoms.length == 324
raise "authority partition is not exhaustive" unless (canonical_ids | provisional_ids).length == 324
raise "gap chunks do not cover every provisional root" unless chunks.flat_map { |chunk| chunk["root_ids"] }.to_set == provisional_ids
raise "gap chunks are not nine-root blocks" unless chunks.all? { |chunk| chunk["root_ids"].length == 9 }

gap_yaml = {
  "metadata" => {
    "title" => "Era Zero current atomic-root gap inventory",
    "authority_date" => Date.today.iso8601,
    "status" => "current_authority",
    "total" => atoms.length,
    "canonical" => canonical_ids.length,
    "remaining" => provisional_ids.length,
    "remaining_chunks" => chunks.length,
    "next_review_packet" => chunks.first && chunks.first["range"],
    "supersedes_gap_snapshot" => "36 canonical / 288 remaining / 32 chunks"
  },
  "chunks" => chunks
}
EraZeroValidation.write("reports/atomic_root_gaps.yaml", YAML.dump(gap_yaml))

canonical_families = FAMILIES.keys.select do |family|
  atoms.values.count { |atom| atom["family"] == family && atom["status"] == "canonical" } == 27
end

markdown = +"# Era Zero Current Atomic-Root Gap Report\n\n"
markdown << if provisional_ids.empty?
              "Status: **CURRENT AUTHORITY — ATOMIC SEMANTIC REVIEW COMPLETE**\n\n"
            else
              "Status: **CURRENT AUTHORITY — PENDING DETAILED SEMANTIC REVIEW**\n\n"
            end
markdown << "This report replaces the original Phase 1 `36/288` gap snapshot. That snapshot remains available through source and audit history, but it is not the current semantic inventory.\n\n"
markdown << "- Total deterministic addresses: **#{atoms.length}**\n"
markdown << "- Canonical meanings: **#{canonical_ids.length}**\n"
markdown << "- Remaining provisional meanings: **#{provisional_ids.length}**\n"
markdown << "- Remaining nine-root chunks: **#{chunks.length}**\n"
markdown << "- Fully canonical families: **#{canonical_families.join(", ")}**\n"
markdown << "- Next review packet: **#{chunks.empty? ? 'none — all atomic packets complete' : "`#{chunks.first["range"]}`"}**\n\n"
if provisional_ids.empty?
  markdown << "All 324 deterministic addresses now have canonical semantic titles and invariant definitions. No provisional atomic root remains.\n\n"
else
  markdown << "All #{provisional_ids.length} remaining addresses already have deterministic family, address, universal slot, harmonic signature, family onset, local compact root, formal carrier, and relative note path. Only their semantic titles and definitions remain provisional.\n\n"
end
markdown << "## Remaining chunks and exact root IDs\n\n"

chunks.each do |chunk|
  markdown << "### #{format("%02d", chunk["chunk_number"])}. `#{chunk["range"]}` — #{chunk["description"]}\n\n"
  markdown << "#{chunk["root_ids"].map { |id| "`#{id}`" }.join(", ")}\n\n"
end

markdown << "## Dependency boundary\n\n"
markdown << if provisional_ids.empty?
              "Atomic semantic completion does not approve compound meanings, an English concept index, etymology, semantic IR, executable grammar, renderer, or translator. Those layers remain separately gated.\n"
            else
              "No compound dictionary, English concept index, etymology layer, semantic IR, executable grammar, renderer, or translator may depend on these provisional meanings.\n"
            end
EraZeroValidation.write("reports/gap_report.md", markdown)

puts "Gap reports regenerated: #{canonical_ids.length} canonical, #{provisional_ids.length} provisional, #{chunks.length} chunks"
puts "Next packet: #{chunks.empty? ? 'none — atomic semantic review complete' : chunks.first["range"]}"
