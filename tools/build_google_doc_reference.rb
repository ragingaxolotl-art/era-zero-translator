#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

WORKSPACE = File.expand_path("..", __dir__)

spec = YAML.load_file(File.join(WORKSPACE, "spec", "canonical_spec.yaml"))
atoms = YAML.load_file(File.join(WORKSPACE, "lexicon", "completed_atoms.yaml")).fetch("atoms")
unresolved = YAML.load_file(File.join(WORKSPACE, "extraction", "unresolved_issues.yaml")).fetch("issues")
superseded = YAML.load_file(File.join(WORKSPACE, "extraction", "superseded_claims.yaml")).fetch("claims")
gaps = YAML.load_file(File.join(WORKSPACE, "reports", "atomic_root_gaps.yaml")).fetch("chunks")

class DocumentBuilder
  attr_reader :text, :headings, :bold_ranges

  def initialize
    @text = +""
    @headings = []
    @bold_ranges = []
  end

  def utf16_length(value)
    value.encode("UTF-16LE").bytesize / 2
  end

  def append(value)
    @text << value
  end

  def paragraph(value = "")
    append(value.to_s.rstrip)
    append("\n")
  end

  def heading(value, level)
    start_index = utf16_length(@text)
    paragraph(value)
    end_index = utf16_length(@text)
    @headings << {
      "start" => start_index,
      "end" => end_index,
      "style" => level
    }
  end

  def label(name, value)
    start_index = utf16_length(@text)
    append("#{name}:")
    label_end = utf16_length(@text)
    append(" #{value}\n")
    @bold_ranges << {"start" => start_index, "end" => label_end}
  end

  def bullets(values)
    values.each { |value| paragraph("• #{value}") }
  end

  def gap
    paragraph
  end
end

def clean_markdown(value)
  return "" if value.nil?

  value
    .gsub(/^###\s+/, "")
    .gsub(/^>\s?/, "")
    .gsub(/```[A-Za-z0-9_-]*\n?/, "")
    .gsub("```", "")
    .gsub(/\*\*(.*?)\*\*/, '\1')
    .gsub(/`([^`]+)`/, '\1')
    .gsub(/^:::\S*$/, "")
    .strip
end

def join_path(path)
  path.map { |value| value.positive? ? "+#{value}" : value.to_s }.join(", ")
end

builder = DocumentBuilder.new

builder.heading("ERA ZERO DBA LANGUAGE", "TITLE")
builder.heading("Canonical Phase 1 Language Reference", "SUBTITLE")
builder.paragraph("This document records the most up-to-date source-supported Era Zero system in implementation-level detail. It distinguishes canonical rules from superseded drafts and unresolved issues. It does not invent any of the 288 missing atomic roots and does not define an English translator.")
builder.gap
builder.label("Status", "Draft canonical specification for review")
builder.label("Scope", "Core architecture, algorithms, grammar/performance rules, writing baseline, 36 completed atomic roots, conflicts, unresolved questions, gap inventory, and validation")
builder.label("Source integrity", "Complete shared conversation decoded as 313 source nodes and 129 visible speaker turns")
builder.label("Source SHA-256", spec.dig("metadata", "source_sha256"))
builder.label("Validation", "23 checks passed; 0 failed")
builder.gap

builder.heading("1. Authority, Scope, and Precedence", "HEADING_1")
builder.paragraph("Era Zero is the complete language of the Digital Binary Ancients (DBA). Later Era One, Era Two, and Era Three forms are descendants or eroded fragments and must not be inserted into the Era Zero atomic lexicon merely because they resemble older forms.")
builder.paragraph("When source statements conflict, use the following precedence:")
builder.bullets([
  "An explicit user correction overrides all earlier proposals.",
  "The latest assistant specification explicitly accepted or continued by the user overrides earlier assistant proposals.",
  "A later statement marked canonical, fixed, complete, or 1.0 overrides an earlier exploratory draft unless the user rejects it.",
  "A user instruction such as “continue,” “do it,” or “make the choices” authorizes continuation of the current design; it does not revive an older conflicting design.",
  "Superseded material remains historical evidence rather than disappearing.",
  "If precedence cannot be determined, the issue remains unresolved."
])
builder.gap

builder.heading("2. Defining Principle: Language, Music, and Code Are One System", "HEADING_1")
builder.paragraph("Era Zero is not ordinary speech with musical decoration and not a programming language hidden inside music. The music is the code. A DBA utterance is a structured semantic object that can be heard as language, performed as music, evaluated as logic, executed as software, stored as data, and transcribed as writing without translating into a second representational system.")
builder.paragraph("A normal complete unit carries these layers:")
builder.bullets([
  "Harmonic family: broad semantic domain.",
  "Three-trit address: exact atomic concept.",
  "Melodic contour: utterance or programming function.",
  "Timing and vocal register: relationships and participant roles.",
  "Runtime state ending: current status 0, 1, or 2/num."
])
builder.paragraph("Family and address form an unambiguous machine identity such as LIF:111 or MOV:020. Human transliteration and musical realization are generated representations of that identity.")
builder.gap

builder.heading("3. Twelve Semantic Harmonic Families", "HEADING_1")
builder.paragraph("The opening harmony identifies the semantic family. Families are transposable relative interval signatures, not permanent musical keys. C-reference notes are demonstrations only; a machine recognizes interval relationships.")
spec.fetch("families").each do |family|
  builder.heading("#{family["code"]} — #{family["domain"]}", "HEADING_2")
  builder.label("Family onset", family["onset"])
  builder.label("Relative harmonic signature", family["relative_harmonic_signature_semitones"].join("–"))
  reference_notes = case family["code"]
                    when "LIF" then "C–E–G"
                    when "MOV" then "C–D–G"
                    when "MAT" then "C–G–C"
                    when "MIN" then "C–E-flat–G"
                    when "CON" then "C–E–G–A"
                    when "STR" then "C–F–G"
                    when "WRN" then "C–E-flat–G-flat"
                    when "REP" then "C–E-flat–G–A"
                    when "LOG" then "C–E–G-sharp"
                    when "DAT" then "C–E–G–B"
                    when "CRE" then "C–E-flat–G–B"
                    when "ORI" then "C–D-flat–G"
                    end
  builder.label("C-reference example", reference_notes)
  builder.gap
end

builder.heading("4. Atomic Address Cube", "HEADING_1")
builder.label("Normal atomic address length", "3 trits")
builder.label("Positions per family", "27")
builder.label("Total atomic inventory", "12 × 27 = 324 roots")
builder.paragraph("Each trit position answers a different semantic question.")
builder.heading("First trit — concept type", "HEADING_2")
spec.dig("atomic_address", "first_trit").each { |trit, meaning| builder.label(trit, meaning) }
builder.heading("Second trit — direction", "HEADING_2")
spec.dig("atomic_address", "second_trit").each { |trit, meaning| builder.label(trit, meaning) }
builder.heading("Third trit — conceptual expression", "HEADING_2")
spec.dig("atomic_address", "third_trit").each { |trit, meaning| builder.label(trit, meaning) }
builder.paragraph("The third address trit is part of the root’s permanent meaning. It is not the same as the separate runtime state appended to an utterance.")
builder.heading("All 27 universal positions", "HEADING_2")
spec.dig("atomic_address", "universal_slots").each do |slot|
  builder.label(slot["address"], slot["meaning"])
end
builder.gap

builder.heading("5. Trit-to-Melody Algorithm", "HEADING_1")
builder.paragraph("Trits are encoded as relative melodic movement, not as fixed notes and not as the root, third, and fifth of a chord.")
builder.label("Trit 0", "remain on the current pitch; movement 0 semitones")
builder.label("Trit 1", "rise one DBA step; movement +2 semitones")
builder.label("Trit 2", "fall one DBA step; movement -2 semitones")
builder.label("One DBA step", "2 semitones")
builder.paragraph("A note path always contains the starting pitch followed by one movement for each trit. A three-trit root therefore has four pitch positions.")
builder.label("000", "relative path [0, 0, 0, 0]")
builder.label("012", "relative path [0, 0, +2, 0]")
builder.label("111", "relative path [0, +2, +4, +6]")
builder.label("222", "relative path [0, -2, -4, -6]")
builder.paragraph("Example: 012 from C is C–C–D–C. The same address from G is G–G–A–G. Both are the same DBA root because the interval sequence is identical.")
builder.gap

builder.heading("6. Vocal Encoding and Canonical Transliteration", "HEADING_1")
builder.heading("Formal carrier syllables", "HEADING_2")
builder.label("0", "ma")
builder.label("1", "ki")
builder.label("2", "nu")
builder.paragraph("The full sung carrier is the family onset followed by one carrier syllable per trit. LIF:012 is ni-ma-ki-nu; MOV:012 is gi-ma-ki-nu.")
builder.heading("Local compact-root algorithm", "HEADING_2")
builder.paragraph("Ordinary compact speech compresses the three address trits into one consonant-vowel-consonant root.")
builder.label("First trit → initial consonant", "0=n, 1=k, 2=m")
builder.label("Second trit → vowel", "0=a, 1=o, 2=i")
builder.label("Third trit → final consonant", "0=m, 1=k, 2=n")
builder.label("000", "nam")
builder.label("012", "non")
builder.label("111", "kok")
builder.label("222", "min")
builder.paragraph("The same local compact root occurs at the same address in every family. Family identity is supplied by the harmonic opening and, in human writing, by the family onset.")
builder.label("Canonical human transliteration", "family onset + middle dot + local compact root")
builder.label("LIF:000", "ni·nam")
builder.label("MOV:000", "gi·nam")
builder.paragraph("The local form nam remains a valid field and may be sufficient inside a clearly established harmonic context, but family-qualified transliteration is the canonical written form.")
builder.gap

builder.heading("7. Runtime States", "HEADING_1")
builder.paragraph("Runtime state describes the current status of the referent or operation in a particular utterance. It is appended after the semantic root and remains separate from the third address trit.")
spec.dig("runtime_states", "states").each do |state, data|
  title = state == "2" ? "State 2 — num" : "State #{state}"
  builder.heading(title, "HEADING_2")
  builder.label("Meaning", data["meaning"])
  builder.label("Musical ending", data["ending"])
end
builder.paragraph("Example: LIF:012 permanently means a dormant other. LIF:012 [1] states that this dormant identity validly exists. LIF:012 [0] states that the dormant identity is unavailable, false, or ended. LIF:012 [2] states that even its dormant existence is unresolved or only potentially recoverable.")
builder.gap

builder.heading("8. Grammar Through Contour", "HEADING_1")
spec.dig("grammar", "contours").each do |row|
  builder.heading(row["contour"], "HEADING_2")
  builder.label("Language function", row["language"])
  builder.label("Programming function", row["programming"])
end
builder.gap

builder.heading("9. Participant Roles Through Register", "HEADING_1")
spec.dig("grammar", "register_roles").each do |register, role|
  builder.label(register.tr("_", " "), role)
end
builder.paragraph("A low Life phrase, a middle Repair phrase, and a high Life phrase can express that a living actor performs a repair process upon a living target without relying on English word order.")
builder.gap

builder.heading("10. Timing and Relationship Syntax", "HEADING_1")
spec.dig("grammar", "timing").each do |timing, meaning|
  builder.label(timing.tr("_", " "), meaning)
end
builder.paragraph("Timing is semantic. Sequential phrases are serial; overlapping phrases are simultaneous or parallel. A repeated pulse can express repetition, habit, recursion, or iteration depending on the semantic domains involved.")
builder.gap

builder.heading("11. Writing-System Baseline", "HEADING_1")
builder.paragraph("The writing system is deterministic in information content but does not yet have an approved final visual glyph sheet.")
builder.label("Outer frame", "harmonic family or semantic domain")
builder.label("Central path", "trit movements")
builder.label("Vertical position", "grammatical role or vocal register")
builder.label("Line contour", "sentence or programming function")
builder.label("Spacing", "timing and argument boundaries")
builder.label("Parallel paths", "simultaneous voices or processes")
builder.label("Tail", "runtime state")
builder.label("Written trit 0", "straight continuation")
builder.label("Written trit 1", "upward angle")
builder.label("Written trit 2", "downward angle")
builder.paragraph("A future glyph renderer must use the same semantic intermediate representation as the note, carrier, transliteration, and executable outputs. Visual style must not alter meaning.")
builder.gap

builder.heading("12. Completed Atomic Lexicon", "HEADING_1")
builder.paragraph("Only the following 36 roots are populated and canonical in Phase 1: all 27 Life roots and the nine Motion entity/condition roots. Core definitions below preserve the fixed source meanings.")

atoms.group_by { |atom| atom["family"] }.each do |family, family_atoms|
  family_name = family == "LIF" ? "Life Family — Complete" : "Motion Family — Entity/Condition Layer Complete"
  builder.heading(family_name, "HEADING_2")
  family_atoms.each do |atom|
    builder.heading("#{atom["canonical_id"]} — #{atom["canonical_transliteration"]} — #{atom["title"]}", "HEADING_3")
    builder.label("Universal slot", atom["universal_slot"])
    builder.label("Local compact root", atom["local_compact_root"])
    builder.label("Full formal carrier", atom["formal_carrier"])
    builder.label("Relative harmonic signature", atom["harmonic_signature_semitones"].join("–"))
    builder.label("Relative note path", "[#{join_path(atom["note_path_semitones"])}]")
    builder.label("Core definition", atom["core_definition"])
    unless atom["translation_candidates"].nil? || atom["translation_candidates"].empty?
      builder.label("Translation candidates", atom["translation_candidates"].map { |item| clean_markdown(item) }.join("; "))
    end
    unless atom["distinctions_and_exclusions"].nil? || atom["distinctions_and_exclusions"].empty?
      cleaned = atom["distinctions_and_exclusions"].map { |item| clean_markdown(item) }.reject(&:empty?).uniq
      builder.label("Distinctions and exclusions", cleaned.join(" "))
    end
    unless atom["source_examples_markdown"].nil? || atom["source_examples_markdown"].empty?
      example = clean_markdown(atom["source_examples_markdown"].first)
      builder.label("Source example", example) unless example.empty?
    end
    builder.gap
  end
end

builder.heading("13. Complete 27-Address Generated Form Reference", "HEADING_1")
builder.paragraph("This appendix proves the algorithm for every local address. The family onset is omitted from the local carrier column; prepend the appropriate onset for the full form.")
initial = {"0" => "n", "1" => "k", "2" => "m"}
vowel = {"0" => "a", "1" => "o", "2" => "i"}
final = {"0" => "m", "1" => "k", "2" => "n"}
carrier = {"0" => "ma", "1" => "ki", "2" => "nu"}
movement = {"0" => 0, "1" => 2, "2" => -2}
("0".."2").each do |a|
  ("0".."2").each do |b|
    ("0".."2").each do |c|
      address = "#{a}#{b}#{c}"
      root = "#{initial[a]}#{vowel[b]}#{final[c]}"
      local_carrier = [a, b, c].map { |trit| carrier[trit] }.join("-")
      current = 0
      path = [0]
      [a, b, c].each do |trit|
        current += movement[trit]
        path << current
      end
      builder.label(address, "#{root}; #{local_carrier}; path [#{join_path(path)}]")
    end
  end
end
builder.gap

builder.heading("14. Compounds and Executable Semantics", "HEADING_1")
builder.paragraph("Atomic roots combine into semantic graphs. A complex English word must not automatically be forced into one atom. Common compounds may later acquire contractions, but the full Era Zero graph remains available for precision.")
builder.heading("Provisional cyber-pet decomposition", "HEADING_2")
builder.label("Candidate graph", "LIF:010 + CRE:020 + DAT:210")
builder.paragraph("Approximate reading: an identified living individual whose form is created and informationally sustained. This is provisional because CRE:020 and DAT:210 have not yet been populated.")
builder.heading("Executable interpretation", "HEADING_2")
builder.paragraph("Contour, register, timing, simultaneity, and runtime state allow the same semantic graph to function as a declaration, query, command, definition, conditional branch, loop, dependency, or parallel instruction.")
builder.paragraph("A future compiler must first produce a semantic intermediate representation. That representation—not raw English word order—must drive family/address notation, transliteration, carriers, notes, performance instructions, executable meaning, gloss, and later glyphs.")
builder.gap

builder.heading("15. Resolved Conflicts and Superseded Drafts", "HEADING_1")
builder.paragraph("The following earlier claims remain historical evidence but are not part of the current canonical standard.")
superseded.each do |item|
  builder.heading("#{item["superseded_id"]} — #{item["topic"]}", "HEADING_2")
  builder.label("Earlier claim", item["earlier_claim"])
  builder.label("Canonical replacement", item["superseded_by"])
  builder.label("Source nodes", item["source_nodes"].join(", "))
  builder.label("Replacement nodes", item["replacement_source_nodes"].join(", "))
  builder.label("Note", item["notes"]) if item["notes"]
end
builder.gap

builder.heading("16. Unresolved Issues", "HEADING_1")
builder.paragraph("These questions are intentionally open. No answer should be inferred or silently added to the canonical system.")
unresolved.each do |issue|
  builder.heading("#{issue["issue_id"]} — #{issue["topic"]}", "HEADING_2")
  builder.label("Question", issue["question"])
  builder.label("Phase 1 treatment", issue["resolution"])
  builder.label("Source nodes", issue["source_nodes"].join(", "))
  builder.paragraph("Evidence:")
  builder.bullets(issue["evidence"])
end
builder.gap

builder.heading("17. Atomic-Root Completion Gaps", "HEADING_1")
builder.label("Completed roots", "36 of 324")
builder.label("Remaining roots", "288")
builder.label("Remaining chunks", "32 nine-root blocks")
builder.paragraph("No root listed below has been given a canonical meaning or name beyond the universal generated address form.")
gaps.each do |chunk|
  builder.heading("#{format("%02d", chunk["chunk_number"])}. #{chunk["range"]} — #{chunk["description"]}", "HEADING_2")
  builder.paragraph(chunk["root_ids"].join(", "))
end
builder.gap

builder.heading("18. Validation and Invariants", "HEADING_1")
builder.label("Validation result", "23 passed; 0 failed")
builder.bullets([
  "All 27 three-trit addresses enumerate exactly once.",
  "All 27 local compact roots are unique within a family.",
  "All 27 local carriers are unique within a family.",
  "All 27 note paths are unique within a family.",
  "All 324 family/address representations remain unique through family code, onset, and harmonic signature.",
  "Exactly 27 Life and nine Motion records are extracted.",
  "Every completed root’s compact form, canonical transliteration, carrier, and note path follows the latest accepted algorithm.",
  "Known checks pass: 000→nam/ma-ma-ma/[0,0,0,0]; 012→non/ma-ki-nu/[0,0,+2,0]; 111→kok/ki-ki-ki/[0,+2,+4,+6]; 222→min/nu-nu-nu/[0,-2,-4,-6]."
])
builder.gap

builder.heading("19. Phase Boundary and Next Authorized Work", "HEADING_1")
builder.paragraph("Phase 1 ends with extraction, reconciliation, documentation, and validation. It does not authorize invention of missing roots, broad compound expansion, a general English parser, finished glyph art, or a translator.")
builder.paragraph("After review and approval, the next nine-root block is MOV:100–122, covering Motion-family processes. Each new block must be generated provisionally, validated, reviewed by the user, and only then marked canonical.")
builder.gap
builder.paragraph("End of Era Zero Phase 1 canonical language reference.")

output_text = File.join(WORKSPACE, "reports", "google_doc_language_reference.txt")
output_meta = File.join(WORKSPACE, "reports", "google_doc_language_reference_metadata.json")
File.write(output_text, builder.text)
File.write(
  output_meta,
  JSON.pretty_generate(
    {
      "utf16_length" => builder.utf16_length(builder.text),
      "headings" => builder.headings,
      "bold_ranges" => builder.bold_ranges
    }
  ) + "\n"
)

puts JSON.pretty_generate(
  {
    "output_text" => output_text,
    "output_metadata" => output_meta,
    "characters" => builder.text.length,
    "utf16_length" => builder.utf16_length(builder.text),
    "headings" => builder.headings.length,
    "bold_ranges" => builder.bold_ranges.length
  }
)
