#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require_relative "era_zero_renderer"

module EraZeroPresentation
  VERSION = "1.0.0"
  TICKS_PER_BEAT = 480
  TEMPO_MICROSECONDS = 500_000

  class PresentationError < StandardError; end
  module_function

  def xml_escape(value)
    value.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
  end

  def validate_formal!(formal)
    EraZeroRenderer.decode(formal)
    raise PresentationError, "performance profile is missing" unless formal["performance"].is_a?(Hash)
    true
  rescue EraZeroRenderer::DecodeError => error
    raise PresentationError, "invalid EZF-1 input: #{error.message}"
  end

  def note_sequence(event)
    event.fetch("family_opening_absolute_midi") + event.fetch("address_absolute_midi") + Array(event.dig("runtime_tail", "absolute_note"))
  end

  def svg(formal)
    validate_formal!(formal)
    events = formal.dig("performance", "lexical_events")
    width = [960, 160 + events.sum { |event| note_sequence(event).length * 34 + 28 }].max
    height = 220 + events.length * 54
    cursor = 100
    rows = []
    events.each_with_index do |event, row|
      y0 = 95 + row * 54
      notes = note_sequence(event)
      points = notes.map.with_index do |note, index|
        x = cursor + index * 34
        y = y0 - (note - event.fetch("base_midi")) * 3
        [x, y, note]
      end
      path = points.map.with_index { |(x, y, _), index| "#{index.zero? ? 'M' : 'L'} #{x} #{y}" }.join(" ")
      label = [event["occurrence_id"], event["component_role"], event["target_id"], "state #{event.dig('runtime_tail', 'code')}"].compact.join(" · ")
      rows << %(<g class="lexical-event" data-target-id="#{xml_escape(event['target_id'])}" data-register="#{xml_escape(event['register'])}"><text x="20" y="#{y0 + 5}" class="label">#{xml_escape(label)}</text><path d="#{path}" class="melody"/>#{points.map { |x, y, note| %(<circle cx="#{x}" cy="#{y}" r="5" data-midi="#{note}"/>) }.join}</g>)
      cursor += notes.length * 34 + 28
    end
    contour = formal.dig("performance", "contour_relative_semitones").join(",")
    <<~SVG
      <?xml version="1.0" encoding="UTF-8"?>
      <svg xmlns="http://www.w3.org/2000/svg" width="#{width}" height="#{height}" viewBox="0 0 #{width} #{height}" role="img" aria-labelledby="title desc" data-format="EZSVG-1" data-formal-id="#{xml_escape(formal['formal_id'])}">
        <title id="title">Era Zero formal notation #{xml_escape(formal['formal_id'])}</title>
        <desc id="desc">Deterministic pitch-path visualization. Primary contour #{xml_escape(formal.dig('performance', 'primary_contour'))}; relative contour #{xml_escape(contour)}.</desc>
        <style>.background{fill:#fff}.staff{stroke:#d4d8de;stroke-width:1}.melody{fill:none;stroke:#202733;stroke-width:2}.lexical-event circle{fill:#3b82f6;stroke:#172033;stroke-width:1}.label{font:12px system-ui,sans-serif;fill:#111827}</style>
        <rect class="background" width="100%" height="100%"/>
        #{(0..8).map { |line| %(<line class="staff" x1="0" x2="#{width}" y1="#{55 + line * 18}" y2="#{55 + line * 18}"/>) }.join}
        #{rows.join("\n  ")}
        <metadata>semantic-digest=#{xml_escape(formal['semantic_digest'])}; profile=#{xml_escape(formal.dig('performance', 'profile'))}; contour=#{xml_escape(contour)}</metadata>
      </svg>
    SVG
  end

  def variable_length(value)
    bytes = [value & 0x7f]
    while (value >>= 7) > 0
      bytes.unshift((value & 0x7f) | 0x80)
    end
    bytes.pack("C*")
  end

  def midi(formal)
    validate_formal!(formal)
    absolute_events = []
    tick = 0
    formal.dig("performance", "lexical_events").each do |event|
      notes = note_sequence(event)
      notes.each_with_index do |note, index|
        raise PresentationError, "MIDI note outside 0..127" unless note.between?(0, 127)
        duration = if index == notes.length - 1 && event["runtime_tail"]
                     (event.dig("runtime_tail", "duration_beats") * TICKS_PER_BEAT).round
                   else
                     TICKS_PER_BEAT
                   end
        absolute_events << [tick, 1, [0x90, note, 90]]
        absolute_events << [tick + duration, 0, [0x80, note, 0]]
        tick += duration
      end
      tick += (0.5 * TICKS_PER_BEAT).round
    end
    contour_base = formal.dig("performance", "anchor_midi")
    formal.dig("performance", "contour_relative_semitones").each do |offset|
      note = contour_base + offset
      absolute_events << [tick, 1, [0x90, note, 70]]
      absolute_events << [tick + TICKS_PER_BEAT / 2, 0, [0x80, note, 0]]
      tick += TICKS_PER_BEAT / 2
    end
    absolute_events.sort_by! { |at, priority, bytes| [at, priority, bytes[1]] }
    track = +"\x00\xFF\x51\x03".b + [TEMPO_MICROSECONDS].pack("N")[1, 3] + "\x00\xC0\x00".b
    previous = 0
    absolute_events.each do |at, _priority, bytes|
      track << variable_length(at - previous) << bytes.pack("C*")
      previous = at
    end
    track << "\x00\xFF\x2F\x00".b
    "MThd".b + [6, 0, 1, TICKS_PER_BEAT].pack("Nnnn") + "MTrk".b + [track.bytesize].pack("N") + track
  end

  def manifest(formal)
    svg_data = svg(formal)
    midi_data = midi(formal)
    { "presentation_version" => VERSION, "formal_id" => formal.fetch("formal_id"), "semantic_digest" => formal.fetch("semantic_digest"), "svg_sha256" => Digest::SHA256.hexdigest(svg_data), "midi_sha256" => Digest::SHA256.hexdigest(midi_data), "semantic_identity_changed" => false }
  end
end
