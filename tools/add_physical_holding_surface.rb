#!/usr/bin/env ruby
# Add an exact English surface for an existing reviewed compound. No new sound.
require_relative 'lib/era_zero_validation'
V = EraZeroValidation
dictionary_path = 'lexicon/compound_dictionary.yaml'
index_path = 'lexicon/english_sense_index.yaml'
migration_path = 'migrations/physical_holding_surface_2026_11_22.yaml'
review_path = 'reviews/physical_holding_surface_2026_11_22.md'
compounds = V.load_yaml(dictionary_path).fetch('entries')
index = V.load_yaml(index_path)
holding = compounds.find { |e| e['compound_id'] == 'CMP:834a56d90e31b430990720ff' }
abort 'Missing reviewed holding foundation' unless holding && holding.dig('conventional_meaning','sound_code') == 76
abort 'Missing surface review' unless File.file?(File.join(V::ROOT,review_path))
before = {dictionary_path => compounds, index_path => index.fetch('senses')}.transform_values do |entries|
  {'before_fingerprint'=>V.fingerprint(entries),'preserved_ids'=>entries.map { |e| e['compound_id'] || e['sense_id'] }}
end
payload = {'lemma'=>'hold','part_of_speech'=>'verb','sense_key'=>'maintained_physical_holding_engagement',
  'route'=>'compound','target_id'=>holding.fetch('compound_id'),'definition'=>holding.fetch('invariant_definition')}
sense = payload.merge('sense_id'=>"ENS:#{V.fingerprint(payload)[0,24]}",'display_form'=>'hold',
  'surface_forms'=>%w[hold holds held holding],
  'selection_cues'=>['Nora held the rope.','A clamp physically holds the board.'],
  'excluded_readings'=>holding.fetch('conventional_meaning').fetch('excludes'),
  'confidence'=>'high','controlled_input_allowed'=>false,'provenance'=>review_path)
old = index['senses'].find { |s| s['sense_id'] == sense['sense_id'] }
abort 'Existing surface differs' if old && old != sense
unless old
  index['senses'] << sense
  index['senses'].sort_by! { |s| [s.fetch('lemma'),s.fetch('sense_key'),s.fetch('sense_id')] }
  V.write(index_path,YAML.dump(index))
end
unless File.exist?(File.join(V::ROOT,migration_path))
  before[dictionary_path]['added_ids']=[]
  before[index_path]['added_ids']=[sense.fetch('sense_id')]
  V.write(migration_path,YAML.dump({'date'=>'2026-11-22','status'=>'applied',
    'authority'=>'Author review under user-directed translator completion; no separate approval of each English sense is claimed.',
    'review'=>review_path,'sources'=>before,'reused_compound'=>holding.fetch('compound_id'),
    'sound_code'=>76,'added_sense'=>sense.fetch('sense_id'),'new_roots'=>0,'new_compounds'=>0}))
end
puts "Reused #{holding.fetch('compound_id')} for #{sense.fetch('sense_id')}; no dictionary meaning or sound changed."
