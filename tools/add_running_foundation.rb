#!/usr/bin/env ruby
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
d=V.load_yaml('lexicon/compound_dictionary.yaml');reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
before=V.fingerprint(d['entries']);prior=d['entries'].map{|e|e['compound_id']};added={}
base=d['entries'].find{|e|e.dig('conventional_meaning','sense_key')=='ongoing_bodily_locomotor_activity'};raise 'Missing locomotor foundation' unless base
added['ongoing_bodily_locomotor_activity']=base.fetch('compound_id')
records=[[23,'ongoing_bodily_running','ongoing bodily running','ongoing_bodily_locomotor_activity','The same actor performs a bodily running gait: a repeated leg-support and recovery pattern of the running class, characterized by bouncing or compressive support rather than the vaulting progression characteristic of walking. This is a conventional gait category, not a speed threshold or an inference from arbitrary body movement. Grounded forms without an airborne interval and running in place are included. The actor need not be human or biological. No particular speed, net ground-relative displacement, destination, arrival, conscious intention or unassisted performance is asserted.',['Walking, passive carriage or fast displacement without running gait','Running a program, operating a machine or liquid flowing','Arrival, mandatory flight phase or a speed threshold inferred from running']]]
records.each do |code,key,title,dependency,definition,excludes|
 nodes=[{'node_id'=>'h','kind'=>'compound_ref','compound_id'=>added.fetch(dependency),'definition_version'=>'1.0.0'}]
 edges=[]
 meaning={'profile'=>'EZLEX-1','sense_key'=>key,'sound_code'=>code,'added_definition'=>definition,'excludes'=>excludes}
 payload={'architecture_version'=>'1.0','semantic_head'=>'h','nodes'=>nodes,'edges'=>edges,'lexical_constraints'=>['The bound actor anchors the same focal material body and local physical changes throughout the nested activity.','Locomotor pattern and specialization are explicit audible conventions, not consequences of root adjacency.','Runtime, grammatical negation, time and path completion are independent.'],'conventional_meaning'=>meaning}
 digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}";added[key]=id
 entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-11-04','display_title'=>title,'english_glosses'=>[title],'invariant_definition'=>definition,'boundaries'=>{'includes'=>definition,'excludes'=>excludes.join('; ')},'collision_audit'=>'reviews/locomotion_foundations.md and reviews/running_foundation.md; physical change alone does not entail the declared locomotor pattern.','confidence'=>'high','approval_record'=>'migrations/running_2026_11_04.yaml','approval_basis'=>'Author review under the user-directed translator completion goal; not independent linguistic validation.','examples'=>{'ordinary'=>'Nora is running.','technical'=>'Preserve the same bound actor in each version-pinned dependency.','future_compound'=>'Add a path only with the same actor and event binding.','counterexample'=>excludes.first},'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
 old=d['entries'].find{|e|e['compound_id']==id};raise 'Existing activity changed' if old&&old!=entry;d['entries']<<entry unless old
 unless reviews['reviews'].any?{|r|r['compound_id']==id}
  candidates=[['explicit_activity_convention','Physical ingredients remain true; the convention supplies pattern and manner.',[9,10,10,9,9,10,8,10],'winner'],['generic_displacement','Displacement loses bodily propulsion and can exclude in-place activity.',[8,9,9,2,3,4,3,4],'rejected'],['runtime_as_manner','Runtime does not encode gait, water or propulsion.',[1,2,2,1,1,1,2,1],'rejected']].map{|name,reason,scores,decision|{'candidate_id'=>name,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
  candidates[0]['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning')
  reviews['reviews']<<{'compound_id'=>id,'display_title'=>title,'current_choice_reason'=>'reviews/running_foundation.md; author judgments, not independent validation.','candidates'=>candidates,'recommendation'=>'approve explicit_activity_convention','confidence'=>'high'}
 end
end
EraZeroCompoundConventions.validate!(d['entries']);d['entries'].sort_by!{|e|e['compound_id']};d['metadata']['entry_count']=d['entries'].length
V.write('lexicon/compound_dictionary.yaml',YAML.dump(d));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
cases=V.load_yaml('tests/gate4b_compound_cases.yaml');cases['metadata']['approved_entries']=d['entries'].length;cases['accepted']=d['entries'].map{|e|{'case_id'=>e['display_title'].tr(' ','_'),'compound_id'=>e['compound_id'],'expected'=>'valid_approved_entry'}};V.write('tests/gate4b_compound_cases.yaml',YAML.dump(cases))
version=V.load_yaml('spec/version.yaml');version['compound_dictionary_entries']=d['entries'].length;V.write('spec/version.yaml',YAML.dump(version))
migration='migrations/running_2026_11_04.yaml';V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/running_foundation.md','before_dictionary_fingerprint'=>before,'previous_compound_ids'=>prior,'added_compounds'=>added.reject{|k,v|k=='ongoing_bodily_locomotor_activity'},'new_convention_codes'=>[23],'existing_meanings_changed'=>false})) unless File.exist?(File.join(V::ROOT,migration))
V.write('pages/running.mjs',"export const RUNNING = #{JSON.generate({pattern:'running',predicate:added.fetch('ongoing_bodily_running'),key:'ongoing_bodily_running',wording:'is running',role:'actor',compoundSlots:{actor:['h','s-actor']},semanticNote:records[0][4]})};\n")
puts JSON.pretty_generate(added)
