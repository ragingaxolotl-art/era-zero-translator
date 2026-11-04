import {strictSemanticReader} from './strict_semantic_reader.mjs';
export function readRunningTree(node,reader,readActor){
 const fail=()=>{throw new Error('Unsupported or malformed running music.');};
 if(node.marker!=='convention_23_open'||node.children?.length!==1)fail();
 const base=node.children[0];if(base.marker!=='convention_20_open'||base.children?.length!==3)fail();
 const [actor,body,head]=base.children;
 reader.exactRoot(body,'MAT:000','middle',null);
 if(![0,1,2].includes(head.runtime_state))fail();reader.exactRoot(head,'MAT:101','middle',head.runtime_state);
 return {predicate:'ongoing_bodily_running',runtime_state:head.runtime_state,actor:readActor?readActor(actor):reader.role(actor,'actor','low'),convention_codes:[23,20],meaning:{body_generates_locomotor_pattern:true,gait:'running',airborne_interval_required:false,speed_threshold_asserted:false,net_ground_progress_asserted:false,arrival_asserted:false,conscious_intention_asserted:false},limitations:['Gait does not establish displacement or completed arrival.','Strict MIDI only; no recorded-audio or external referent recovery.']};
}
export function decodeRunningMidi(bytes,atoms){
 const reader=strictSemanticReader(bytes,atoms,'Malformed running music.'),{current,scopes}=reader.unwrapScopes(n=>n.marker==='convention_23_open');
 if(current.length!==1)throw new Error('Unsupported or malformed running music.');
 return {profile:'EZRUN-INVERSE-1',speech_act:reader.observed.speech_act,scopes,...readRunningTree(current[0],reader)};
}
