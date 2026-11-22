require 'minitest/autorun'
require_relative '../tools/lib/era_zero_validation'

class InformationVocabularyPinsTest < Minitest::Test
  def test_every_previous_meaning_and_sense_is_preserved
    v = EraZeroValidation
    migration = v.load_yaml('migrations/information_vocabulary_2026_11_22.yaml')
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

  def test_copy_and_recall_use_the_reviewed_dependencies_and_distinct_codes
    v = EraZeroValidation
    entries = v.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries').to_h { |e| [e.fetch('compound_id'), e] }
    added = v.load_yaml('migrations/information_vocabulary_2026_11_22.yaml').fetch('added_compounds')
    {'copy' => [%w[DAT:000 CRE:110],83], 'recall' => [%w[MIN:012 MIN:011 ORI:110],84]}.each do |word, (roots, code)|
      entry = entries.fetch(added.fetch(word))
      assert_equal roots, entry.fetch('nodes').map { |node| node.fetch('root_id') }
      assert_equal code, entry.fetch('conventional_meaning').fetch('sound_code')
    end
  end
end
