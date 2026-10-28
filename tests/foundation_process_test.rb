# frozen_string_literal: true
require "minitest/autorun"
require_relative "../tools/lib/era_zero_controlled_english"
require_relative "../tools/lib/era_zero_presentation"

class FoundationProcessTest < Minitest::Test
  def test_ongoing_and_completed_processes_remain_distinct_in_midi
    compiler = EraZeroControlledEnglish::Compiler.new
    [["physical repair", "ongoing physical repair"], ["data repair", "ongoing internal data repair"],
     ["structural repair", "ongoing internal structural repair"]].each do |completed, ongoing|
      outputs = [completed, ongoing].map do |label|
        result = compiler.compile(%Q{ASSERT "#{label}" [1].})
        assert_equal "ok", result["status"]
        EraZeroRenderer.render(result.fetch("semantic_ir"))
      end
      assert outputs.first.dig("performance", "lexical_events").all? { |event| event["target_id"].end_with?("0") }
      assert outputs.last.dig("performance", "lexical_events").all? { |event| event["target_id"].end_with?("1") }
      refute_equal EraZeroPresentation.midi(outputs.first), EraZeroPresentation.midi(outputs.last)
      assert_equal 1, outputs.last.dig("performance", "lexical_events").count { |e| e["runtime_tail"] }
    end
  end

  def test_runtime_does_not_select_completed_lexical_phase
    compiler = EraZeroControlledEnglish::Compiler.new
    targets = [0, 1, 2].map do |state|
      result = compiler.compile(%Q{ASSERT "ongoing physical repair" [#{state}].})
      assert_equal "ok", result["status"]
      formal = EraZeroRenderer.render(result.fetch("semantic_ir"))
      assert_equal state, formal.dig("performance", "lexical_events").last.dig("runtime_tail", "code")
      formal.dig("performance", "lexical_events").map { |event| event["target_id"] }
    end
    assert_equal 1, targets.uniq.length
  end

  def test_participant_role_survives_controlled_compilation
    result = EraZeroControlledEnglish::Compiler.new.compile('ASSERT "ongoing physical repair" [1] ROLE target "machine" [1].')
    assert_equal "ok", result["status"]
    formal = EraZeroRenderer.render(result.fetch("semantic_ir"))
    role = result.dig("semantic_ir", "edges").find { |edge| edge["role"] == "target" }
    assert role
    events = formal.dig("performance", "lexical_events").select { |event| event["occurrence_id"] == role["from"] }
    assert events.all? { |event| event["register"] == "high" }
  end
end
