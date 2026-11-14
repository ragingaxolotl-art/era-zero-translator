# frozen_string_literal: true
require "minitest/autorun"
require_relative "../tools/lib/era_zero_controlled_english"
require_relative "../tools/lib/era_zero_presentation"

class RepetitionPerformanceTest < Minitest::Test
  def formal(text)
    result = EraZeroControlledEnglish::Compiler.new.compile(text)
    assert_equal "ok", result["status"]
    EraZeroRenderer.render(result.fetch("semantic_ir"))
  end

  # Parse the emitted MIDI track rather than comparing file hashes alone.
  def sounding_notes(bytes)
    position = 22
    notes = []
    while position < bytes.bytesize
      byte = 128
      while byte >= 128
        byte = bytes.getbyte(position)
        position += 1
      end
      status = bytes.getbyte(position)
      position += 1
      if status == 255
        position += 1 # meta type
        length = bytes.getbyte(position)
        position += 1 + length
      elsif status & 240 == 192
        position += 1
      else
        note, velocity = bytes.getbyte(position), bytes.getbyte(position + 1)
        notes << note if status & 240 == 144 && velocity.positive?
        position += 2
      end
    end
    notes
  end

  def test_two_and_three_repeat_the_entire_compound_melody
    [2, 3].each do |count|
      output = formal(%Q{ASSERT REPEAT #{count} TIMES "ongoing physical repair" [1].})
      phrase = output.dig("performance", "lexical_events").flat_map { |event| EraZeroPresentation.note_sequence(event) }
      contour = output.dig("performance", "contour_relative_semitones").map { |n| n + 60 }
      assert_equal phrase * count + contour, sounding_notes(EraZeroPresentation.midi(output))
    end
  end

  def test_nested_repetition_repeats_phrase_in_sequence_order
    output = formal('ASSERT SEQUENCE "active care" [1] THEN "conscious self" [1].')
    ir = Marshal.load(Marshal.dump(output["semantic_ir"]))
    center = ir["edges"].find { |edge| edge["type"] == "centers" }
    old = center["from"]
    center["from"] = "repeat"
    ir["nodes"] << { "node_id" => "repeat", "kind" => "scope_operator", "operator" => "repetition", "mode" => "count", "count" => 2 }
    ir["edges"] << { "edge_id" => "repeat_edge", "type" => "scopes", "from" => old, "to" => "repeat" }
    digest = EraZeroRenderer.semantic_digest(ir)
    ir["utterance_id"] = "UTT:#{digest[0, 24]}"
    ir["serialization"]["content_digest"] = digest
    repeated = EraZeroRenderer.render(ir)
    expected = output.dig("performance", "lexical_events").map { |e| e["target_id"] } * 2
    assert_equal expected, EraZeroPresentation.scheduled_lexical_events(repeated).map { |e| e["target_id"] }
  end

  def test_oversized_repetition_fails_before_allocating_export
    output = formal('ASSERT REPEAT 1000000000 TIMES "active care" [1].')
    assert_raises(EraZeroPresentation::PresentationError) { EraZeroPresentation.midi(output) }
  end
end
