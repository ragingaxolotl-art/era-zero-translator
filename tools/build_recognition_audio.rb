#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "yaml"
require_relative "lib/era_zero_validation"

# EZRP-1 is a presentation-only identity checksum. It never changes an atom's
# address, carrier, runtime state, sentence contour, or semantic identity.
palettes = {
  "LIF" => [0, 2, 4, 5, 7, 9, 11, 12],
  "MOV" => [0, 2, 4, 5, 7, 9, 10, 12],
  "MAT" => [0, 2, 4, 5, 7, 9, 11, 12],
  "MIN" => [0, 2, 3, 5, 7, 8, 10, 12],
  "CON" => [0, 2, 4, 5, 7, 9, 11, 12],
  "STR" => [0, 2, 5, 7, 9, 10, 11, 12],
  "WRN" => [0, 1, 3, 5, 6, 8, 10, 12],
  "REP" => [0, 2, 3, 5, 7, 9, 10, 12],
  "LOG" => [0, 2, 4, 6, 8, 10, 11, 12],
  "DAT" => [0, 2, 4, 6, 7, 9, 11, 12],
  "CRE" => [0, 2, 3, 5, 7, 8, 11, 12],
  "ORI" => [0, 1, 3, 5, 7, 8, 10, 12]
}.freeze

atoms = EraZeroValidation.load_yaml("lexicon/all_atoms.yaml").fetch("atoms").sort_by { |atom| atom.fetch("canonical_id") }
length_order = atoms.sort_by { |atom| Digest::SHA256.hexdigest("EZRP-1|length|#{atom.fetch('canonical_id')}") }
lengths = {}
[[2, 28], [3, 148], [4, 112], [5, 36]].each do |length, count|
  length_order.shift(count).each { |atom| lengths[atom.fetch("canonical_id")] = length }
end
raise "length assignment incomplete" unless length_order.empty? && lengths.length == atoms.length

used_pitch_signatures = {}
length_distribution = lengths.values.each_with_object(Hash.new(0)) { |length, counts| counts[length] += 1 }.sort.to_h
records = atoms.map do |atom|
  id = atom.fetch("canonical_id")
  family = atom.fetch("family")
  length = lengths.fetch(id)
  palette = palettes.fetch(family)
  wants_octave = Digest::SHA256.digest("EZRP-1|octave|#{id}").getbyte(0) % 4 == 0
  candidates = (0...(8**length)).map do |number|
    degrees = Array.new(length) { |index| (number / (8**(length - index - 1))) % 8 }
    next if degrees.each_cons(2).any? { |a, b| a == b }
    next if degrees.count(7) > 1
    next if wants_octave != degrees.include?(7)
    semitones = degrees.map { |degree| palette.fetch(degree) }
    next if semitones.each_cons(2).any? { |a, b| (a - b).abs > 7 }
    [Digest::SHA256.hexdigest("EZRP-1|candidate|#{id}|#{degrees.join}") , degrees, semitones]
  end.compact
  selected = candidates.sort_by(&:first).find { |_digest, _degrees, semitones| !used_pitch_signatures.key?(semitones.join(",")) }
  raise "no unique recognition phrase available for #{id}" unless selected
  _digest, degrees, semitones = selected
  used_pitch_signatures[semitones.join(",")] = id
  duration_palette = [0.75, 1.0, 1.25]
  durations = degrees.each_index.map do |index|
    byte = Digest::SHA256.digest("EZRP-1|rhythm|#{id}|#{index}").getbyte(0)
    duration_palette.fetch(byte % duration_palette.length)
  end
  checksum = Digest::SHA256.hexdigest(["EZRP-1", id, degrees.join("."), semitones.join("."), durations.join(".")].join("|"))[0, 16]
  {
    "target_id" => id,
    "note_count" => length,
    "degree_indices" => degrees,
    "relative_semitones" => semitones,
    "duration_beats" => durations,
    "octave_positions" => degrees.each_index.select { |index| degrees[index] == 7 },
    "checksum" => checksum,
    "semantic_content" => false
  }
end

document = {
  "metadata" => {
    "format" => "EZRP-1",
    "version" => "1.0.0",
    "status" => "presentation_only_optional_identity_checksum",
    "record_count" => records.length,
    "note_count_range" => [2, 5],
    "length_distribution" => length_distribution,
    "placement" => "after_address_before_runtime",
    "decoder_rule" => "absence is valid strict presentation; presence must match target_id; recognition data never contributes semantic content",
    "canonical_note_channels_changed" => false,
    "semantic_authority_changes" => 0,
    "generation_algorithm" => "EZRP-1 deterministic SHA-256 ordered allocation"
  },
  "family_palettes_relative_semitones" => palettes,
  "timing" => {
    "seconds_per_beat" => 0.24,
    "inter_note_seconds" => 0.04,
    "separation_before_seconds" => 0.14,
    "separation_after_seconds" => 0.12
  },
  "records" => records
}

EraZeroValidation.write("spec/recognition_audio_1.0.yaml", YAML.dump(document))
puts "Built EZRP-1 recognition registry: #{records.length} roots; #{length_distribution}"
