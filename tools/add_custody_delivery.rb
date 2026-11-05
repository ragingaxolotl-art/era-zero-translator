#!/usr/bin/env ruby
# Idempotent reviewed foundation; no historical generator is rerun.
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
file='lexicon/compound_dictionary.yaml';dictionary=V.load_yaml(file)
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
meaning={'profile'=>'EZLEX-1','sense_key'=>'completed_carrying_custody_delivery','sound_code'=>10,
 'added_definition'=>'Completion of one carrying-mediated custody delivery: the carrier conveys the same supported material load to the contextual position of the recipient, and that carrying arrival culminates in the linked transfer of practical physical custody of that load from the carrier to that recipient. The carrier is the transfer source, the load is the transferred object and the destination referent is the recipient. The nested carrying arrival and custody transfer are phases of this one delivery, not independent events. The source loses custody as the recipient acquires it at culmination. Ownership, willing acceptance, permission, exclusivity against third parties and persistence afterward are unspecified.',
 'excludes'=>['Spatial arrival while the carrier retains custody','Custody transfer without the specified supporting conveyance and arrival','Carrying arrival and an unrelated later handover','A different carrier, object or recipient across the nested events','Ownership, permission or willing acceptance inferred from delivery']}
payload={'architecture_version'=>'1.0','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'q-arrival','kind'=>'compound_ref','compound_id'=>'CMP:74d98d19808f74d0b8196951','definition_version'=>'1.0.0'},{'node_id'=>'h','kind'=>'compound_ref','compound_id'=>'CMP:e3075c904daf1c647969fef6','definition_version'=>'1.0.0'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q-arrival','to'=>'h'}],
 'binding_constraints'=>[
  {'relation'=>'same_argument','slot_paths'=>[['q-arrival','q-path','q-carry','q-support','s-source'],['h','q-prior','s-source']]},
  {'relation'=>'same_argument','slot_paths'=>[['q-arrival','s-load'],['h','q-prior','s-target']]},
  {'relation'=>'same_argument','slot_paths'=>[['q-arrival','s-destination'],['h','h','q-custody','s-source']]}],
 'lexical_constraints'=>['The same carrier is the source of the same-load custody transfer.','The destination referent identifies the recipient and its contextual position, not a separate unbound person.','Carrying arrival culminates in custody transfer within this one event; nested event commitments remain inside outer grammar scope.'],
 'conventional_meaning'=>meaning}
digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}"
entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-11-04','display_title'=>'completed carrying-mediated custody delivery','english_glosses'=>['completed carrying-mediated custody delivery'],
 'invariant_definition'=>meaning['added_definition'],
 'boundaries'=>{'includes'=>'A single supporting conveyance whose arrival culminates in transfer to the destination recipient.','excludes'=>meaning['excludes'].join('; ')},
 'collision_audit'=>'Exact carrying-to-arrival and custody-transfer versions supply the event ingredients. Convention 10 adds the same-event culmination and three explicit participant equalities. Mere conjunction would not entail delivery.',
 'confidence'=>'high','approval_record'=>'migrations/custody_delivery_2026_11_04.yaml','approval_basis'=>'Delegated semantic approval under the user-directed translator-completion goal; reviews/custody_delivery_foundation.md',
 'examples'=>{'ordinary'=>'Ben carried the box to Ada, with the explicitly selected custody-delivery reading.','technical'=>'The carrier, load and recipient are shared across arrival and custody transfer in one culmination.','future_compound'=>'Reuse this delivery before specializing route, service or acceptance conditions.','counterexample'=>'The box arrives beside Ada while Ben retains custody.'},
 'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
old=dictionary['entries'].find{|e|e['compound_id']==id};abort 'Existing delivery definition differs' if old && old!=entry
before=V.fingerprint(dictionary['entries']);dictionary['entries']<<entry unless old
EraZeroCompoundConventions.validate!(dictionary['entries'])
unless reviews['reviews'].any?{|r|r['compound_id']==id}
 candidates=[['explicit_carrying_transfer_culmination','Reuse exact carrying arrival and custody transfer, link their culmination and share all three participants.',[9,10,10,9,9,10,8,10],'winner'],['unlinked_conjunction','Unrelated arrival and handover do not establish this carrying-mediated delivery.',[7,9,9,2,3,4,4,5],'rejected: event linkage absent'],['runtime_transition','Runtime 0 and 1 are occurrence endings, not a before/after event operator.',[1,2,2,1,1,1,2,1],'rejected: ternary semantic loss']].map{|key,reason,scores,decision|{'candidate_id'=>key,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
 candidates.first['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning','binding_constraints')
 reviews['reviews']<<{'compound_id'=>id,'display_title'=>entry['display_title'],'current_choice_reason'=>'Review in reviews/custody_delivery_foundation.md; scores are author judgments, not independent semantic validation.','candidates'=>candidates,'recommendation'=>'approve explicit_carrying_transfer_culmination','confidence'=>'high'}
end
dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write(file,YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
migration='migrations/custody_delivery_2026_11_04.yaml'
unless File.exist?(File.join(V::ROOT,migration))
 V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/custody_delivery_foundation.md','before_dictionary_fingerprint'=>before,'added_compound_id'=>id,'convention'=>meaning,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false,'required_followup'=>'Validate participant equality, event culmination, scope and runtime states; broader delivery senses remain separate.'}))
end
puts id
