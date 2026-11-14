#!/usr/bin/env ruby
# Idempotent reviewed foundation; no historical generator is rerun.
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
file='lexicon/compound_dictionary.yaml';dictionary=V.load_yaml(file)
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
meaning={'profile'=>'EZLEX-1','sense_key'=>'active_physical_load_support','sound_code'=>3,
 'added_definition'=>'The same material source bears at least part of the distinct material target load through physical influence that resists displacement under an applied force. This load-bearing support may be contact-mediated or field-mediated, need not bear the entire load, and does not require rest, movement, intention or consciousness.',
 'excludes'=>['Physical influence without load-bearing support','Emotional, evidential, financial or computational support','Carrying or transport inferred from support alone','Grasping or holding without the load-bearing commitment']}
payload={'architecture_version'=>'1.0','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'q-load','kind'=>'root','root_id'=>'MAT:010'},{'node_id'=>'s-source','kind'=>'slot','slot_name'=>'supporter','slot_type'=>'entity'},{'node_id'=>'s-target','kind'=>'slot','slot_name'=>'load','slot_type'=>'entity'},{'node_id'=>'h','kind'=>'root','root_id'=>'MAT:211'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q-load','to'=>'s-target'},{'type'=>'fills_role','from'=>'s-source','to'=>'h','role'=>'source'},{'type'=>'fills_role','from'=>'s-target','to'=>'h','role'=>'target'}],
 'lexical_constraints'=>['The supporting source and material load are distinct participants.','The physical influence and load-bearing commitment concern the same source-to-target relation; the material qualifier applies to the bound target load.'],
 'conventional_meaning'=>meaning}
digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}"
entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-10-28','display_title'=>'active physical load support','english_glosses'=>['active physical load support'],
 'invariant_definition'=>meaning['added_definition'],
 'boundaries'=>{'includes'=>'A person, structure or device physically bearing all or part of a distinct material load, through contact or a field.','excludes'=>meaning['excludes'].join('; ')},
 'collision_audit'=>'MAT:211 supplies physical influence and MAT:010 constrains the bound load. Neither entails load bearing. Convention code 3 contributes that additional commitment without changing either root.',
 'confidence'=>'high','approval_record'=>'migrations/physical_support_2026_10_28.yaml','approval_basis'=>'Delegated semantic approval under the user-directed translator-completion goal; reviews/physical_support_foundation.md',
 'examples'=>{'ordinary'=>'Ada is physically supporting the box.','technical'=>'The supporting source bears part of the target load through physical influence resisting displacement under an applied force.','future_compound'=>'Reuse the exact versioned support relation for carrying, with explicit movement and shared participant constraints.','counterexample'=>'A lamp heats a box without bearing its load; a shelf supports a box without transporting it.'},
 'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
old=dictionary['entries'].find{|e|e['compound_id']==id};abort 'Existing support definition differs' if old && old!=entry
before=V.fingerprint(dictionary['entries']);dictionary['entries']<<entry unless old
EraZeroCompoundConventions.validate!(dictionary['entries'])
unless reviews['reviews'].any?{|r|r['compound_id']==id}
 candidates=[['explicit_load_support','Bind the same source and material load; explicitly mark the extra load-bearing commitment.',[9,10,10,9,9,10,8,10],'winner'],['unmarked_coupling','Physical influence alone includes heating and other non-supporting interactions.',[9,10,10,2,3,5,4,5],'rejected: load bearing absent'],['movement_substitution','Movement can be unsupported; support can occur without movement.',[5,5,6,2,3,4,3,4],'rejected: wrong invariant']].map{|key,reason,scores,decision|{'candidate_id'=>key,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
 candidates.first['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning')
 reviews['reviews']<<{'compound_id'=>id,'display_title'=>entry['display_title'],'current_choice_reason'=>'Review in reviews/physical_support_foundation.md; scores are author judgments, not independent semantic validation.','candidates'=>candidates,'recommendation'=>'approve explicit_load_support','confidence'=>'high'}
end
dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write(file,YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
migration='migrations/physical_support_2026_10_28.yaml'
unless File.exist?(File.join(V::ROOT,migration))
 V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/physical_support_foundation.md','before_dictionary_fingerprint'=>before,'added_compound_id'=>id,'convention'=>meaning,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false,'required_followup'=>'Ordinary sentence and musical contrast validation; carrying still requires explicit transport and participant identity constraints.'}))
end
puts id
