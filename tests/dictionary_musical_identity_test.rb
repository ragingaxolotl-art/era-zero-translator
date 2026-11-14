require 'minitest/autorun'
require_relative '../tools/lib/era_zero_musical_identity'

class DictionaryMusicalIdentityTest < Minitest::Test
  def ir_for(id, state = 1)
    ir = { 'ir_version' => '1.0', 'root_clause' => 'c', 'speech_act' => 'assertion',
      'nodes' => [{ 'node_id' => 'c', 'kind' => 'clause', 'clause_type' => 'predication' },
                  { 'node_id' => 'p', 'kind' => 'lexical_occurrence', 'target_type' => 'compound', 'target_id' => id, 'runtime_state' => { 'code' => state } }],
      'edges' => [{ 'edge_id' => 'e0', 'type' => 'centers', 'from' => 'p', 'to' => 'c' }], 'discourse_constraints' => {} }
    digest = EraZeroRenderer.semantic_digest(ir)
    ir.merge('utterance_id' => "UTT:#{digest[0,24]}", 'serialization' => { 'content_digest' => digest })
  end

  def test_different_dictionary_ids_and_definitions_do_not_guarantee_different_music
    atoms, authority = EraZeroRenderer.load_authority
    original = authority.values.find { |entry| entry['display_title'] == 'physical tool' }
    alternate = Marshal.load(Marshal.dump(original))
    alternate['compound_id'] = 'test-conventional-sense'
    alternate['invariant_definition'] = 'A hypothetical specialized meaning, for collision testing only.'
    entries = authority.merge(alternate['compound_id'] => alternate)
    EraZeroRenderer.stub(:load_authority, [atoms, entries]) do
      originals = [original, alternate].map { |entry| EraZeroRenderer.render(ir_for(entry['compound_id'])) }
      refute_equal originals.first['formal_id'], originals.last['formal_id']
      records = originals.each_with_index.map { |formal, index| { 'identity' => index.to_s, 'midi_sha256' => EraZeroMusicalIdentity.signature(formal) } }
      assert_equal records.first['midi_sha256'], records.last['midi_sha256']
      assert_equal ['0', '1'], EraZeroMusicalIdentity.collisions(records).first['identities']
      assert_empty EraZeroMusicalIdentity.collisions([records.first, records.first])
      different_state = EraZeroRenderer.render(ir_for(original['compound_id'], 0))
      refute_equal records.first['midi_sha256'], EraZeroMusicalIdentity.signature(different_state)
    end
  end
end
