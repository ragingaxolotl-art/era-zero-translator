require 'minitest/autorun'
require_relative '../tools/lib/era_zero_compound_dependencies'
require_relative '../tools/lib/era_zero_validation'
require 'digest'
class CompoundConventionTest < Minitest::Test
  def meaning(code = 0)
    {'profile'=>'EZLEX-1','sense_key'=>"fixture_sense_#{code}",'sound_code'=>code,'added_definition'=>'A test-only conventional distinction, not approved vocabulary.','excludes'=>['Unmarked composition']}
  end
  def test_identity_and_validation
    base={'architecture_version'=>'1.0','semantic_head'=>'h','nodes'=>[],'edges'=>[],'lexical_constraints'=>[]}
    assert_equal base, EraZeroCompoundConventions.semantic_payload(base.merge('english_gloss'=>'editorial'))
    signatures=[0,1,2,6560].map do |code|
      entry=base.merge('conventional_meaning'=>meaning(code))
      assert EraZeroCompoundConventions.validate!([entry])
      assert_equal 11, EraZeroCompoundConventions.pitches(meaning(code),'open').length
      Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(EraZeroCompoundConventions.semantic_payload(entry))))
    end
    assert_equal 4, signatures.uniq.length
    [nil,{},meaning(-1),meaning(6561),meaning('1'),meaning.merge('runtime_state'=>2),meaning.merge('excludes'=>[])].each do |invalid|
      assert_raises(ArgumentError){EraZeroCompoundConventions.validate!([{'conventional_meaning'=>invalid}])}
    end
    assert_raises(ArgumentError){EraZeroCompoundConventions.validate!([{'conventional_meaning'=>meaning},{'conventional_meaning'=>meaning.merge('added_definition'=>'A conflicting conventional meaning under the same code.')}])}
    assert_raises(ArgumentError){EraZeroCompoundConventions.validate!([{'conventional_meaning'=>meaning},{'conventional_meaning'=>meaning.merge('sound_code'=>1)}])}
    assert EraZeroCompoundConventions.validate!([{'conventional_meaning'=>meaning},{'conventional_meaning'=>meaning}])
  end
  def test_single_reference_specialization_requires_added_meaning
    expanded={'nodes'=>[{'kind'=>'root'},{'kind'=>'root'}]}
    wrapper={'nodes'=>[{'kind'=>'compound_ref'}],'conventional_meaning'=>meaning}
    assert EraZeroCompoundConventions.distinct_dictionary_graph?(wrapper,expanded)
    refute EraZeroCompoundConventions.distinct_dictionary_graph?(wrapper.reject{|key,_|key=='conventional_meaning'},expanded)
    refute EraZeroCompoundConventions.distinct_dictionary_graph?(wrapper.merge('nodes'=>[{'kind'=>'root'}]),expanded)
    refute EraZeroCompoundConventions.distinct_dictionary_graph?(wrapper,{'nodes'=>[{'kind'=>'root'}]})
  end

  def test_all_available_sound_codes_are_unique
    openings=(0..6560).map{|code| EraZeroCompoundConventions.pitches(meaning(code),'open')}
    assert_equal 6561, openings.uniq.length
    assert openings.all?{|path| path[2,8].all?{|pitch| [0,1,-1].include?(pitch)}}
  end
end
