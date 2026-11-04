import {strictSemanticReader} from './strict_semantic_reader.mjs';
export function decodeSwimmingMidi(bytes,atoms){
 const fail=()=>{throw new Error('Unsupported or malformed swimming music.');};
 const reader=strictSemanticReader(bytes,atoms,'Malformed swimming music.'),{current,scopes}=reader.unwrapScopes(n=>['convention_21_open','convention_22_open'].includes(n.marker));
 if(current.length!==1)fail();let outer=current[0],region;
 if(outer.marker==='convention_22_open'){if(outer.children?.length!==2)fail();region=reader.role(outer.children[0],'environment','sustained_background');outer=outer.children[1];}
 if(outer.marker!=='convention_21_open'||outer.children?.length!==1)fail();
 const base=outer.children[0];if(base.marker!=='convention_20_open'||base.children?.length!==3)fail();
 const [actor,body,head]=base.children;
 reader.exactRoot(body,'MAT:000','middle',null);
 if(![0,1,2].includes(head.runtime_state))fail();reader.exactRoot(head,'MAT:101','middle',head.runtime_state);
 return {profile:'EZSWIM-INVERSE-1',speech_act:reader.observed.speech_act,scopes,predicate:region?'ongoing_swimming_across_region':'ongoing_bodily_swimming',runtime_state:head.runtime_state,actor:reader.role(actor,'actor','low'),convention_codes:region?[22,21,20]:[21,20],...(region?{path:{relation:'across',phase:'ongoing',region,progress_relative_to_region:true,completion_asserted:false}}:{}),meaning:{body_generates_locomotor_pattern:true,medium:'water',swimming_propulsion:true,net_ground_progress_asserted:false,arrival_asserted:false,unassisted_activity_asserted:false,conscious_intention_asserted:false},limitations:['Local bodily activity does not establish a completed path.','Strict MIDI only; no recorded-audio or external referent recovery.']};
}
