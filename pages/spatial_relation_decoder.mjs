import {strictSemanticReader} from './strict_semantic_reader.mjs';
// Recover the selected spatial relation from MIDI, without an English input or IR.
const meanings={convention_26_open:'interior',convention_27_open:'exterior',convention_28_open:'boundary_intersection'};
export function readSpatialRelationTree(node,reader,{embedded=false}={}){
 const fail=()=>{throw new Error('Unsupported or malformed spatial relation music.');};
 if(!Object.hasOwn(meanings,node.marker)||node.children?.length!==3)fail();
 const [bearer,region,head]=node.children;
 if(bearer.marker!=='role_bearer_open'||bearer.children?.length<2)fail();
 reader.exactRoot(bearer.children[0],'MAT:000','middle',null);
 if(embedded?head.runtime_state!==null:![0,1,2].includes(head.runtime_state))fail();
 reader.exactRoot(head,'MOV:221','middle',head.runtime_state);
 return {
  relation:meanings[node.marker],runtime_state:head.runtime_state,
  bearer:reader.reference(bearer.children.slice(1),'middle'),region:reader.role(region,'location','sustained_background'),
  criterion:'contextually selected region and relevant participant extent in a shared spatial frame',
  limitations:['No measured geometry, external referent identity or whole-body criterion is recovered from sound labels.','Location does not assert entry, exit, movement, permission or continued presence.','Strict MIDI recovery only; recorded-audio recognition is not established.']};
}

export function decodeSpatialRelationMidi(bytes,atoms){
 const reader=strictSemanticReader(bytes,atoms,'Malformed spatial relation music.');
 const {current,scopes}=reader.unwrapScopes(n=>Object.hasOwn(meanings,n.marker));
 if(current.length!==1)throw new Error('Unsupported or malformed spatial relation music.');
 return {profile:'EZSPATIAL-INVERSE-1',speech_act:reader.observed.speech_act,scopes,...readSpatialRelationTree(current[0],reader)};
}
