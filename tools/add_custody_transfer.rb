#!/usr/bin/env ruby
# Idempotent reviewed foundation; no historical generator is rerun.
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
file='lexicon/compound_dictionary.yaml';dictionary=V.load_yaml(file)
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
meaning={'profile'=>'EZLEX-1','sense_key'=>'completed_physical_custody_transfer','sound_code'=>9,
 'added_definition'=>'Completion of one reallocation of practical physical custody of the same distinct material object from a source holder to a distinct recipient: the source has custody and the recipient lacks it immediately before the event; at culmination the source lacks that custody and the recipient acquires it. The source custody and recipient acquisition are linked phases of this same reallocation, not unrelated loss and acquisition. Nested source custody describes the pre-state, while nested acquisition describes the culmination transition; neither is an independent speech-time assertion. No ownership change, willing acceptance, permission, displacement, physical carrying, exclusive control by either holder relative to third parties, or persistence afterward is asserted.',
 'excludes'=>['Acquisition without a prior holder','Unrelated loss and acquisition involving the same object','Shared custody retained by the source at culmination','Ownership, permission, motion or willing acceptance inferred from transfer','Different objects at the two custody endpoints']}
payload={'architecture_version'=>'1.0','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'q-prior','kind'=>'compound_ref','compound_id'=>'CMP:0aca609416668978e1527dac','definition_version'=>'1.0.0'},{'node_id'=>'h','kind'=>'compound_ref','compound_id'=>'CMP:c332d2e89b9f6177486fc93b','definition_version'=>'1.0.0'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q-prior','to'=>'h'}],
 'binding_constraints'=>[{'relation'=>'same_argument','slot_paths'=>[['q-prior','s-target'],['h','q-custody','s-target']]},{'relation'=>'distinct_arguments','slot_paths'=>[['q-prior','s-source'],['h','q-custody','s-source']]}],
 'lexical_constraints'=>['Source custody is the pre-state of this reallocation, not current custody asserted outside the event.','The same object passes from source custody to recipient acquisition in one event; source loss at culmination and linked reallocation are explicit conventional commitments.','The inherited holder/object constraints and distinct source/recipient constraint remain in force.'],
 'conventional_meaning'=>meaning}
digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}"
entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-11-04','display_title'=>'completed transfer of physical custody','english_glosses'=>['completed transfer of physical custody'],
 'invariant_definition'=>meaning['added_definition'],
 'boundaries'=>{'includes'=>'A single linked reallocation with one object and distinct source and recipient.','excludes'=>meaning['excludes'].join('; ')},
 'collision_audit'=>'Version-pinned custody supplies the source pre-state and acquisition supplies the recipient transition. Convention 9 adds linked reallocation and source loss. No existing root is redefined as material transfer.',
 'confidence'=>'high','approval_record'=>'migrations/custody_transfer_2026_11_04.yaml','approval_basis'=>'Delegated semantic approval under the user-directed translator-completion goal; reviews/custody_transfer_foundation.md',
 'examples'=>{'ordinary'=>'Ben transferred physical custody of the box to Ada.','technical'=>'One object, distinct source and recipient, linked source loss and recipient acquisition at culmination.','future_compound'=>'Reuse this exact transfer event when specifying a carrying-mediated delivery.','counterexample'=>'Ada gains shared control while Ben retains custody; acquisition occurs but this relinquishing transfer does not.'},
 'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
old=dictionary['entries'].find{|e|e['compound_id']==id};abort 'Existing transfer definition differs' if old && old!=entry
before=V.fingerprint(dictionary['entries']);dictionary['entries']<<entry unless old
EraZeroCompoundConventions.validate!(dictionary['entries'])
unless reviews['reviews'].any?{|r|r['compound_id']==id}
 candidates=[['explicit_linked_reallocation','Reuse exact custody and acquisition, share the object and explicitly link source loss and recipient gain.',[9,10,10,9,9,10,8,10],'winner'],['unlinked_conjunction','Unrelated loss and gain do not establish a sourced reallocation.',[7,9,9,2,3,4,4,5],'rejected: event linkage absent'],['runtime_transition','Runtime 0 and 1 are occurrence endings, not a before/after event operator.',[1,2,2,1,1,1,2,1],'rejected: ternary semantic loss']].map{|key,reason,scores,decision|{'candidate_id'=>key,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
 candidates.first['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning','binding_constraints')
 reviews['reviews']<<{'compound_id'=>id,'display_title'=>entry['display_title'],'current_choice_reason'=>'Review in reviews/custody_transfer_foundation.md; scores are author judgments, not independent semantic validation.','candidates'=>candidates,'recommendation'=>'approve explicit_linked_reallocation','confidence'=>'high'}
end
dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write(file,YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
migration='migrations/custody_transfer_2026_11_04.yaml'
unless File.exist?(File.join(V::ROOT,migration))
 V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/custody_transfer_foundation.md','before_dictionary_fingerprint'=>before,'added_compound_id'=>id,'convention'=>meaning,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false,'required_followup'=>'Validate three participants, linked phases, scoped nested bindings and runtime states; carrying-mediated delivery remains separate.'}))
end
puts id
