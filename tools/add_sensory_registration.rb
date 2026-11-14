#!/usr/bin/env ruby
# Idempotent, reviewed lexical extension under the user-directed completion goal.
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V = EraZeroValidation
path='lexicon/compound_dictionary.yaml'
dictionary=V.load_yaml(path)
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
meaning={
 'profile'=>'EZLEX-1','sense_key'=>'ongoing_sensory_registration','sound_code'=>0,
 'added_definition'=>'The transfer is realized by physical sensory transduction: the target receiver registers information carried by a physical stimulus from the distinct source. Registration does not by itself assert conscious experience, attention, identification or understanding.',
 'excludes'=>['Mere physical influence without informational registration','Generic data copying without sensory transduction','Conscious experience or understanding inferred from registration','A specified sensory channel inferred without a channel distinction']
}
payload={
 'architecture_version'=>'1.0','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'q01','kind'=>'root','root_id'=>'MAT:211'},{'node_id'=>'h','kind'=>'root','root_id'=>'DAT:111'}],
 'edges'=>[{'edge_id'=>'e01','type'=>'qualifies','from'=>'q01','to'=>'h'}],
 'lexical_constraints'=>['The qualifier describes the physical realization of the same source-to-target information transfer, not an unrelated simultaneous coupling.','The source is distinct from the receiving target. Neither consciousness nor communication intent is required.'],
 'conventional_meaning'=>meaning
}
digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}"
entry=payload.merge(
 'compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-10-28',
 'display_title'=>'ongoing sensory registration','english_glosses'=>['ongoing sensory registration'],
 'invariant_definition'=>'An ongoing information transfer from one distinct physical source to a receiving target, physically realized by active material coupling in which sensory transduction causes the receiver to register information carried by the source stimulus.',
 'boundaries'=>{'includes'=>'physical sensory registration by a biological receiver or a sensing device, with no required conscious experience','excludes'=>meaning['excludes'].join('; ')},
 'collision_audit'=>'MAT:211 supplies active physical coupling and DAT:111 supplies ongoing source-to-target information transfer. Their graph alone does not entail sensory transduction. EZLEX-1 code 0 explicitly contributes that additional conventional distinction; the unmarked graph remains broader.',
 'confidence'=>'high',
 'approval_record'=>'migrations/sensory_registration_2026_10_28.yaml',
 'approval_basis'=>'Delegated semantic approval under the user-directed translator-completion goal; reviews/sensory_registration_foundation.md',
 'examples'=>{'ordinary'=>'The sensor is registering sensory input from the bell.','technical'=>'A receiver transduces a physical stimulus into received information without asserting a conscious experience.','future_compound'=>'Reuse as the registration component of channel-specific sensing; experience and successful perception require separate definitions.','counterexample'=>'A body is warmed without registering information, or a stored file is copied without sensory transduction.'},
 'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
old=dictionary['entries'].find{|e| e['compound_id']==id}
abort 'Existing registration definition differs' if old && old!=entry
before=V.fingerprint(dictionary['entries'])
dictionary['entries']<<entry unless old
EraZeroCompoundConventions.validate!(dictionary['entries'])
unless reviews['reviews'].any?{|r| r['compound_id']==id}
 candidates=[
  ['explicit_transduction','Retains both physical coupling and information transfer; names the additional transduction commitment explicitly.',[9,10,10,9,9,10,8,10],'winner'],
  ['unmarked_transfer','Information transfer plus physical coupling does not select sensory registration.',[9,10,10,2,3,6,4,6],'rejected: sensory commitment absent'],
  ['conscious_representation','Conscious mental representation excludes nonconscious sensors and adds an unsupported experiential claim.',[6,6,5,5,4,5,4,4],'rejected: wrong receiver and experience commitments']
 ].map{|key,reason,scores,decision| {'candidate_id'=>key,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
 candidates.first['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning')
 reviews['reviews']<<{'compound_id'=>id,'display_title'=>entry['display_title'],'current_choice_reason'=>'Semantic analysis in reviews/sensory_registration_foundation.md. Scores are implementation-author judgments, not independent evidence.','candidates'=>candidates,'recommendation'=>'approve explicit_transduction','confidence'=>'high'}
end
dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write(path,YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
migration='migrations/sensory_registration_2026_10_28.yaml'
unless File.exist?(File.join(V::ROOT,migration))
 V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/sensory_registration_foundation.md','before_dictionary_fingerprint'=>before,'added_compound_id'=>id,'convention'=>meaning,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false,'required_followup'=>'Rebuild derived inventories; validate ordinary sentences, MIDI contrasts and runtime states before publication.'}))
end
puts id
