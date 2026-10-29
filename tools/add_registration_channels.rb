#!/usr/bin/env ruby
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_expansion'
V=EraZeroValidation
file='lexicon/compound_dictionary.yaml'
dictionary=V.load_yaml(file)
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
base=dictionary.fetch('entries').find{|e|e['compound_id']=='CMP:ade73037114406a2cd91ce13'} or abort 'Missing reviewed sensory registration foundation'
before=V.fingerprint(dictionary['entries']);added=[]
[
 ['optical',1,'The sensory transduction registers information carried by light from the source, including visible, infrared or ultraviolet light. No conscious visual experience, color judgment, object recognition or attention is entailed.','light-mediated sensory registration in a biological or device receiver','radio data transfer, acoustic-only input, visual imagination, and conscious seeing inferred from registration'],
 ['acoustic',2,'The sensory transduction registers information carried by a propagating mechanical pressure or elastic vibration signal from the source through a material medium. No conscious auditory experience, speech comprehension, source recognition or attention is entailed.','sensory registration of an acoustic vibration signal in a biological or device receiver','static contact alone, optical-only input, remembered sounds, and conscious hearing inferred from registration']
].each do |channel,code,definition,includes,excludes|
 meaning={'profile'=>'EZLEX-1','sense_key'=>"ongoing_#{channel}_registration",'sound_code'=>code,'added_definition'=>definition,'excludes'=>[excludes,'Inferring the channel from the source noun alone']}
 payload={'architecture_version'=>'1.0','semantic_head'=>'h','nodes'=>[{'node_id'=>'h','kind'=>'compound_ref','compound_id'=>base['compound_id'],'definition_version'=>base['definition_version']}],'edges'=>[],
 'lexical_constraints'=>['The channel restriction applies to the same registration event and its source-to-receiver transfer. All inherited registration commitments remain true.'], 'conventional_meaning'=>meaning}
 digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}";title="ongoing #{channel} sensory registration"
 entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-10-28','display_title'=>title,'english_glosses'=>[title],
 'invariant_definition'=>"An instance of ongoing sensory registration, as defined by #{base['compound_id']} version 1.0.0, with the additional channel commitment: #{definition}",
 'boundaries'=>{'includes'=>includes,'excludes'=>excludes},'collision_audit'=>'The exact registration foundation is reused through a versioned reference. A distinct conventional frame adds the channel restriction; it is not inferred from root adjacency, source noun, or runtime state.','confidence'=>'high',
 'approval_record'=>'migrations/registration_channels_2026_10_28.yaml','approval_basis'=>'Delegated semantic approval under the user-directed translator-completion goal; reviews/registration_channels.md',
 'examples'=>{'ordinary'=>"The sensor is registering #{channel} input from the bell.",'technical'=>definition,'future_compound'=>'Reuse the exact registration/channel meaning where the derived definition entails it; conscious experience and recognition require additional foundations.','counterexample'=>"Do not infer this channel from the noun bell; exclude #{excludes}."},
 'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
 old=dictionary['entries'].find{|e|e['compound_id']==id};abort 'Existing channel definition differs' if old && old!=entry
 dictionary['entries']<<entry unless old
 unless reviews['reviews'].any?{|r|r['compound_id']==id}
  candidates=[['versioned_specialization','Reuse registration exactly and add an explicit, audible channel restriction.',[9,10,10,10,9,10,8,10],'winner'],['unmarked_reference','A reference alone repeats registration without distinguishing a channel.',[9,10,10,1,3,5,3,4],'rejected: missing channel'],['noun_inference','Guessing the channel from a source name loses meaning and fails cross-channel cases.',[3,3,3,1,2,3,3,2],'rejected: source noun is not a channel']].map{|key,reason,scores,decision|{'candidate_id'=>key,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
  candidates[0]['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning')
  reviews['reviews']<<{'compound_id'=>id,'display_title'=>title,'current_choice_reason'=>'Review in reviews/registration_channels.md; scores are author judgments, not independent validation.','candidates'=>candidates,'recommendation'=>'approve versioned_specialization','confidence'=>'high'}
 end
 added<<{'channel'=>channel,'compound_id'=>id,'convention'=>meaning,'dependency'=>{'compound_id'=>base['compound_id'],'definition_version'=>base['definition_version']}}
end
EraZeroCompoundDependencies::Registry.new(dictionary['entries']).ordered
dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write(file,YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
migration='migrations/registration_channels_2026_10_28.yaml'
unless File.exist?(File.join(V::ROOT,migration))
 V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/registration_channels.md','before_dictionary_fingerprint'=>before,'added'=>added,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false}))
end
puts JSON.generate(added.map{|e|e.slice('channel','compound_id')})
