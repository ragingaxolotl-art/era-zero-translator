require 'minitest/autorun'
require_relative '../tools/lib/era_zero_validation'
class MatCapacityExampleMigrationTest < Minitest::Test
 V=EraZeroValidation
 def test_exact_editorial_delta_and_unchanged_approved_roots
  atoms=V.load_yaml('lexicon/atoms.yaml').fetch('atoms')
  migration=V.load_yaml('migrations/mat_capacity_example_reconciliation_2026_10_29.yaml')
  assert V.atomic_fingerprint_matches?(atoms,migration.fetch('after_fingerprint'))
  assert V.atomic_fingerprint_matches?(atoms,migration.fetch('before_fingerprint'))
  assert V.atomic_fingerprint_matches?(atoms,V.load_yaml('migrations/min_cross_reference_reconciliation_2026_10_28.yaml').fetch('before_fingerprint'))
  restored=Marshal.load(Marshal.dump(atoms))
  migration.fetch('changes').each do |c|
   assert_equal 'normal_example',c.fetch('field')
   restored.find{|r|r['canonical_id']==c['root_id']}['normal_example']=c.fetch('before')
  end
  assert_equal migration.fetch('before_fingerprint'),V.fingerprint(restored)
  assert_equal V.ids_for_range('MAT:200-222').sort,migration.fetch('changes').map{|c|c['root_id']}.sort
  assert_equal 9,migration.fetch('changes').length
  assert_equal 9,migration['changes'].count{|c|c['field']=='normal_example'}
  approval=V.load_yaml('migrations/MAT_200_222_semantic_approval.yaml')
  approval.fetch('promoted_roots').each do |root|
   row=atoms.find{|a|a['canonical_id']==root['canonical_id']}
   assert_equal root.fetch('invariant_definition'),row.fetch('core_definition')
   assert_equal root.fetch('canonical_title'),row.fetch('title')
   root.fetch('fixed_generated_fields').each{|field,value|assert_equal value,row.fetch(field)}
  end
  inventories=%w[lexicon/atoms.yaml lexicon/all_atoms.yaml lexicon/reviewed_canonical_atoms.yaml spec/canonical_spec.yaml].to_h do |path|
   doc=V.load_yaml(path);[path,path.start_with?('spec/') ? doc.fetch('lexicon').fetch('completed_atoms') : doc.fetch('atoms')]
  end
  inventories['browser']=JSON.parse(File.read(File.join(V::ROOT,'pages/data/index.json'))).fetch('atoms')
  inventories.each do |path,rows|
   migration.fetch('changes').each do |c|
    row=rows.find{|a|a['canonical_id']==c['root_id']}
    assert_equal c.fetch('after'),row.fetch(c.fetch('field')),path
   end
  end
  [->(r){r['core_definition']='scheduled arrival'},->(r){r['normal_example']+=' Queued.'},->(r){r['note_path_semitones'][0]=7},->(r){r['runtime_state_examples']['2']='future tense'}].each do |change|
   mutated=Marshal.load(Marshal.dump(atoms));change.call(mutated.find{|a|a['canonical_id']=='MAT:210'})
   refute V.atomic_fingerprint_matches?(mutated,migration.fetch('before_fingerprint'))
  end
 end
end
