import {strictSemanticReader} from './strict_semantic_reader.mjs';
export function decodeSwimmingMidi(bytes,atoms){
 const fail=()=>{throw new Error('Unsupported or malformed swimming music.');};
 const reader=strictSemanticReader(bytes,atoms,'Malformed swimming music.'),{current,scopes}=reader.unwrapScopes(n=>n.marker==='convention_21_open');
 if(current.length!==1)fail();const outer=current[0];
 if(outer.marker!=='convention_21_open'||outer.children?.length!==1)fail();
 const base=outer.children[0];if(base.marker!=='convention_20_open'||base.children?.length!==3)fail();
 const [actor,body,head]=base.children;
 reader.exactRoot(body,'MAT:000','middle',null);
 if(![0,1,2].includes(head.runtime_state))fail();reader.exactRoot(head,'MAT:101','middle',head.runtime_state);
 return {profile:'EZSWIM-INVERSE-1',speech_act:reader.observed.speech_act,scopes,predicate:'ongoing_bodily_swimming',runtime_state:head.runtime_state,actor:reader.role(actor,'actor','low'),convention_codes:[21,20],meaning:{body_generates_locomotor_pattern:true,medium:'water',swimming_propulsion:true,net_ground_progress_asserted:false,arrival_asserted:false,unassisted_activity_asserted:false,conscious_intention_asserted:false},limitations:['Local bodily activity does not establish a completed path.','Strict MIDI only; no recorded-audio or external referent recovery.']};
}
