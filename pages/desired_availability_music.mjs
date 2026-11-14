import {validateDesiredAvailability} from './desired_availability.mjs';
import {desiredAvailabilityEvent} from './desired_availability_frames.mjs';
import {custodyOpportunityMusicEvents,readCustodyOpportunityTree} from './custody_opportunity_music.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function midiFromDesiredAvailability(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateDesiredAvailability(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'desired-availability',name);
 let events=[desiredAvailabilityEvent(d.subject_binding,d.runtime_state,'open',anchor),mark('role_experiencer_open'),...await renderLexicalOccurrences({nodes:[d.holder],edges:[]},authority,{anchor}),mark('role_experiencer_close'),mark('proposition_content_open'),...await custodyOpportunityMusicEvents(d.content,authority,{allowDraft:true,anchor}),mark('proposition_content_close'),desiredAvailabilityEvent(d.subject_binding,d.runtime_state,'close',anchor)];
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return midiFromScheduledEvents(events,anchor,d.speech_act==='question'?[0,2]:[0,0]);
}
export function decodeDesiredAvailabilityMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Desired availability requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed desired availability music.',{allowDraftCustodyOpportunity:true,allowDraftDesiredAvailability:true}),{current,scopes}=reader.unwrapScopes(n=>/^desired_availability_/.test(n.marker||'')),frame=current[0],m=frame?.marker?.match(/^desired_availability_(explicit_content_subject)_([012])_open$/);
 const valid=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(current.length!==1||!m||frame.children?.length!==2||!valid.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(reader.observed.speech_act))throw new Error('Invalid desired availability structure.');
 const holder=reader.role(frame.children[0],'experiencer','middle'),nested=frame.children[1];
 if(!['phonemic','deictic'].includes(holder.kind)||holder.property||holder.reference_mode==='nominal_class'||nested.marker!=='proposition_content_open')throw new Error('Invalid desire arguments.');
 const content=readCustodyOpportunityTree(nested.children,reader);
 return {profile:'EZDESIRED-AVAILABILITY-INVERSE-1',status:'draft',foundation_id:'FND:f66b7a3877f4b0140a0b7023',holder,content,content_status:'intensional',outcome_commitment:'desired_not_asserted',subject_binding:m[1],runtime_state:Number(m[2]),speech_act:reader.observed.speech_act,scopes};
}
