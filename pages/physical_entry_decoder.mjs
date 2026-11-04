import {strictSemanticReader} from './strict_semantic_reader.mjs';
import {readSpatialRelationTree} from './spatial_relation_decoder.mjs';
export function decodePhysicalEntryMidi(bytes,atoms){
 const fail=()=>{throw new Error('Unsupported or malformed physical entry music.');};
 const reader=strictSemanticReader(bytes,atoms,'Malformed entry music.');
 const {current,scopes}=reader.unwrapScopes(n=>n.marker==='convention_29_open');
 if(current.length!==1||current[0].marker!=='convention_29_open'||current[0].children?.length!==5)fail();
 const [actorFrame,regionFrame,beforeTree,afterTree,head]=current[0].children;
 const actor=reader.role(actorFrame,'actor','low'),region=reader.role(regionFrame,'environment','sustained_background');
 const before=readSpatialRelationTree(beforeTree,reader,{embedded:true}),after=readSpatialRelationTree(afterTree,reader,{embedded:true});
 if(before.relation!=='exterior'||after.relation!=='interior')fail();
 for(const phase of [before,after])if(JSON.stringify(phase.bearer)!==JSON.stringify(actor)||JSON.stringify(phase.region)!==JSON.stringify(region))fail();
 if(![0,1,2].includes(head.runtime_state))fail();reader.exactRoot(head,'MOV:120','middle',head.runtime_state);
 return {profile:'EZENTRY-INVERSE-1',speech_act:reader.observed.speech_act,scopes,predicate:'completed_physical_entry',actor,region,runtime_state:head.runtime_state,
  phases:{before:'exterior',culmination:'interior',after:'unspecified'},same_participant:true,same_region:true,same_event:true,
  limitations:['Entry is the event type under the recovered speech act and scopes; questions, commands and negation do not assert its occurrence.','No prescribed manner, permission, ownership or continued presence is asserted.','Strict MIDI only; external referent identity, contextual geometry and recorded audio are not recovered.']};
}
