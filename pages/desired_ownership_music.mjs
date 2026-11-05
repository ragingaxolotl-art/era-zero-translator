import {validateDesiredOwnership} from './desired_ownership.mjs';
import {desiredOwnershipEvent} from './desired_ownership_frames.mjs';
import {ownershipMusicEvents,readOwnershipTree} from './ownership_music.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function midiFromDesiredOwnership(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateDesiredOwnership(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'desired-ownership',name);
 let events=[desiredOwnershipEvent(d.subject_binding,d.runtime_state,'open',anchor),mark('role_experiencer_open'),...await renderLexicalOccurrences({nodes:[d.holder],edges:[]},authority,{anchor}),mark('role_experiencer_close'),mark('proposition_content_open'),...await ownershipMusicEvents(d.content,authority,{allowDraft:true,anchor}),mark('proposition_content_close'),desiredOwnershipEvent(d.subject_binding,d.runtime_state,'close',anchor)];
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return midiFromScheduledEvents(events,anchor,d.speech_act==='question'?[0,2]:[0,0]);
}
export function decodeDesiredOwnershipMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Desired ownership requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed desired ownership music.',{allowDraftOwnership:true,allowDraftDesiredOwnership:true}),{current,scopes}=reader.unwrapScopes(n=>/^desired_ownership_/.test(n.marker||'')),frame=current[0],m=frame?.marker?.match(/^desired_ownership_(same_as_desire_holder|explicit_content_subject)_([012])_open$/);
 const valid=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(current.length!==1||!m||frame.children?.length!==2||!valid.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(reader.observed.speech_act))throw new Error('Invalid desired ownership structure.');
 const holder=reader.role(frame.children[0],'experiencer','middle'),nested=frame.children[1];
 if(!['phonemic','deictic'].includes(holder.kind)||holder.property||holder.reference_mode==='nominal_class'||nested.marker!=='proposition_content_open')throw new Error('Invalid desire arguments.');
 const content=readOwnershipTree(nested.children,reader);
 if(m[1]==='same_as_desire_holder'&&JSON.stringify(holder)!==JSON.stringify(content.owner))throw new Error('Invalid controlled owner.');
 return {profile:'EZDESIRED-OWNERSHIP-INVERSE-1',status:'draft',foundation_id:'FND:f66b7a3877f4b0140a0b7023',holder,content,content_status:'intensional',outcome_commitment:'desired_not_asserted',subject_binding:m[1],runtime_state:Number(m[2]),speech_act:reader.observed.speech_act,scopes};
}
