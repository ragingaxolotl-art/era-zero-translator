# frozen_string_literal: true
require 'json'

# Explicit lexical specialization, separate from what a root graph entails.
module EraZeroCompoundConventions
  KEYS = %w[profile sense_key sound_code added_definition excludes].freeze
  module_function

  def validate!(entries, error_class: ArgumentError)
    codes, senses = {}, {}
    entries.each do |entry|
      next unless entry.key?('conventional_meaning')
      meaning = entry['conventional_meaning']
      unless meaning.is_a?(Hash) && meaning.keys.sort == KEYS.sort && meaning['profile'] == 'EZLEX-1' &&
          meaning['sense_key'].is_a?(String) && meaning['sense_key'].match?(/\A[a-z][a-z0-9_]{2,79}\z/) &&
          meaning['sound_code'].is_a?(Integer) && meaning['sound_code'].between?(0, 6560) &&
          meaning['added_definition'].is_a?(String) && meaning['added_definition'].strip.length >= 20 &&
          meaning['excludes'].is_a?(Array) && !meaning['excludes'].empty? &&
          meaning['excludes'].all? { |value| value.is_a?(String) && !value.strip.empty? } &&
          meaning['excludes'].uniq == meaning['excludes']
        raise error_class, 'invalid explicit compound convention'
      end
      code, sense = meaning.values_at('sound_code', 'sense_key')
      if (codes.key?(code) && codes[code] != meaning) || (senses.key?(sense) && senses[sense] != meaning)
        raise error_class, 'compound convention code or sense has conflicting meanings'
      end
      codes[code] = meaning
      senses[sense] = meaning
    end
    true
  end

  def distinct_dictionary_graph?(entry, expanded)
    return false unless expanded.fetch('nodes').count { |node| node['kind'] == 'root' } >= 2
    nodes = entry.fetch('nodes')
    nodes.length > 1 || (nodes.length == 1 && nodes.first['kind'] == 'compound_ref' && entry['conventional_meaning'].is_a?(Hash))
  end

  def semantic_payload(entry)
    fields = %w[architecture_version semantic_head nodes edges lexical_constraints conventional_meaning binding_constraints]
    entry.select { |key, _| fields.include?(key) }
  end

  # Fixed-width lexical trits encode identity, never occurrence runtime state.
  def pitches(meaning, side)
    raise ArgumentError, 'invalid convention frame side' unless %w[open close].include?(side)
    trits = meaning.fetch('sound_code').to_s(3).rjust(8, '0').chars.map { |trit| [0, 1, -1].fetch(trit.to_i) }
    [0, side == 'open' ? -19 : 19, *trits, 0]
  end

  def event(meaning, side, occurrence_id, anchor_midi, path)
    relative = pitches(meaning, side)
    marker = "convention_#{meaning.fetch('sound_code')}_#{side}"
    { 'kind' => 'grammar_marker', 'grammar_profile' => 'EZLEX-1', 'marker' => marker,
      'convention_scope_path' => path, 'convention_sense' => meaning.fetch('sense_key'),
      'occurrence_id' => occurrence_id, 'target_id' => "EZLEX:#{marker}",
      'register' => 'middle', 'base_midi' => anchor_midi,
      'family_qualified_transliteration' => marker, 'formal_carrier' => '',
      'family_opening_relative_semitones' => [], 'family_opening_absolute_midi' => [],
      'address_relative_semitones' => relative, 'address_absolute_midi' => relative.map { |note| anchor_midi + note },
      'note_duration_beats' => 0.25, 'boundary_after_beats' => 0.5 }
  end
end
