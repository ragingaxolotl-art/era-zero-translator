#!/usr/bin/env ruby
# Index the selected physical senses; these need comparison grammar, not atoms.
require_relative 'lib/era_zero_validation'
V = EraZeroValidation
index_path='lexicon/english_sense_index.yaml'
migration_path='migrations/contextual_adjective_surfaces_2026_11_22.yaml'
review_path='reviews/contextual_width_2026_11_22.md'
profile=V.load_yaml('spec/contextual_scalar_standard_1.0.yaml')
index=V.load_yaml(index_path)
before=V.fingerprint(index.fetch('senses'));previous=index.fetch('senses').map { |s| s.fetch('sense_id') }
dimensions={
  'thermodynamic_temperature'=>['thermodynamic temperature',['felt warmth','spiciness','emotional tone']],
  'mass'=>['physical mass',['weight force','carrying effort','size','brightness']],
  'luminance'=>['photometric surface luminance in the contextual viewing direction',['perceived brightness','glare','color','intelligence']],
  'surface_texture'=>['physical surface irregularity in the contextually selected surface region and at the selected scale',['tactile experience','damage','hardness','friction','figurative difficulty']],
  'physical_width'=>['lateral physical extent along a contextually selected transverse axis and section',['opening clearance','passability','capacity','area','height','length','thickness','apparent size','figurative breadth']]
}
added=[]
profile.fetch('norms').each do |word,norm|
  property,exclusions=dimensions.fetch(norm.fetch('dimension'))
  relation=norm.fetch('relation')=='greater_than' ? 'above' : 'below'
  definition="The material bearer's #{property} is #{relation} the local contextual #{word} standard. The selected physical reading requires a bound bearer and an explicit comparison interpretation. No numerical cutoff, measured value, universal threshold or equality with another occurrence's standard is asserted. The opposite adjective may use a different standard; grammatical negation and runtime 0/1/2 remain separate."
  payload={'lemma'=>word,'part_of_speech'=>'adjective','sense_key'=>"contextual_#{norm.fetch('dimension')}_#{word}",'route'=>'semantic_ir','definition'=>definition}
  record=payload.merge('sense_id'=>"ENS:#{V.fingerprint(payload)[0,24]}",'display_form'=>word,'surface_forms'=>[word],
    'selection_cues'=>["The object is #{word}.","Selected physical #{norm.fetch('dimension')} under a local contextual standard"],
    'excluded_readings'=>exclusions+['Numerical measurements, entity-to-entity comparisons, or other added details without their own grammar'],
    'confidence'=>'high','controlled_input_allowed'=>false,'provenance'=>review_path)
  old=index['senses'].find { |s| s['sense_id']==record['sense_id'] }
  abort "Existing sense differs: #{word}" if old && old!=record
  index['senses']<<record unless old
  added<<record.fetch('sense_id')
end
index['senses'].sort_by! { |s| [s.fetch('lemma'),s.fetch('sense_key'),s.fetch('sense_id')] }
V.write(index_path,YAML.dump(index))
unless File.exist?(File.join(V::ROOT,migration_path))
  V.write(migration_path,YAML.dump({'date'=>'2026-11-22','status'=>'applied','review'=>review_path,
    'authority'=>'Author review under user-directed translator completion; no new roots or compounds.',
    'source'=>{'path'=>index_path,'before_fingerprint'=>before,'preserved_ids'=>previous},'added_senses'=>added,
    'preserved_norms'=>profile.fetch('norms').reject { |name,_| %w[wide narrow].include?(name) },
    'new_norms'=>profile.fetch('norms').select { |name,_| %w[wide narrow].include?(name) },
    'compound_fingerprint'=>V.fingerprint(V.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries'))}))
end
puts "Indexed #{added.length} contextual physical adjective routes, reusing eight existing norms and adding wide/narrow."
