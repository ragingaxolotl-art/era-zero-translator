#!/usr/bin/env ruby
# Idempotent reviewed foundation; no historical generator is rerun.
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
file='lexicon/compound_dictionary.yaml';dictionary=V.load_yaml(file)
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
meaning={'profile'=>'EZLEX-1','sense_key'=>'completed_physical_custody_acquisition','sound_code'=>8,
 'added_definition'=>'Completion of one bounded transition in which the specified practical physical custody relation comes to obtain: the same holder lacks that control of the same distinct material object immediately before the transition and has it at culmination. The actualized referent is this holder-object custody relation, not the material object. The nested custody relation describes the culmination state, not an independent assertion of custody at speech time. No prior custodian, sourced transfer, loss of another holder\'s control, ownership, willingness, displacement, creation of the object or persistence after culmination is asserted.',
 'excludes'=>['Already having custody without a transition into it','Creation or movement of the material object inferred from acquisition','Ownership, permission or legal custody without practical physical custody','A prior holder, handover, causal mechanism or relinquishment inferred from acquisition','Continued custody after culmination inferred from completion']}
payload={'architecture_version'=>'1.0','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'q-custody','kind'=>'compound_ref','compound_id'=>'CMP:0aca609416668978e1527dac','definition_version'=>'1.0.0'},{'node_id'=>'h','kind'=>'root','root_id'=>'ORI:110'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q-custody','to'=>'h'}],
 'lexical_constraints'=>['The exact bound holder-object custody relation is the distinct referent actualized by this transition.','The nested custody state belongs to the culmination of this same acquisition; it does not assert current custody outside the event scope.','The inherited holder/object distinctness constraint remains in force.'],
 'conventional_meaning'=>meaning}
digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}"
entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-11-04','display_title'=>'completed acquisition of physical custody','english_glosses'=>['completed acquisition of physical custody'],
 'invariant_definition'=>meaning['added_definition'],
 'boundaries'=>{'includes'=>'A bounded transition from lacking to having the specified custody relation, with the same holder and object.','excludes'=>meaning['excludes'].join('; ')},
 'collision_audit'=>'The version-pinned custody relation supplies the culmination state; ORI:110 supplies distinct actualization. Convention 8 identifies the actualized referent as that relation and binds its pre/post transition. The object is not newly created, and conjunction alone does not supply the event linkage.',
 'confidence'=>'high','approval_record'=>'migrations/custody_acquisition_2026_11_04.yaml','approval_basis'=>'Delegated semantic approval under the user-directed translator-completion goal; reviews/custody_acquisition_foundation.md',
 'examples'=>{'ordinary'=>'Ada acquired physical custody of the box.','technical'=>'The same custody relation is absent immediately before this transition and obtains at its culmination; later persistence is unspecified.','future_compound'=>'Reuse this exact acquisition event before specifying a source holder and transfer mechanism.','counterexample'=>'Ada has held the box throughout; no acquisition occurs in the described interval.'},
 'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
old=dictionary['entries'].find{|e|e['compound_id']==id};abort 'Existing acquisition definition differs' if old && old!=entry
before=V.fingerprint(dictionary['entries']);dictionary['entries']<<entry unless old
EraZeroCompoundConventions.validate!(dictionary['entries'])
unless reviews['reviews'].any?{|r|r['compound_id']==id}
 candidates=[['explicit_relation_actualization','Actualize the exact custody relation at one culmination, with an explicit pre-state and stable participants.',[9,10,10,9,9,10,8,10],'winner'],['spatial_arrival','Arrival beside a person does not establish their practical control.',[7,9,9,2,3,4,4,5],'rejected: acquisition absent'],['runtime_transition','Runtime 0 and 1 are occurrence endings, not a before/after event operator.',[1,2,2,1,1,1,2,1],'rejected: ternary semantic loss']].map{|key,reason,scores,decision|{'candidate_id'=>key,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
 candidates.first['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning','binding_constraints')
 reviews['reviews']<<{'compound_id'=>id,'display_title'=>entry['display_title'],'current_choice_reason'=>'Review in reviews/custody_acquisition_foundation.md; scores are author judgments, not independent semantic validation.','candidates'=>candidates,'recommendation'=>'approve explicit_relation_actualization','confidence'=>'high'}
end
dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write(file,YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
migration='migrations/custody_acquisition_2026_11_04.yaml'
unless File.exist?(File.join(V::ROOT,migration))
 V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/custody_acquisition_foundation.md','before_dictionary_fingerprint'=>before,'added_compound_id'=>id,'convention'=>meaning,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false,'required_followup'=>'Validate sentence meaning, nested custody binding and all runtime states; sourced transfer and delivery remain separate.'}))
end
puts id
