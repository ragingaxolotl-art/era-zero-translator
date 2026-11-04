import {strictSemanticReader} from './strict_semantic_reader.mjs';

// Learned lexical conventions interpreted from performed MIDI, not source IR.
const profiles={
  11:{predicate:'felt_self_condition',chain:[11],quality:'unspecified'},
  12:{predicate:'pleasant_felt_condition',chain:[12,11],quality:'pleasant'},
  13:{predicate:'happy_felt_mood',chain:[13,12,11],quality:'glad_or_content_mood'},
  14:{predicate:'felt_bodily_need',chain:[14,11],quality:'bodily_replenishment_demand'},
  15:{predicate:'felt_hunger',chain:[15,14,11],quality:'food_directed_bodily_demand'},
  16:{predicate:'felt_thirst',chain:[16,14,11],quality:'water_directed_bodily_demand'},
  17:{predicate:'felt_fatigue',chain:[17,11],quality:'physical_or_mental_weariness'}
};
export function decodeFeltConditionMidi(bytes,atoms){
 const message='Unsupported or malformed felt-condition music.',fail=()=>{throw new Error(message);};
 const {observed,marker,exactRoot,role,unwrapScopes}=strictSemanticReader(bytes,atoms,message);
 const {current,scopes}=unwrapScopes(node=>/^convention_(11|12|13|14|15|16|17)_open$/.test(node.marker||''));
 if(current.length!==1)fail();
 const meaning=readFeltConditionTree(current[0],{marker,exactRoot,role});
 return {profile:'EZFELT-INVERSE-1',speech_act:observed.speech_act,scopes,...meaning,
  limitations:['The felt predicate remains inside the recovered scope and speech act; negation, questions and future scope do not assert it presently holds.',
   'The subjective state does not diagnose a physical deficit, illness or objectively unavailable capacity.',
   'Specific figurative, evaluative and object-directed senses require other conventions.',
   'This bounded MIDI inverse does not recover original spelling, external identity, general discourse or arbitrary recorded audio.']};
}

// Shared tree interpretation for standalone and intensional felt conditions.
export function readFeltConditionTree(node,{marker,exactRoot,role},readExperiencer){
 const fail=()=>{throw new Error('Unsupported or malformed felt-condition music.');};
 const code=Number(node.marker?.match(/^convention_(\d+)_open$/)?.[1]),profile=profiles[code];if(!profile)fail();
 for(const expected of profile.chain){
  if(!marker(node,`convention_${expected}_open`))fail();
  if(expected===11)break;
  if(expected===14){
   if(node.children?.length!==2)fail();exactRoot(node.children[0],'MAT:000','middle',null);node=node.children[1];
  }else{if(node.children?.length!==1)fail();node=node.children[0];}
 }
 if(node.children?.length!==3)fail();
 const [participant,conscious,head]=node.children,runtime=head?.runtime_state;
 if(![0,1,2].includes(runtime))fail();exactRoot(conscious,'LIF:001','middle',null);exactRoot(head,'MIN:001','middle',runtime);
 return {predicate:profile.predicate,
  runtime_state:runtime,participants:{experiencer:readExperiencer?readExperiencer(participant):role(participant,'experiencer','middle')},convention_codes:[...profile.chain],
  meaning:{consciously_felt_self_condition:true,focal_self_is_bound_experiencer:true,quality:profile.quality,
   measured_physiological_deficit_asserted:false,care_behavior_asserted:false,intended_action_asserted:false,
   sleep_or_dormancy_asserted:false,damage_asserted:false}};
}
