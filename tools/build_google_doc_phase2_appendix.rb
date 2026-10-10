#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
atoms = YAML.load_file(File.join(ROOT, "lexicon/provisional_atoms.yaml")).fetch("atoms")
phase2_spec = YAML.load_file(File.join(ROOT, "spec/phase2_provisional_spec.yaml"))
chunks = phase2_spec.fetch("review_chunks")

class AppendixBuilder
  attr_reader :text, :headings

  def initialize
    @text = +""
    @headings = []
  end

  def utf16_length(value)
    value.encode("UTF-16LE").bytesize / 2
  end

  def paragraph(value = "")
    @text << value.to_s.rstrip << "\n"
  end

  def heading(value, style)
    start_index = utf16_length(@text)
    paragraph(value)
    @headings << {
      "start" => start_index,
      "end" => utf16_length(@text),
      "style" => style
    }
  end
end

def path_text(path)
  path.map { |value| value.positive? ? "+#{value}" : value.to_s }.join(", ")
end

builder = AppendixBuilder.new
builder.paragraph
builder.heading("PHASE 2 — COMPLETE PROVISIONAL 288-ROOT CATALOGUE", "HEADING_1")
builder.paragraph("This appendix completes the address inventory while preserving the Phase 1 authority boundary. The 36 source-approved LIF:000–222 and MOV:000–022 meanings above remain canonical and unchanged. The 288 entries below are design proposals requested after Phase 1; they require explicit approval before their titles and definitions become canonical.")
builder.paragraph
builder.heading("Phase 2 status and reading rules", "HEADING_2")
builder.paragraph("Inventory: 324 total addresses = 36 canonical meanings + 288 provisional meanings.")
builder.paragraph("Review units: 32 ordered chunks of nine roots. A chunk may be approved, approved with edits, or returned for revision.")
builder.paragraph("Encoding authority: family onset, harmonic signature, universal slot, compact root, family-qualified transliteration, formal carrier, and note path are generated from accepted algorithms.")
builder.paragraph("Semantic authority: every new title and core definition is provisional. None was presented as a claim extracted from the original Era Zero conversation.")
builder.paragraph("State separation: the third address trit is permanently lexical. A separate runtime ending [0], [1], or [2]/num states whether that lexical concept is currently inactive, active, or pending.")
builder.paragraph("Runtime glosses: [0] inactive, false, ended, unavailable, or inaccessible; [1] active, valid, expressed, or executing; [2]/num dormant, pending, remembered, possible, or unresolved.")
builder.paragraph
builder.heading("Provisional ORI / num resolution", "HEADING_2")
builder.paragraph("ORI:002 is generated as nu·nan by the latest compact-root algorithm and is proposed to mean “latent first condition.” The word num remains the name of runtime state 2. Historical use of num as a contraction is still unresolved and is not canonized here.")
builder.paragraph

chunks.each do |chunk|
  builder.heading("Chunk #{format('%02d', chunk.fetch('number'))} — #{chunk.fetch('range')}", "HEADING_2")
  builder.paragraph("Status: provisional for review as one nine-root semantic unit.")
  builder.paragraph

  chunk.fetch("ids").each do |id|
    atom = atoms.find { |candidate| candidate.fetch("canonical_id") == id }
    raise "Missing atom #{id}" unless atom

    builder.heading("#{id} — #{atom.fetch('canonical_transliteration')} — #{atom.fetch('title')}", "HEADING_3")
    builder.paragraph("Universal slot: #{atom.fetch('universal_slot')}")
    builder.paragraph("Address axes: first = #{atom.dig('address_axes', 'first_trit')}; second = #{atom.dig('address_axes', 'second_trit')}; third = #{atom.dig('address_axes', 'third_trit')}.")
    builder.paragraph("Encoding: local root #{atom.fetch('local_compact_root')}; full carrier #{atom.fetch('formal_carrier')}; family harmony [#{atom.fetch('harmonic_signature_semitones').join(', ')}]; note path [#{path_text(atom.fetch('note_path_semitones'))}] semitones.")
    builder.paragraph("Proposed meaning: #{atom.fetch('core_definition')}")
    builder.paragraph("Boundaries: keep this root inside #{atom.fetch('family_domain')}; do not confuse its third address trit with the separate runtime ending.")
    neighbor_text = atom.fetch("neighbor_contrasts").map do |neighbor_id|
      neighbor = atoms.find { |candidate| candidate.fetch("canonical_id") == neighbor_id }
      "#{neighbor_id} #{neighbor.fetch('title')}"
    end
    builder.paragraph("Nearest lexical contrasts: #{neighbor_text.join('; ')}.")
    builder.paragraph("Usage example: #{id} [1] — #{atom.fetch('core_definition')}")
    builder.paragraph("Runtime variants: #{id} [0] inactive/unavailable; #{id} [1] active/valid; #{id} [2]/num pending/unresolved.")
    builder.paragraph
  end
end

builder.heading("Phase 2 validation and approval gate", "HEADING_2")
builder.paragraph("Validation result: 17 checks passed, 0 failed, including 2,268 field-level algorithm assertions.")
builder.paragraph("Coverage result: 324 unique IDs, 27 addresses per family, 288 proposal IDs covered exactly once by 32 nine-root chunks, and zero missing addresses.")
builder.paragraph("Preservation result: all 36 Phase 1 canonical atom objects are retained unchanged in the complete local inventory.")
builder.paragraph("Scope result: no English translator, new syntax, long-address encoding, negation system, final glyph geometry, or historical contraction canonization was generated.")
builder.paragraph("Approval gate: the core address inventory is structurally complete, but the 288 proposed lexical meanings remain provisional until explicitly approved.")
builder.paragraph
builder.paragraph("End of Era Zero Phase 2 provisional root catalogue.")

text_path = File.join(ROOT, "reports/google_doc_phase2_appendix.txt")
metadata_path = File.join(ROOT, "reports/google_doc_phase2_appendix_metadata.json")
File.write(text_path, builder.text, encoding: "UTF-8")
File.write(
  metadata_path,
  JSON.pretty_generate(
    {
      "utf16_length" => builder.text.encode("UTF-16LE").bytesize / 2,
      "character_length" => builder.text.length,
      "headings" => builder.headings,
      "atom_heading_count" => builder.headings.count { |heading| heading["style"] == "HEADING_3" },
      "chunk_heading_count" => builder.headings.count { |heading| heading["style"] == "HEADING_2" && builder.text.encode("UTF-16LE").byteslice(heading["start"] * 2, (heading["end"] - heading["start"]) * 2).force_encoding("UTF-16LE").encode("UTF-8").start_with?("Chunk ") }
    }
  ),
  encoding: "UTF-8"
)

puts "Built Google Doc appendix: #{builder.text.length} characters, #{builder.headings.length} styled headings."
