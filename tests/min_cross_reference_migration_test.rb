require 'minitest/autorun'
require_relative '../tools/lib/era_zero_validation'
class MinCrossReferenceMigrationTest < Minitest::Test
  V = EraZeroValidation
  def test_only_documented_editorial_delta_matches_historical_authority
    atoms=V.load_yaml('lexicon/atoms.yaml').fetch('atoms')
    migration=V.load_yaml('migrations/min_cross_reference_reconciliation_2026_10_28.yaml')
    baseline=migration.fetch('before_fingerprint')
    assert V.atomic_fingerprint_matches?(atoms,baseline)
    assert V.atomic_fingerprint_matches?(atoms,migration.fetch('after_fingerprint'))
    [
      ->(rows){rows.find{|r|r['canonical_id']=='MIN:001'}['core_definition']='seeing'},
      ->(rows){rows.find{|r|r['canonical_id']=='MIN:001'}['distinctions_and_exclusions'] << 'extra meaning'},
      ->(rows){rows.first['formal_carrier']='changed'},
      ->(rows){rows.pop}
    ].each do |mutation|
      changed=Marshal.load(Marshal.dump(atoms));mutation.call(changed)
      refute V.atomic_fingerprint_matches?(changed,baseline)
    end
    refute V.atomic_fingerprint_matches?(atoms,'unrelated historical revision')
    index=JSON.parse(File.read(File.join(V::ROOT,'pages/data/index.json')))
    browser=index.fetch('atoms').to_h{|r|[r['canonical_id'],r]}
    atoms.select{|r|migration['root_ids'].include?(r['canonical_id'])}.each do |row|
      assert_equal row['distinctions_and_exclusions'],browser.fetch(row['canonical_id'])['distinctions_and_exclusions']
      migration['replacements'].each do |old,corrected|
        refute_includes row['distinctions_and_exclusions'],old
        assert_includes row['distinctions_and_exclusions'],corrected
      end
    end
  end
end
