import {validateDesiredDrinking} from './desired_drinking.mjs';
import {desiredDrinkingEvent} from './desired_drinking_frames.mjs';
import {drinkingMusicEvents,readDrinkingTree} from './drinking_music.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function midiFromDesiredDrinking(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateDesiredDrinking(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'desired-drinking',name);
 let events=[desiredDrinkingEvent(d.subject_binding,d.runtime_state,'open',anchor),mark('role_experiencer_open'),...await renderLexicalOccurrences({nodes:[d.holder],edges:[]},authority,{anchor}),mark('role_experiencer_close'),mark('proposition_content_open'),...await drinkingMusicEvents(d.content,authority,{allowDraft:true,anchor}),mark('proposition_content_close'),desiredDrinkingEvent(d.subject_binding,d.runtime_state,'close',anchor)];
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return midiFromScheduledEvents(events,anchor,d.speech_act==='question'?[0,2]:[0,0]);
}
export function decodeDesiredDrinkingMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Desired drinking requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed desired drinking music.',{allowDraftDrinking:true,allowDraftDesiredDrinking:true}),{current,scopes}=reader.unwrapScopes(n=>/^desired_drinking_/.test(n.marker||'')),frame=current[0],m=frame?.marker?.match(/^desired_drinking_(same_as_desire_holder|explicit_content_subject)_([012])_open$/);
 const valid=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(current.length!==1||!m||frame.children?.length!==2||!valid.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(reader.observed.speech_act))throw new Error('Invalid desired drinking structure.');
 const holder=reader.role(frame.children[0],'experiencer','middle'),nested=frame.children[1];
 if(!['phonemic','deictic'].includes(holder.kind)||holder.property||holder.reference_mode==='nominal_class'||nested.marker!=='proposition_content_open')throw new Error('Invalid desire arguments.');
 const content=readDrinkingTree(nested.children,reader);
 if(m[1]==='same_as_desire_holder'&&JSON.stringify(holder)!==JSON.stringify(content.drinker))throw new Error('Invalid controlled drinker.');
 return {profile:'EZDESIRED-DRINKING-INVERSE-1',status:'draft',foundation_id:'FND:f66b7a3877f4b0140a0b7023',holder,content,content_status:'intensional',outcome_commitment:'desired_not_asserted',subject_binding:m[1],runtime_state:Number(m[2]),speech_act:reader.observed.speech_act,scopes};
}
