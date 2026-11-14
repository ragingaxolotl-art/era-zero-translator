#!/usr/bin/env ruby
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
d=V.load_yaml('lexicon/compound_dictionary.yaml');reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
before=V.fingerprint(d['entries']);prior=d['entries'].map{|e|e['compound_id']};added={};routes=[]
common='The located participant is material, and its contextually relevant spatial extent is related to the bound physical region in one shared spatial frame at the reference time. The region and relevant extent are contextually selected, not measured or inferred from their sound labels. '
records=[
 [26,'physical_region_interior','physical region interior relation','is inside','The relevant extent lies wholly in the interior of the region, without meeting its boundary.'],
 [27,'physical_region_exterior','physical region exterior relation','is outside','The relevant extent lies wholly in the exterior of the region, without meeting its boundary.'],
 [28,'physical_region_boundary','physical region boundary relation','is on the boundary of','The relevant extent intersects the boundary of the region; this does not assert that the entire participant lies on the boundary.']
]
records.each do |code,key,title,pattern,commitment|
 definition=common+commitment+' No movement, entry, exit, structural membership, ownership, custody, intention or permission is asserted. The three relations are not runtime states and outside is not a synonym for not inside.'
 excludes=['Structural or organizational membership and figurative inclusion','Entry or exit inferred from current location','Outside inferred merely from not inside','A numeric geometry or whole-body criterion silently inferred from a noun label']
 payload={'architecture_version'=>'1.0','semantic_head'=>'h','nodes'=>[{'node_id'=>'q-body','kind'=>'root','root_id'=>'MAT:000'},{'node_id'=>'s-bearer','kind'=>'slot','slot_name'=>'located_participant','slot_type'=>'entity'},{'node_id'=>'s-region','kind'=>'slot','slot_name'=>'spatial_region','slot_type'=>'entity'},{'node_id'=>'h','kind'=>'root','root_id'=>'MOV:221'}],'edges'=>[{'type'=>'qualifies','from'=>'q-body','to'=>'s-bearer'},{'type'=>'fills_role','from'=>'s-bearer','to'=>'h','role'=>'bearer'},{'type'=>'fills_role','from'=>'s-region','to'=>'h','role'=>'location'}],'lexical_constraints'=>['The material qualifier applies to the located participant, not the region.','Both arguments share one contextual spatial frame and inclusion criterion.','Location does not assert displacement; lexical address and runtime state remain independent.'],'conventional_meaning'=>{'profile'=>'EZLEX-1','sense_key'=>key,'sound_code'=>code,'added_definition'=>definition,'excludes'=>excludes}}
 digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}";added[key]=id
 entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-11-04','display_title'=>title,'english_glosses'=>[title],'invariant_definition'=>definition,'boundaries'=>{'includes'=>definition,'excludes'=>excludes.join('; ')},'collision_audit'=>'reviews/spatial_entry_foundation.md; positional configuration alone does not specify interior, exterior or boundary.','confidence'=>'high','approval_record'=>'migrations/spatial_relations_2026_11_04.yaml','approval_basis'=>'Author semantic review under the user-directed translator completion goal; not independent linguistic validation.','examples'=>{'ordinary'=>"Nora #{pattern} the archive.",'technical'=>'Keep the same participant, region and contextual extent criterion in dependent event compounds.','future_compound'=>'Entry must add outside-to-inside displacement in one event.','counterexample'=>'Being inside throughout is not entry; touching the boundary is neither wholly inside nor wholly outside.'},'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
 old=d['entries'].find{|e|e['compound_id']==id};raise 'Existing spatial meaning changed' if old&&old!=entry;d['entries']<<entry unless old
 unless reviews['reviews'].any?{|r|r['compound_id']==id}
 candidates=[['explicit_spatial_convention','Material participant and live shared-frame configuration remain true; convention contributes spatial inclusion.',[9,10,10,9,9,10,8,10],'winner'],['configuration_only','Positional configuration does not determine interior or exterior.',[9,10,10,2,3,5,4,5],'rejected'],['structural_membership','Spatial occupancy is not structural membership.',[5,5,6,2,3,4,3,4],'rejected']].map{|name,reason,scores,decision|{'candidate_id'=>name,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
 candidates[0]['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning')
 reviews['reviews']<<{'compound_id'=>id,'display_title'=>title,'current_choice_reason'=>'reviews/spatial_entry_foundation.md; author scores, not independent validation.','candidates'=>candidates,'recommendation'=>'approve explicit_spatial_convention','confidence'=>'high'}
 end
 routes<<{pattern:pattern,predicate:id,key:key,wording:pattern,role:'bearer',targetRole:'location',compoundSlots:{bearer:['s-bearer'],location:['s-region']},semanticNote:definition}
end
EraZeroCompoundConventions.validate!(d['entries']);d['entries'].sort_by!{|e|e['compound_id']};d['metadata']['entry_count']=d['entries'].length
V.write('lexicon/compound_dictionary.yaml',YAML.dump(d));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
migration='migrations/spatial_relations_2026_11_04.yaml';V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/spatial_entry_foundation.md','before_dictionary_fingerprint'=>before,'previous_compound_ids'=>prior,'added_compounds'=>added,'new_convention_codes'=>[26,27,28],'existing_meanings_changed'=>false})) unless File.exist?(File.join(V::ROOT,migration))
V.write('pages/spatial_relations.mjs',"export const SPATIAL_RELATIONS = #{JSON.generate(routes)};\n")
puts JSON.pretty_generate(added)
