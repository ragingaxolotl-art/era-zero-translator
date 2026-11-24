#!/usr/bin/env ruby
# Surface vocabulary for the existing physical comparison grammar, not new roots.
require_relative 'lib/era_zero_validation'
V = EraZeroValidation
path='lexicon/english_sense_index.yaml'
migration_path='migrations/ordinary_comparatives_2026_11_23.yaml'
review='reviews/ordinary_comparatives_2026_11_23.md'
index=V.load_yaml(path)
before=V.fingerprint(index.fetch('senses'))
preserved=index.fetch('senses').map { |s| s.fetch('sense_id') }
forms={
  'hotter'=>['thermodynamic_temperature','greater_than','thermodynamic temperature','higher','felt warmth, spiciness, attractiveness or figurative intensity'],
  'colder'=>['thermodynamic_temperature','less_than','thermodynamic temperature','lower','felt coldness, emotional distance or figurative tone'],
  'heavier'=>['mass','greater_than','physical mass','greater','weight force, carrying effort, density, severity or figurative importance'],
  'lighter'=>['mass','less_than','physical mass','less','weight force, carrying effort, luminance, color, severity or figurative tone']
}
added=[]
forms.each do |word,(dimension,relation,property,direction,other)|
  definition="The bound bearer's #{property} is strictly #{direction} than that of the bound comparison participant in the selected context. Both ordered participants are required. No numeric measurement, difference magnitude, contextual #{word == 'hotter' ? 'hot' : word == 'colder' ? 'cold' : word == 'heavier' ? 'heavy' : 'light'} threshold or persistence is asserted. Negation scopes this strict comparison and allows equality; it is not the opposite strict comparison. Runtime 0/1/2 remains independent of comparison, time and negation."
  payload={'lemma'=>word,'part_of_speech'=>'adjective','sense_key'=>"physical_#{dimension}_#{relation}_comparative",'route'=>'semantic_ir','definition'=>definition}
  record=payload.merge('sense_id'=>"ENS:#{V.fingerprint(payload)[0,24]}",'display_form'=>word,'surface_forms'=>[word],
    'selection_cues'=>["The cup is #{word} than the plate.","Selected #{property} comparison between two participants"],
    'excluded_readings'=>[other,'Absolute state, numerical difference, degree modifier, superlative, or missing comparison participant'],
    'confidence'=>'high','controlled_input_allowed'=>false,'provenance'=>review)
  old=index['senses'].find { |s| s['sense_id']==record['sense_id'] }
  abort "Existing comparative sense differs: #{word}" if old && old!=record
  index['senses']<<record unless old
  added<<record.fetch('sense_id')
end
index['senses'].sort_by! { |s| [s.fetch('lemma'),s.fetch('sense_key'),s.fetch('sense_id')] }
unless File.exist?(File.join(V::ROOT,migration_path))
  V.write(migration_path,YAML.dump({'date'=>'2026-11-23','status'=>'applied','review'=>review,
    'authority'=>'Author review under the user-directed translator completion goal; not independent linguistic validation.',
    'source'=>{'path'=>path,'before_fingerprint'=>before,'preserved_ids'=>preserved},'added_senses'=>added,
    'atomic_inventory_fingerprint'=>V.fingerprint(V.load_yaml('lexicon/all_atoms.yaml').fetch('atoms')),
    'compound_fingerprint'=>V.fingerprint(V.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries'))}))
end
V.write(path,YAML.dump(index))
puts "Indexed #{added.length} ordinary comparative forms using existing property comparison grammar."
