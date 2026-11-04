require 'minitest/autorun'
require_relative '../tools/lib/era_zero_packet_evidence'

class PacketEvidenceTest < Minitest::Test
  def test_optional_historical_metadata_is_checked_not_ignored
    required = {'carrier'=>'ba-ma-ma-ma', 'notes'=>[0,0,0,0]}
    optional = {'family'=>'MAT', 'address'=>'000'}
    assert EraZeroPacketEvidence.fixed_fields?(required, required, optional)
    assert EraZeroPacketEvidence.fixed_fields?(required.merge(optional), required, optional)
    [required.merge('family'=>'MOV'), required.merge('notes'=>[0,1,0,0]),
     required.merge('unknown'=>'value'), {'carrier'=>'ba-ma-ma-ma'}].each do |record|
      refute EraZeroPacketEvidence.fixed_fields?(record, required, optional)
    end
  end

  def test_old_and_new_candidate_selection_are_explicit
    keys = %w[recommended_candidate_id recommended_winner]
    assert_equal 'chosen', EraZeroPacketEvidence.field({'recommended_winner'=>'chosen'}, keys)
    assert_equal 'chosen', EraZeroPacketEvidence.field({'recommended_candidate_id'=>'chosen'}, keys)
    assert_equal 'chosen', EraZeroPacketEvidence.field(keys.to_h { |k| [k, 'chosen'] }, keys)
    assert_nil EraZeroPacketEvidence.field({'recommended_candidate_id'=>'chosen', 'recommended_winner'=>'other'}, keys)
    assert_nil EraZeroPacketEvidence.field({'highest_score'=>'chosen'}, keys)
  end

  def test_stress_evidence_does_not_hide_conflicts_or_empty_fields
    keys = %w[analysis rationale reason]
    assert_equal 'Explicit argument', EraZeroPacketEvidence.field({'reason'=>'Explicit argument'}, keys)
    [{}, {'analysis'=>nil}, {'analysis'=>' '}, {'analysis'=>[]}, {'analysis'=>'A','reason'=>'B'}, {'analysis'=>'A','reason'=>nil}].each do |record|
      assert_nil EraZeroPacketEvidence.field(record, keys)
    end
  end
end
