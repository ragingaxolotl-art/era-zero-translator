require 'minitest/autorun'
require_relative '../tools/lib/era_zero_validation'
class ContextualWidthPinsTest < Minitest::Test
  def test_existing_meanings_and_norm_codes_are_preserved
    v=EraZeroValidation;m=v.load_yaml('migrations/contextual_adjective_surfaces_2026_11_22.yaml')
    source=m.fetch('source');rows=v.load_yaml(source.fetch('path')).fetch('senses')
    old=rows.select { |r| source.fetch('preserved_ids').include?(r.fetch('sense_id')) }
    assert_equal source.fetch('preserved_ids').sort,old.map { |r| r.fetch('sense_id') }.sort
    assert_equal source.fetch('before_fingerprint'),v.fingerprint(old)
    assert_equal m.fetch('compound_fingerprint'),v.fingerprint(v.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries'))
    norms=v.load_yaml('spec/contextual_scalar_standard_1.0.yaml').fetch('norms')
    m.fetch('preserved_norms').each { |name,value| assert_equal value,norms.fetch(name) }
    m.fetch('new_norms').each { |name,value| assert_equal value,norms.fetch(name) }
    assert_equal 10,m.fetch('added_senses').length
    m.fetch('added_senses').each do |id|
      row=rows.find { |r| r['sense_id']==id };assert_equal 'semantic_ir',row['route'];refute row['controlled_input_allowed'];refute row.key?('target_id')
    end
  end
end
