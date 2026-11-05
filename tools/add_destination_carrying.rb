#!/usr/bin/env ruby
# Add reviewed dependencies in order without rerunning historical generators.
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
dictionary=V.load_yaml('lexicon/compound_dictionary.yaml')
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
added=[]
definitions=[
 ['ongoing_destination_carrying',5,'ongoing destination-directed physical carrying','MOV:111','q-carry','CMP:7a6749aaf61cd6181e544bd6',
  'An instance of ongoing physical carrying in which that same supported load is undergoing displacement toward the specified destination position during the same carrying event. The supporting conveyance constitutes this approach; unrelated simultaneous approach does not qualify. The destination may be specified by a contextual location associated with a referent. Arrival, receipt, ownership transfer, intention and continued presence are not asserted.',
  ['Carrying and unrelated approach by another load or during another event','Arrival or receipt inferred merely from directed carrying','Recipient or ownership inferred from a destination label']],
 ['completed_destination_carrying',6,'completed physical carrying to a destination','MOV:110','q-path',nil,
  'Completion of one destination-directed physical carrying event: the same load conveyed by the same supporting source reaches the same specified destination position as the culmination of that carrying conveyance. The ongoing carrying and approach are internal phases of this completed event, not separate current assertions. Arrival after the load is released and travels independently is excluded. Receipt, ownership transfer, intention and continued presence after arrival are not asserted.',
  ['A carrying episode that ends short of the destination','Arrival during a separate event or by a different load','Arrival after unsupported flight or independent displacement following release','Receipt, ownership transfer or continued presence inferred from arrival']]
]
definitions.each do |key,code,title,head,nested,dependency,definition,excludes|
 dependency ||= added.first
 meaning={'profile'=>'EZLEX-1','sense_key'=>key,'sound_code'=>code,'added_definition'=>definition,'excludes'=>excludes}
 shared_load=code==5 ? [[nested,'q-support','s-target'],[nested,'s-load'],['s-load']] : [[nested,'s-load'],['s-load']]
 constraints=[{'relation'=>'same_argument','slot_paths'=>shared_load}]
 constraints << {'relation'=>'same_argument','slot_paths'=>[[nested,'s-destination'],['s-destination']]} if code==6
 payload={'architecture_version'=>'1.0','semantic_head'=>'h',
  'nodes'=>[{'node_id'=>nested,'kind'=>'compound_ref','compound_id'=>dependency,'definition_version'=>'1.0.0'},
    {'node_id'=>'s-load','kind'=>'slot','slot_name'=>'moving_load','slot_type'=>'entity'},
    {'node_id'=>'s-destination','kind'=>'slot','slot_name'=>'destination','slot_type'=>'entity'},
    {'node_id'=>'h','kind'=>'root','root_id'=>head}],
  'edges'=>[{'type'=>'qualifies','from'=>nested,'to'=>'h'},{'type'=>'fills_role','from'=>'s-load','to'=>'h','role'=>'actor'},{'type'=>'fills_role','from'=>'s-destination','to'=>'h','role'=>'destination'}],
  'binding_constraints'=>constraints,
  'lexical_constraints'=>['The same-argument constraints bind the exact load throughout the nested carrying and movement.',code==5 ? 'The carrying conveyance is the approach event, not a separate simultaneous occurrence.' : 'The nested approach culminates at this arrival in the same event, with one shared destination.'],
  'conventional_meaning'=>meaning}
 digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}";added<<id
 entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-10-28','display_title'=>title,'english_glosses'=>[title],
  'invariant_definition'=>definition,'boundaries'=>{'includes'=>definition,'excludes'=>excludes.join('; ')},
  'collision_audit'=>"Version-pinned dependency #{dependency} plus #{head} supplies the ingredients; convention #{code} explicitly adds same-event linkage, and the completed convention adds culmination. Neither is asserted to follow from conjunction alone.",
  'confidence'=>'high','approval_record'=>'migrations/destination_carrying_2026_10_28.yaml',
  'approval_basis'=>'Delegated semantic review under the user-directed translator-completion goal; reviews/destination_carrying.md. Author review, not independent validation.',
  'examples'=>{'ordinary'=>code==5 ? 'Ada is carrying the box to the gate (spatial destination reading).' : 'Ada carried the box to the gate (completed spatial destination reading).',
    'technical'=>'One load, one carrier and one carrying event; destination denotes a contextual position, not a recipient.',
    'future_compound'=>'Reuse this spatial foundation before adding receipt or specialized delivery.',
    'counterexample'=>code==5 ? 'Ada carries the box away while another object approaches the gate.' : 'Ada carries the box partway, then throws it through the gate.'},
  'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
 old=dictionary['entries'].find{|e|e['compound_id']==id};abort 'Existing definition differs' if old&&old!=entry
 dictionary['entries']<<entry unless old
 unless reviews['reviews'].any?{|r|r['compound_id']==id}
  candidates=[['explicit_same_event','Reuse the exact prior foundation, share load and destination as applicable, and state the same-event relation audibly.',[9,10,10,9,9,10,8,10],'winner'],
    ['unlinked_conjunction','Conjunction permits different events and cannot establish this carrying culmination.',[8,9,9,2,3,4,4,5],'rejected: event identity missing'],
    ['runtime_as_completion','Using runtime 0 or 2 to express arrival corrupts the independent ternary state.',[1,2,2,1,1,1,2,1],'rejected: runtime semantic loss']].map{|name,reason,scores,decision|{'candidate_id'=>name,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
  candidates.first['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning','binding_constraints')
  reviews['reviews']<<{'compound_id'=>id,'display_title'=>title,'current_choice_reason'=>'reviews/destination_carrying.md; author-scored candidates, not independent semantic validation.','candidates'=>candidates,'recommendation'=>'approve explicit_same_event','confidence'=>'high'}
 end
end
EraZeroCompoundConventions.validate!(dictionary['entries'])
previous=dictionary['entries'].reject{|e|added.include?(e['compound_id'])}.sort_by{|e|e['compound_id']}
migration={'authority'=>'User-directed translator-completion goal','review'=>'reviews/destination_carrying.md','before_dictionary_fingerprint'=>V.fingerprint(previous),'previous_compound_ids'=>previous.map{|e|e['compound_id']},'added_compound_ids'=>added,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false,'new_convention_codes'=>[5,6],'required_followup'=>'Sentence interpretation, exact load/destination binding, nested convention sound contrasts and runtime 0/1/2. Receipt remains separate.'}
dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write('lexicon/compound_dictionary.yaml',YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
V.write('migrations/destination_carrying_2026_10_28.yaml',YAML.dump(migration))
puts added
