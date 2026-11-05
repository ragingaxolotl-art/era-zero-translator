#!/usr/bin/env ruby
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V=EraZeroValidation
dictionary=V.load_yaml('lexicon/compound_dictionary.yaml')
reviews=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
before=V.fingerprint(dictionary['entries']);previous=dictionary['entries'].map{|e|e['compound_id']};added={};paths={};routes=[]
records=[
 [11,'felt_self_condition',nil,'consciously felt self-condition',nil,
  'The bound experiencer has a presently conscious felt presentation of their own condition. The presentation is experiential rather than merely stored, inferred, reported or externally registered, and can be implicit without a verbal judgment. Within this compound the self in LIF:001 and MIN:001 is the bound experiencer, not necessarily the speaker. No particular pleasantness, desire, bodily need, cause, truth of a judgment or external sensory channel is asserted.',
  ['Unconscious sensory registration or a device record alone','A manifest self-model without conscious feeling','A specific emotional valence or bodily need inferred from generic feeling']],
 [12,'pleasant_felt_condition','felt_self_condition','pleasant felt condition',nil,
  'The same consciously felt self-condition has a pleasant experiential tone for its experiencer. Pleasantness is felt valence, not an appraisal that an outcome is useful, morally good or desired. It does not by itself establish happiness, satisfaction, affection, care, preference, or absence of simultaneous unpleasant feeling.',
  ['Care behavior or a favorable judgment without pleasant feeling','Attention or physiological activation used as positive valence','Happiness or a preferred outcome inferred from any pleasant feeling']],
 [13,'happy_felt_mood','pleasant_felt_condition','happy felt mood','happy',
  'The experiencer feels happiness: a pleasant emotional mood of gladness or contentment, not merely a pleasant sensory quality or a favorable evaluation. The mood can coexist with other feelings and need not be permanent, intense, externally expressed, or caused by a particular event. This is the felt-state sense of happy, not fortunate, willing, suitable or happy with a specified object.',
  ['Fortunate circumstances or willingness without felt happiness','Care, attention, approval or a pleasant sensation alone','Absence of sadness or an exclusively positive emotional state inferred from happiness']],
 [14,'felt_bodily_need','felt_self_condition','felt bodily replenishment need',nil,
  'The same consciously felt self-condition presents the experiencer\'s own material body as calling for replenishment or maintenance. MAT:000 identifies that experiencer\'s body within the same focal frame. This is a felt bodily demand, not proof of a measured physiological deficit, harm, failed viability, an intended action or actual replenishment. The required resource or maintenance kind is not yet specified.',
  ['A bodily deficit that is not felt','An intellectual wish or a duty without a felt bodily demand','Measured depletion, damage or action inferred from the feeling']],
 [15,'felt_hunger','felt_bodily_need','felt hunger','hungry',
  'The same felt bodily replenishment need is hunger: a bodily feeling calling for food or nourishment through eating. The feeling need not prove a measured energy deficit or imminent harm and does not assert eating, appetite for a particular food, permission, or a deliberate plan. Figurative hunger for achievement or information is excluded.',
  ['Water-directed thirst without food-directed hunger','Dormancy, low work capacity or an unfelt nutritional deficit alone','A metaphorical desire for success or knowledge']],
 [16,'felt_thirst','felt_bodily_need','felt thirst','thirsty',
  'The same felt bodily replenishment need is thirst: a bodily feeling calling for water intake, ordinarily through drinking. It does not prove a measured water deficit or assert drinking, a chosen beverage, permission, or a deliberate plan. Figurative thirst for power or knowledge is excluded.',
  ['Food-directed hunger without water-directed thirst','A dry object, an unfelt fluid deficit or dormancy alone','A metaphorical desire for power or knowledge']],
 [17,'felt_fatigue','felt_self_condition','felt fatigue','tired',
  'The experiencer feels fatigue: a condition of weariness in which sustaining physical or mental effort is felt as taxing or diminished and rest or recovery is called for. This does not entail sleep, dormancy, unconsciousness, objective incapacity, illness, damage or a measured energy deficit. Mere boredom or being tired of a particular object is a separate sense.',
  ['Dormancy or unconsciousness without felt fatigue','Low physical work capacity or damage without weariness','Boredom with a particular object or a generic unpleasant feeling alone']],
 [18,'unpleasant_felt_condition','felt_self_condition','unpleasant felt condition',nil,
  'The same consciously felt self-condition has an unpleasant experiential tone for its experiencer. Unpleasantness is felt valence, not merely objective harm, disapproval, lack of pleasure, or a desire to avoid an outcome. It may coexist with pleasant feeling and does not by itself specify sadness, pain, fear, anger, fatigue or a cause.',
  ['Absence of pleasant feeling without unpleasant feeling','Objective harm or disapproval without unpleasant experience','Sadness, fear or pain inferred from every unpleasant feeling']],
 [19,'sad_felt_mood','unpleasant_felt_condition','sad felt mood','sad',
  'The experiencer feels sadness: an unpleasant emotional mood of sorrow or low spirits. This is a felt-state meaning, not a diagnosis, a judgment that an event is unfortunate, or every unpleasant sensation. It does not require a particular loss, crying, outward expression, permanence, incapacity, lack of care or total absence of happiness.',
  ['Negated happiness or emotional neutrality without sadness','Physical pain, fear or anger without sadness','A regrettable event or medical diagnosis inferred from the adjective']]
]
records.each do |code,key,dependency,title,surface,definition,excludes|
 meaning={'profile'=>'EZLEX-1','sense_key'=>key,'sound_code'=>code,'added_definition'=>definition,'excludes'=>excludes}
 if dependency
  nodes=[{'node_id'=>'h','kind'=>'compound_ref','compound_id'=>added.fetch(dependency),'definition_version'=>'1.0.0'}];edges=[]
  if code==14
   nodes.unshift({'node_id'=>'q-body','kind'=>'root','root_id'=>'MAT:000'});edges<<{'type'=>'qualifies','from'=>'q-body','to'=>'h'}
  end
  path=['h']+paths.fetch(dependency)
 else
  nodes=[{'node_id'=>'q-conscious','kind'=>'root','root_id'=>'LIF:001'},{'node_id'=>'s-experiencer','kind'=>'slot','slot_name'=>'experiencer','slot_type'=>'entity'},{'node_id'=>'h','kind'=>'root','root_id'=>'MIN:001'}]
  edges=[{'type'=>'qualifies','from'=>'q-conscious','to'=>'h'},{'type'=>'fills_role','from'=>'s-experiencer','to'=>'h','role'=>'experiencer'}];path=['s-experiencer']
 end
 payload={'architecture_version'=>'1.0','semantic_head'=>'h','nodes'=>nodes,'edges'=>edges,'lexical_constraints'=>['The bound experiencer anchors the focal self of every nested self-condition; no automatic speaker substitution.','Felt meaning and any specialization are explicit lexical conventions, not consequences of root adjacency alone.','Lexical trits, experiential quality, time, grammatical negation and runtime 0/1/2 remain independent.'],'conventional_meaning'=>meaning}
 digest=V.fingerprint(payload);id="CMP:#{digest[0,24]}";added[key]=id;paths[key]=path
 entry=payload.merge('compound_id'=>id,'content_digest'=>digest,'definition_version'=>'1.0.0','status'=>'approved','approval_date'=>'2026-11-04','display_title'=>title,'english_glosses'=>[title],'invariant_definition'=>definition,'boundaries'=>{'includes'=>definition,'excludes'=>excludes.join('; ')},'collision_audit'=>"Convention #{code} explicitly adds the stated felt distinction. Exact dependency versions preserve the shared experiencer; no existing mental, living, material, care or runtime meaning is substituted for the added feeling.",'confidence'=>'high','approval_record'=>(code>=18 ? 'migrations/sadness_2026_11_04.yaml' : 'migrations/felt_conditions_2026_11_04.yaml'),'approval_basis'=>'Delegated author semantic review under the user-directed completion goal; reviews/felt_conditions_foundation.md. Not independent linguistic validation.','examples'=>{'ordinary'=>surface ? "Eli is #{surface}." : "The experiencer has a #{title}.",'technical'=>'The same experiencer is retained through the version-pinned nested felt-state definitions.','future_compound'=>'Reuse the exact felt foundation before specializing its object, cause or relief.','counterexample'=>excludes.first},'serialization'=>{'canonical_format'=>'EZC-JSON-1','content_digest'=>digest})
 old=dictionary['entries'].find{|e|e['compound_id']==id};abort 'Existing felt definition differs' if old&&old!=entry;dictionary['entries']<<entry unless old
 unless reviews['reviews'].any?{|r|r['compound_id']==id}
  candidates=[['explicit_felt_specialization','Bind one experiencer, reuse exact dependencies and audibly declare the additional felt meaning.',[9,10,10,9,9,10,8,10],'winner'],['unmarked_root_substitution','Representation, care, work capacity and viability do not entail the required feeling.',[8,9,9,2,3,4,3,4],'rejected: missing experiential distinction'],['runtime_as_feeling','Runtime status does not encode pleasantness, hunger, thirst or fatigue.',[1,2,2,1,1,1,2,1],'rejected: ternary semantic loss']].map{|name,reason,scores,decision|{'candidate_id'=>name,'direction'=>reason,'scores'=>V::SCORE_KEYS.zip(scores).to_h,'total'=>scores.sum,'decision'=>decision}}
  candidates[0]['graph']=payload.slice('semantic_head','nodes','edges','conventional_meaning')
  reviews['reviews']<<{'compound_id'=>id,'display_title'=>title,'current_choice_reason'=>'reviews/felt_conditions_foundation.md; author judgments, not independent validation.','candidates'=>candidates,'recommendation'=>'approve explicit_felt_specialization','confidence'=>'high'}
 end
 routes<<{pattern:surface,predicate:id,key:key,wording:"is #{surface}",role:'experiencer',compoundSlots:{experiencer:path},semanticNote:definition} if surface
end
EraZeroCompoundConventions.validate!(dictionary['entries']);dictionary['entries'].sort_by!{|e|e['compound_id']};dictionary['metadata']['entry_count']=dictionary['entries'].length
V.write('lexicon/compound_dictionary.yaml',YAML.dump(dictionary));V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml',YAML.dump(reviews))
V.write('pages/felt_conditions.mjs',"// Generated reviewed surface routes; root definitions and sounds are unchanged.\nexport const FELT_CONDITIONS = #{JSON.pretty_generate(routes)};\n")
migration='migrations/felt_conditions_2026_11_04.yaml'
unless File.exist?(File.join(V::ROOT,migration))
 V.write(migration,YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/felt_conditions_foundation.md','before_dictionary_fingerprint'=>before,'previous_compound_ids'=>previous,'added_compounds'=>added,'slot_paths'=>paths,'new_convention_codes'=>(11..17).to_a,'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false}))
end
puts JSON.pretty_generate(added)

unless File.exist?(File.join(V::ROOT,'migrations/sadness_2026_11_04.yaml'))
 V.write('migrations/sadness_2026_11_04.yaml',YAML.dump({'authority'=>'User-directed translator-completion goal','review'=>'reviews/sadness_foundation.md','before_dictionary_fingerprint'=>before,'previous_compound_ids'=>previous,'added_compounds'=>added.select{|k,v|%w[unpleasant_felt_condition sad_felt_mood].include?(k)},'new_convention_codes'=>[18,19],'atomic_meanings_changed'=>false,'existing_compound_meanings_changed'=>false}))
end

cases=V.load_yaml('tests/gate4b_compound_cases.yaml')
cases['metadata']['approved_entries']=dictionary['entries'].length
cases['accepted']=dictionary['entries'].map{|e|{'case_id'=>e['display_title'].tr(' ','_'),'compound_id'=>e['compound_id'],'expected'=>'valid_approved_entry'}}
V.write('tests/gate4b_compound_cases.yaml',YAML.dump(cases))
version=V.load_yaml('spec/version.yaml');version['compound_dictionary_entries']=dictionary['entries'].length
V.write('spec/version.yaml',YAML.dump(version))
