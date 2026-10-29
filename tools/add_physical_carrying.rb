#!/usr/bin/env ruby
# Idempotent reviewed foundation; no historical generator is rerun.
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
file='lexicon/compound_dictionary.yaml';dictionary=V.load_yaml(file)
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
meaning={'profile'=>'EZLEX-1','sense_key'=>'ongoing_physical_carrying','sound_code'=>4,
 'added_definition'=>'A material source conveys the same distinct material load that it physically supports, relative to the contextually relevant movement frame during the same ongoing interval. The load is borne upon, within, or suspended from a moving supporting part or field maintained by the source; that load-bearing engagement is the means of conveyance. The whole source need not translate, as with a conveyor belt. No intention, destination or recipient is asserted.',
 'excludes'=>['Stationary support without conveyance','Support and unrelated simultaneous movement','Pushing or dragging a load across an independently supporting surface without bearing it upon, within or suspended from the carrier','Throwing or falling after support ends','Abstract carrying of information, responsibility or disease']}
payload={'architecture_version'=>'1.0','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'q-support','kind'=>'compound_ref','compound_id'=>'CMP:eef9fff8ac6618ce60927f18','definition_version'=>'1.0.0'},{'node_id'=>'s-load','kind'=>'slot','slot_name'=>'moving_load','slot_type'=>'entity'},{'node_id'=>'h','kind'=>'root','root_id'=>'MOV:121'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q-support','to'=>'h'},{'type'=>'fills_role','from'=>'s-load','to'=>'h','role'=>'actor'}],
 'binding_constraints'=>[{'relation'=>'same_argument','slot_paths'=>[['q-support','s-target'],['s-load']]},{'relation'=>'distinct_arguments','slot_paths'=>[['q-support','s-source'],['q-support','s-target']]}],
 'lexical_constraints'=>['The supported load is exactly the moving participant, distinct from its carrier.','Support and conveyance concern the same ongoing interval and the load-bearing engagement is the means of conveyance.'],
 'conventional_meaning'=>meaning}
digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}"
entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-10-28','display_title'=>'ongoing physical carrying','english_glosses'=>['ongoing physical carrying'],
 'invariant_definition'=>meaning['added_definition'],
 'boundaries'=>{'includes'=>'A person, vehicle, tray or conveyor conveying a distinct material load borne by its moving support.','excludes'=>meaning['excludes'].join('; ')},
 'collision_audit'=>'Exact support version 1.0.0 supplies load bearing; MOV:121 supplies shared-frame movement. Neither entails conveyance by that support. Convention code 4 adds the transport linkage and explicit participant constraints.',
 'confidence'=>'high','approval_record'=>'migrations/physical_carrying_2026_10_28.yaml','approval_basis'=>'Delegated semantic approval under the user-directed translator-completion goal; reviews/physical_carrying.md',
 'examples'=>{'ordinary'=>'Ada is carrying the box.','technical'=>'The supported target and moving actor are the same load, conveyed by its carrier during the same interval.','future_compound'=>'Reuse this exact transport relation before adding destinations, recipients or manner.','counterexample'=>'A shelf supports a stationary box; a person pushes a box across a floor that bears its load.'},
 'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
old=dictionary['entries'].find{|e|e['compound_id']==id};abort 'Existing support definition differs' if old && old!=entry
before=V.fingerprint(dictionary['entries']);dictionary['entries']<<entry unless old
EraZeroCompoundConventions.validate!(dictionary['entries'])
unless reviews['reviews'].any?{|r|r['compound_id']==id}
 candidates=[['explicit_supported_conveyance','Reuse support first, bind its load to the mover, and mark conveyance by that supporting engagement.',[9,10,10,9,9,10,8,10],'winner'],['mere_conjunction','Support plus simultaneous movement does not entail conveyance by that support.',[9,10,10,2,3,5,4,5],'rejected: conveyance linkage absent'],['unshared_mover','A carrier can support one object while a different object moves.',[5,5,6,2,3,4,3,4],'rejected: wrong invariant']].map{|key,reason,scores,decision|{'candidate_id'=>key,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
 candidates.first['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning','binding_constraints')
 reviews['reviews']<<{'compound_id'=>id,'display_title'=>entry['display_title'],'current_choice_reason'=>'Review in reviews/physical_carrying.md; scores are author judgments, not independent semantic validation.','candidates'=>candidates,'recommendation'=>'approve explicit_supported_conveyance','confidence'=>'high'}
end
dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write(file,YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
migration='migrations/physical_carrying_2026_10_28.yaml'
unless File.exist?(File.join(V::ROOT,migration))
 V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/physical_carrying.md','before_dictionary_fingerprint'=>before,'added_compound_id'=>id,'convention'=>meaning,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false,'required_followup'=>'Ordinary sentence, runtime 0/1/2, participant-identity and musical contrast validation. Destination and manner extensions remain separate.'}))
end
puts id
