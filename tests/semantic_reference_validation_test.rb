require 'minitest/autorun'
require_relative '../tools/lib/era_zero_semantic_validation'
require_relative '../tools/lib/era_zero_renderer'

class SemanticReferenceValidationTest < Minitest::Test
  def fixture
    name = { 'format' => 'EZNAME-0.1', 'normalized_label' => 'ada', 'phonemes' => ['AA'], 'object_tag' => '' }
    digest = Digest::SHA256.hexdigest("EZNAME-0.1\nada\nAA\n")
    name['name_id'] = "EZNAME:#{digest[0,16]}"
    ir = {'ir_version'=>'1.0','root_clause'=>'c','speech_act'=>'assertion',
      'nodes'=>[{'node_id'=>'c','kind'=>'clause','clause_type'=>'predication'},
        {'node_id'=>'p','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'LIF:011','runtime_state'=>{'code'=>1}},
        {'node_id'=>'a','kind'=>'phonemic_reference','value_type'=>'entity','referent_id'=>name['name_id'],'name'=>name}],
      'edges'=>[{'edge_id'=>'e0','type'=>'centers','from'=>'p','to'=>'c'}, {'edge_id'=>'e1','type'=>'fills_role','from'=>'a','to'=>'p','role'=>'bearer'}],
      'discourse_constraints'=>{}}
    identify(ir)
  end

  def identify(ir)
    payload=ir.slice('ir_version','root_clause','speech_act','nodes','edges','discourse_constraints')
    digest=Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
    ir.merge('utterance_id'=>"UTT:#{digest[0,24]}",'serialization'=>{'canonical_format'=>'EZIR-JSON-1','content_digest'=>digest})
  end

  def test_valid_name_reference
    assert_empty EraZeroSemanticValidation.validate(fixture)
  end

  def test_forged_or_unknown_phonemes
    ['name_id','phonemes'].each do |field|
      ir=fixture
      ir['nodes'][2]['name'][field]=field=='phonemes' ? ['INVALID'] : 'EZNAME:forged'
      assert_includes EraZeroSemanticValidation.validate(identify(ir)), 'invalid_phonemic_name'
    end
  end

  def test_name_is_not_a_runtime_lexeme
    ir=fixture
    ir['nodes'][2]['runtime_state']={'code'=>1}
    assert_includes EraZeroSemanticValidation.validate(identify(ir)), 'invalid_phonemic_reference'
  end

  def test_missing_referent_and_disconnected_name
    ir=fixture
    ir['nodes'][2]['referent_id']=''
    ir['edges'].pop
    errors=EraZeroSemanticValidation.validate(identify(ir))
    assert_includes errors,'invalid_phonemic_reference'
    assert_includes errors,'disconnected_node'
  end

  def test_renderer_enforces_structure_before_sound
    assert_equal 'EZF-1', EraZeroRenderer.render(fixture)['format']
    disconnected=fixture
    disconnected['edges'].pop
    error=assert_raises(EraZeroRenderer::RenderError) { EraZeroRenderer.render(identify(disconnected)) }
    assert_includes error.message,'disconnected_node'
    duplicate=fixture
    duplicate['nodes'] << duplicate['nodes'].last.dup
    error=assert_raises(EraZeroRenderer::RenderError) { EraZeroRenderer.render(identify(duplicate)) }
    assert_includes error.message,'duplicate_node'
    assert_raises(EraZeroRenderer::RenderError) { EraZeroRenderer.render(nil) }
    malformed=fixture
    malformed['nodes'][1]['runtime_state']='active'
    error=assert_raises(EraZeroRenderer::RenderError) { EraZeroRenderer.render(identify(malformed)) }
    assert_includes error.message,'invalid_runtime_state'
  end

  def test_deictic_reference_requires_matching_context_role
    ir=fixture
    ir['nodes'][2]={'node_id'=>'a','kind'=>'deictic_reference','deictic_role'=>'speaker','referent_id'=>'discourse:speaker','value_type'=>'entity'}
    assert_empty EraZeroSemanticValidation.validate(identify(ir))
    ir['nodes'][2]['referent_id']='discourse:addressee'
    assert_includes EraZeroSemanticValidation.validate(identify(ir)),'invalid_deictic_reference'
    ir['nodes'][2]['deictic_role']='she'
    assert_includes EraZeroSemanticValidation.validate(identify(ir)),'invalid_deictic_reference'
  end

  def test_malformed_containers_return_diagnostics
    assert_equal ['invalid_document'],EraZeroSemanticValidation.validate(nil)
    assert_equal ['invalid_nodes'],EraZeroSemanticValidation.validate({'nodes'=>[nil]})
    assert_equal ['invalid_edges'],EraZeroSemanticValidation.validate({'nodes'=>[],'edges'=>[nil]})
  end
end
