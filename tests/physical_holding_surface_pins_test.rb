require 'minitest/autorun'
require_relative '../tools/lib/era_zero_validation'
class PhysicalHoldingSurfacePinsTest < Minitest::Test
  def test_no_previous_meaning_or_sound_is_changed
    v=EraZeroValidation;m=v.load_yaml('migrations/physical_holding_surface_2026_11_22.yaml')
    m.fetch('sources').each do |path,source|
      dictionary=path.include?('compound_dictionary');id=dictionary ? 'compound_id' : 'sense_id'
      rows=v.load_yaml(path).fetch(dictionary ? 'entries' : 'senses')
      old=rows.select { |r| source.fetch('preserved_ids').include?(r.fetch(id)) }
      assert_equal source.fetch('preserved_ids').sort,old.map { |r| r.fetch(id) }.sort
      assert_equal source.fetch('before_fingerprint'),v.fingerprint(old)
    end
    compound=v.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries').find { |e| e['compound_id']==m.fetch('reused_compound') }
    sense=v.load_yaml('lexicon/english_sense_index.yaml').fetch('senses').find { |e| e['sense_id']==m.fetch('added_sense') }
    assert_equal compound.fetch('invariant_definition'),sense.fetch('definition')
    assert_equal 76,compound.dig('conventional_meaning','sound_code')
    assert_equal [],m.dig('sources','lexicon/compound_dictionary.yaml','added_ids')
    assert_equal %w[hold holds held holding],sense.fetch('surface_forms')
  end
end
