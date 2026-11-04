import {strictSemanticReader} from './strict_semantic_reader.mjs';
export function readRunningTree(node,reader,readActor,{embedded=false}={}){
 const fail=()=>{throw new Error('Unsupported or malformed running music.');};
 if(node.marker!=='convention_23_open'||node.children?.length!==1)fail();
 const base=node.children[0];if(base.marker!=='convention_20_open'||base.children?.length!==3)fail();
 const [actor,body,head]=base.children;
 reader.exactRoot(body,'MAT:000','middle',null);
 if(embedded?head.runtime_state!==null:![0,1,2].includes(head.runtime_state))fail();reader.exactRoot(head,'MAT:101','middle',head.runtime_state);
 return {predicate:'ongoing_bodily_running',runtime_state:head.runtime_state,actor:readActor?readActor(actor):reader.role(actor,'actor','low'),convention_codes:[23,20],meaning:{body_generates_locomotor_pattern:true,gait:'running',airborne_interval_required:false,speed_threshold_asserted:false,net_ground_progress_asserted:false,arrival_asserted:false,conscious_intention_asserted:false},limitations:['Gait does not establish displacement or completed arrival.','Strict MIDI only; no recorded-audio or external referent recovery.']};
}
export function decodeRunningMidi(bytes,atoms){
 const reader=strictSemanticReader(bytes,atoms,'Malformed running music.'),{current,scopes}=reader.unwrapScopes(n=>['convention_23_open','convention_24_open'].includes(n.marker));
 if(current.length!==1)throw new Error('Unsupported or malformed running music.');
 const node=current[0];
 if(node.marker==='convention_24_open'){
  const fail=()=>{throw new Error('Unsupported or malformed directed running music.');};
  if(node.children?.length!==4)fail();
  const [actorFrame,destinationFrame,nested,head]=node.children;
  if(![0,1,2].includes(head.runtime_state))fail();
  reader.exactRoot(head,'MOV:111','middle',head.runtime_state);
  const actor=reader.role(actorFrame,'actor','low'),destination=reader.role(destinationFrame,'destination','high');
  const running=readRunningTree(nested,reader,undefined,{embedded:true});
  if(JSON.stringify(actor)!==JSON.stringify(running.actor))fail();
  return {profile:'EZRUN-INVERSE-1',speech_act:reader.observed.speech_act,scopes,...running,predicate:'ongoing_destination_running',runtime_state:head.runtime_state,convention_codes:[24,23,20],destination,meaning:{...running.meaning,same_actor:true,same_event:true,destination_relation:'toward',approach_asserted:true,destination_relative_displacement_asserted:true,receipt_asserted:false},limitations:['Approach and running are bound to one event and actor; arrival is not asserted.','Repeated sounds are checked for consistency, not external identity.','Strict MIDI only; no recorded-audio or external referent recovery.']};
 }
 return {profile:'EZRUN-INVERSE-1',speech_act:reader.observed.speech_act,scopes,...readRunningTree(node,reader)};
}
