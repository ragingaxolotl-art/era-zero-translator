require 'minitest/autorun'
require_relative '../tools/lib/era_zero_controlled_english'
require_relative '../tools/lib/era_zero_presentation'

class ControlledRoleReferenceTest < Minitest::Test
  def setup
    @compiler=EraZeroControlledEnglish::Compiler.new
  end

  def test_shared_participant_is_one_occurrence_with_independent_predicate_state
    [0,1,2].each do |state|
      ir=@compiler.compile!(%(ASSERT "active target restoration" [#{state}] ROLE actor "conscious self" [1] ROLE target "distinct material object" [2] ROLE beneficiary REF actor.))
      roles=ir['edges'].select{|e|e['type']=='fills_role'}.to_h{|e|[e['role'],e['from']]}
      assert_equal roles['actor'],roles['beneficiary']
      refute_equal roles['actor'],roles['target']
      assert_equal 3,ir['nodes'].count{|n|n['kind']=='lexical_occurrence'}
      formal=EraZeroRenderer.render(ir)
      assert_equal ir,EraZeroRenderer.decode(formal)
      assert_equal state,formal['performance']['lexical_events'].find{|e|e['occurrence_id']=='n002'}['runtime_tail']['code']
      assert EraZeroPresentation.midi(formal).bytesize>0
      repeated=@compiler.compile!(%(ASSERT "active target restoration" [#{state}] ROLE actor "conscious self" [1] ROLE target "distinct material object" [2] ROLE beneficiary "conscious self" [1].))
      refute_equal ir['utterance_id'],repeated['utterance_id']
      refute_equal EraZeroPresentation.midi(formal),EraZeroPresentation.midi(EraZeroRenderer.render(repeated))
      assert_equal 4,repeated['nodes'].count{|n|n['kind']=='lexical_occurrence'}
    end
  end

  def test_references_are_local_backward_and_explicit
    ['actor','missing','beneficiary'].each do |role|
      result=@compiler.compile(%(ASSERT "active target restoration" [1] ROLE beneficiary REF #{role}.))
      assert_equal 'unknown_role_reference',result.dig('error','code')
      refute result.key?('semantic_ir')
    end
    chain=@compiler.compile!('ASSERT "active target restoration" [1] ROLE actor "conscious self" [1] ROLE beneficiary REF actor ROLE recipient REF beneficiary.')
    assert_equal 1,chain['edges'].select{|e|e['type']=='fills_role'}.map{|e|e['from']}.uniq.length
    duplicate=@compiler.compile('ASSERT "active target restoration" [1] ROLE actor "conscious self" [1] ROLE actor REF actor.')
    assert_equal 'duplicate_role',duplicate.dig('error','code')
  end

  def test_scoped_identity_constraints_receive_the_explicit_reference
    # Structural fixture only: tests the compiler/constraint interface, not vocabulary approval.
    definition=Marshal.load(Marshal.dump(@compiler.instance_variable_get(:@compounds).fetch('CMP:eef9fff8ac6618ce60927f18')))
    definition['binding_constraints']=[{'relation'=>'same_argument','slot_paths'=>[['s-source'],['s-target']]}]
    @compiler.instance_variable_get(:@compounds)[definition['compound_id']]=definition
    ir=@compiler.compile!('ASSERT "active physical load support" [1] ROLE source "distinct material object" [2] ROLE target REF source.')
    bindings=ir['nodes'].find{|n|n['target_type']=='compound'}['compound_bindings']
    assert_equal 1,bindings.map{|b|b['argument_id']}.uniq.length
    result=@compiler.compile('ASSERT "active physical load support" [1] ROLE source "distinct material object" [2] ROLE target "distinct material object" [2].')
    assert_equal 'ambiguous_compound_binding',result.dig('error','code')
    # Change the fixture rule to ensure a forbidden alias is also rejected.
    definition['binding_constraints'][0]['relation']='distinct_arguments'
    result=@compiler.compile('ASSERT "active physical load support" [1] ROLE source "distinct material object" [2] ROLE target REF source.')
    assert_equal 'ambiguous_compound_binding',result.dig('error','code')
  end
end
