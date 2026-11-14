#!/usr/bin/env ruby
# Idempotent reviewed foundation; no historical generator is rerun.
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
file='lexicon/compound_dictionary.yaml';dictionary=V.load_yaml(file)
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
meaning={'profile'=>'EZLEX-1','sense_key'=>'practical_physical_custody','sound_code'=>7,
 'added_definition'=>'An established material relation in which a holder has effective practical control over access to and physical handling of a distinct material object, through an arrangement the holder can operate directly or through a controlled physical intermediary. Mere ability to approach, touch, influence or seize the object does not establish this relation. Control need not be exclusive, lawful, conscious, voluntary, continuously exercised or accompanied by ownership, load bearing, movement or a prior transfer.',
 'excludes'=>['Ownership, permission or entitlement without practical control','Proximity, touch, load support or physical influence alone','Hypothetical ability to seize an object not already under practical control','Legal guardianship, information access or ownership of an abstract asset','Receipt or transfer inferred from a custody state alone']}
payload={'architecture_version'=>'1.0','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'q-load','kind'=>'root','root_id'=>'MAT:010'},{'node_id'=>'s-source','kind'=>'slot','slot_name'=>'custodian','slot_type'=>'entity'},{'node_id'=>'s-target','kind'=>'slot','slot_name'=>'held_object','slot_type'=>'entity'},{'node_id'=>'h','kind'=>'root','root_id'=>'MAT:210'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q-load','to'=>'s-target'},{'type'=>'fills_role','from'=>'s-source','to'=>'h','role'=>'source'},{'type'=>'fills_role','from'=>'s-target','to'=>'h','role'=>'target'}],
 'binding_constraints'=>[{'relation'=>'distinct_arguments','slot_paths'=>[['s-source'],['s-target']]}],
 'lexical_constraints'=>['The custodian and material object are distinct participants.','The established coupling and practical control concern the same holder-to-object relation; the material qualifier applies to the bound target object.','Controlled mediation does not imply ownership of the intermediary or object; control itself must be established rather than merely achievable.'],
 'conventional_meaning'=>meaning}
digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}"
entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-10-29','display_title'=>'practical physical custody','english_glosses'=>['practical physical custody'],
 'invariant_definition'=>meaning['added_definition'],
 'boundaries'=>{'includes'=>'Established practical control of physical access and handling, directly or through a controlled material arrangement; shared custody is permitted.','excludes'=>meaning['excludes'].join('; ')},
 'collision_audit'=>'MAT:210 supplies established material coupling and MAT:010 constrains its target object. Convention code 7 adds effective practical control of access and handling; no root graph alone is claimed to entail that commitment.',
 'confidence'=>'high','approval_record'=>'migrations/physical_custody_2026_10_29.yaml','approval_basis'=>'Delegated semantic approval under the user-directed translator-completion goal; reviews/physical_custody_foundation.md',
 'examples'=>{'ordinary'=>'Ada has physical custody of the box.','technical'=>'A controlled locker can mediate custody without continuous touch or load bearing by the holder.','future_compound'=>'Reuse this exact relation as the before/after state of a custody transfer, preserving object identity.','counterexample'=>'A table bears a box without controlling access; an owner can lack custody; a custodian can lack ownership.'},
 'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
old=dictionary['entries'].find{|e|e['compound_id']==id};abort 'Existing custody definition differs' if old && old!=entry
before=V.fingerprint(dictionary['entries']);dictionary['entries']<<entry unless old
EraZeroCompoundConventions.validate!(dictionary['entries'])
unless reviews['reviews'].any?{|r|r['compound_id']==id}
 candidates=[['explicit_practical_custody','Conventional practical control specializes the established material relation and keeps a distinct object.',[9,10,10,9,9,10,8,10],'winner'],['unmarked_coupling','Heating or illumination can influence an object without custody.',[9,10,10,2,3,5,4,5],'rejected: practical control absent'],['load_support_substitution','A table may bear the load without controlling access; custody may use a controlled enclosure.',[7,9,9,2,3,4,4,5],'rejected: wrong relation']].map{|key,reason,scores,decision|{'candidate_id'=>key,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
 candidates.first['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning','binding_constraints')
 reviews['reviews']<<{'compound_id'=>id,'display_title'=>entry['display_title'],'current_choice_reason'=>'Review in reviews/physical_custody_foundation.md; scores are author judgments, not independent semantic validation.','candidates'=>candidates,'recommendation'=>'approve explicit_practical_custody','confidence'=>'high'}
end
dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write(file,YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
migration='migrations/physical_custody_2026_10_29.yaml'
unless File.exist?(File.join(V::ROOT,migration))
 V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/physical_custody_foundation.md','before_dictionary_fingerprint'=>before,'added_compound_id'=>id,'convention'=>meaning,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false,'required_followup'=>'Ordinary sentence, binding and musical contrast validation. Transfer, receipt and delivery require further explicit event definitions.'}))
end
puts id
