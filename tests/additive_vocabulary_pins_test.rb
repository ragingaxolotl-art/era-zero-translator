require 'minitest/autorun'
require_relative '../tools/lib/era_zero_validation'
class AdditiveVocabularyPinsTest < Minitest::Test
  def test_recorded_baselines_and_additions_preserve_exact_meanings
    v=EraZeroValidation
    %w[migrations/additive_vocabulary_source_pins_2026_11_04.yaml migrations/running_vocabulary_source_pins_2026_11_04.yaml].each do |migration|
    m=v.load_yaml(migration)
    m.fetch('sources').each do |path,source|
      key=path.include?('compound_dictionary') ? 'entries' : 'senses'
      id=key=='entries' ? 'compound_id' : 'sense_id'
      current=v.load_yaml(path).fetch(key)
      prior=current.select{|e|source.fetch('preserved_ids').include?(e.fetch(id))}
      assert_equal source['preserved_ids'].sort,prior.map{|e|e[id]}.sort
      assert_equal source['before_fingerprint'],v.fingerprint(prior)
      snapshot=current.select{|e|(source['preserved_ids']+source['added_ids']).include?(e[id])}
      assert_equal source['after_fingerprint'],v.fingerprint(snapshot)
      assert_equal source['added_ids'].sort,(snapshot.map{|e|e[id]}-source['preserved_ids']).sort
      refute_equal source['before_fingerprint'],v.fingerprint(prior.drop(1))
      altered=Marshal.load(Marshal.dump(prior));altered.first['definition_version']='corrupted'
      refute_equal source['before_fingerprint'],v.fingerprint(altered)
    end
    end
  end
end
