require 'minitest/autorun'
require_relative '../tools/lib/era_zero_renderer'
require_relative '../tools/lib/era_zero_semantic_validation'
class QuantityValidationTest < Minitest::Test
  def fixture(id)
    ir = YAML.load_file(File.expand_path('semantic_ir_cases.yaml', __dir__))['valid_cases'].find { |c| c['case_id'] == id }['ir']
    yield ir
    digest = EraZeroRenderer.semantic_digest(ir)
    ir['utterance_id'] = "UTT:#{digest[0,24]}"; ir['serialization']['content_digest'] = digest
    ir
  end
  def test_canonical_measurements
    %w[0 5 -5 0.5 -0.5 10000000000000000000000001].each do |value|
      ir = fixture('measurement') { |f| f['nodes'].find { |n| n['kind'] == 'measurement' }['magnitude'] = value }
      assert_empty EraZeroSemanticValidation.validate(ir), value
    end
    [5, nil, '-0', '01', '1.0', '1e3', '.5', '+1', '0.00', '1' * 1025].each do |value|
      ir = fixture('measurement') { |f| f['nodes'].find { |n| n['kind'] == 'measurement' }['magnitude'] = value }
      assert_includes EraZeroSemanticValidation.validate(ir), 'invalid_quantity'
      assert_raises(EraZeroRenderer::RenderError) { EraZeroRenderer.render(ir) }
    end
  end
  def test_quantifier_shape_and_count
    %w[exact at_least at_most all some none].each do |mode|
      ir = fixture('exact_quantity') do |f|
        n = f['nodes'].find { |n| n['operator'] == 'quantifier' }; n['quantifier'] = mode
        n.delete('value') if %w[all some none].include?(mode)
      end
      assert_empty EraZeroSemanticValidation.validate(ir), mode
    end
    [{'value'=>3},{'value'=>'-1'},{'value'=>'1.5'},{'value'=>'03'},{'quantifier'=>'none'},{'quantifier'=>nil},{'quantifier'=>'range'},{'scope_note'=>'unsounded'}].each do |patch|
      ir = fixture('exact_quantity') { |f| f['nodes'].find { |n| n['operator'] == 'quantifier' }.merge!(patch) }
      assert_includes EraZeroSemanticValidation.validate(ir), 'invalid_quantifier'
      assert_raises(EraZeroRenderer::RenderError) { EraZeroRenderer.render(ir) }
    end
  end
end
