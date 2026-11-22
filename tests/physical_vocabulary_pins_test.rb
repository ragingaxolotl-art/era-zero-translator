require 'minitest/autorun'
require_relative '../tools/lib/era_zero_validation'

class PhysicalVocabularyPinsTest < Minitest::Test
  def test_original_meanings_and_senses_are_preserved
    v = EraZeroValidation
    migration = v.load_yaml('migrations/physical_vocabulary_2026_11_22.yaml')
    migration.fetch('sources').each do |path, source|
      dictionary = path.include?('compound_dictionary')
      id = dictionary ? 'compound_id' : 'sense_id'
      entries = v.load_yaml(path).fetch(dictionary ? 'entries' : 'senses')
      previous = entries.select { |e| source.fetch('preserved_ids').include?(e.fetch(id)) }
      assert_equal source.fetch('preserved_ids').sort, previous.map { |e| e.fetch(id) }.sort
      assert_equal source.fetch('before_fingerprint'), v.fingerprint(previous)
      assert source.fetch('added_ids').all? { |added| entries.any? { |e| e.fetch(id) == added } }
    end
  end

  def test_drop_reuses_release_and_fall_and_content_properties_share_the_foundation
    v = EraZeroValidation
    entries = v.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries').to_h { |e| [e.fetch('compound_id'), e] }
    added = v.load_yaml('migrations/physical_vocabulary_2026_11_22.yaml').fetch('added_compounds')
    dependencies = lambda { |word| entries.fetch(added.fetch(word)).fetch('nodes').map { |n| n['compound_id'] }.compact }
    assert_equal [added.fetch('release'), added.fetch('fall')], dependencies.call('drop')
    assert_includes dependencies.call('release'), added.fetch('physical holding foundation')
    %w[empty full].each { |word| assert_equal [added.fetch('physical content capacity foundation')], dependencies.call(word) }
    assert_equal 8, added.values.uniq.length
    assert_equal (75..82).to_a, added.values.map { |id| entries.fetch(id).fetch('conventional_meaning').fetch('sound_code') }
  end
end
