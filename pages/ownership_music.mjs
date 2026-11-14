import {validateOwnershipMeaning,OWNERSHIP_CONTRACT} from './ownership_meaning.mjs';
import {ownershipEvent} from './ownership_frames.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function ownershipMusicEvents(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateOwnershipMeaning(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'ownership',name);
 let events=[ownershipEvent(d.runtime_state,'open',anchor)];
 // In this convention the standard role identifies the normative framework.
 for(const [role,ref] of [['experiencer',d.owner],['content',d.object],['comparison_standard',d.framework]])events.push(mark(`role_${role}_open`),...await renderLexicalOccurrences({nodes:[ref],edges:[]},authority,{anchor}),mark(`role_${role}_close`));
 events.push(ownershipEvent(d.runtime_state,'close',anchor));
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return events;
}
export async function midiFromOwnership(d,authority,options={}){return midiFromScheduledEvents(await ownershipMusicEvents(d,authority,options),options.anchor??60,d.speech_act==='question'?[0,2]:[0,0]);}
export function decodeOwnershipMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Ownership requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed ownership music.',{allowDraftOwnership:true});return readOwnershipTree(reader.readTree(),reader,reader.observed.speech_act);
}
export function readOwnershipTree(nodes,reader,speechAct='assertion'){
 const {current,scopes}=reader.unwrapScopes(n=>/^ownership_/.test(n.marker||''),nodes),frame=current[0],m=frame?.marker?.match(/^ownership_([012])_open$/);
 const allowed=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(current.length!==1||!m||frame.children?.length!==3||!allowed.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(speechAct))throw new Error('Invalid ownership structure.');
 const owner=reader.role(frame.children[0],'experiencer','middle'),object=reader.role(frame.children[1],'content','middle'),framework=reader.role(frame.children[2],'comparison_standard','middle');
 for(const ref of [owner,object,framework])if(!['phonemic','deictic'].includes(ref.kind)||ref.property||ref.reference_mode==='nominal_class')throw new Error('Invalid ownership reference.');
 if(framework.kind!=='phonemic')throw new Error('Invalid ownership framework.');
 return {profile:'EZOWNERSHIP-INVERSE-1',status:'draft',...OWNERSHIP_CONTRACT,owner,object,framework,speech_act:speechAct,scopes,runtime_state:Number(m[1])};
}
