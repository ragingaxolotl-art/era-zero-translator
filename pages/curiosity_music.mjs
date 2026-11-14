import {CURIOSITY_CONTRACT,validateCuriosity,validCuriosityScopes} from './curiosity.mjs';
import {curiosityEvent} from './curiosity_frames.mjs';
import {contextualInquiryEvent} from './contextual_inquiry_frames.mjs';
import {contextualContentMusicEvent} from './contextual_content_frames.mjs';
import {foundationEvent,foundationPath,validateFoundations} from './foundations.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
import {readSelectedContent} from './content_selection.mjs';
async function desireRecord(records){await validateFoundations(records,{allowDraft:true});const r=records.find(r=>r.foundation_id===CURIOSITY_CONTRACT.desire_foundation_id);if(!r)throw new Error('Shared original desire definition required.');return r;}
export async function midiFromCuriosity(document,authority,records,{allowDraft=false,anchor=60}={}){
 const d=await validateCuriosity(document,{allowDraft}),record=await desireRecord(records),formal={performance:{anchor_midi:anchor}};
 const marker=name=>grammarMarker(formal,'curiosity',name),reference=ref=>renderLexicalOccurrences({nodes:[ref],edges:[]},authority,{anchor});
 let events=[curiosityEvent('open',anchor),marker('role_experiencer_open'),...await reference(d.experiencer),marker('role_experiencer_close'),marker('role_content_open'),contextualInquiryEvent('open',anchor),contextualContentMusicEvent('topic','open',anchor),...await reference(d.inquiry.topic.anchor),contextualContentMusicEvent('topic','close',anchor),contextualInquiryEvent('close',anchor),marker('role_content_close'),await foundationEvent(record,{anchor,runtimeState:d.runtime_state,allowDraft:true}),curiosityEvent('close',anchor)];
 for(const s of [...d.scopes].reverse()){const key=s.operator==='negation'?'negation':`time_${s.relation}`;events=[marker(key+'_open'),...events,marker(key+'_close')];}
 return midiFromScheduledEvents(events,anchor,d.speech_act==='question'?[0,2]:[0,0]);
}
export async function decodeCuriosityMidi(bytes,atoms,records,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Curiosity requires draft opt-in.');
 const r=await desireRecord(records),dictionary=[...atoms,{canonical_id:r.foundation_id,harmonic_signature_semitones:[0,3,7],note_path_semitones:foundationPath(r.sound_code)}];
 const reader=strictSemanticReader(bytes,dictionary,'Malformed curiosity music.',{allowDraftCuriosity:true,allowDraftContextualInquiry:true,allowDraftContextualContent:true}),{current,scopes}=reader.unwrapScopes(n=>n.marker==='epistemic_curiosity_open');
 const fail=()=>{throw new Error('Unsupported curiosity structure.');};
 if(!validCuriosityScopes(scopes)||!['assertion','question'].includes(reader.observed.speech_act)||current.length!==1||current[0].marker!=='epistemic_curiosity_open'||current[0].children?.length!==3)fail();
 const [holder,content,head]=current[0].children,experiencer=reader.role(holder,'experiencer','middle');
 if(!['phonemic','deictic'].includes(experiencer.kind)||experiencer.property||experiencer.reference_mode==='nominal_class'||content.marker!=='role_content_open'||content.children?.length!==1||content.children[0].marker!=='contextual_inquiry_open')fail();
 const inquiry=content.children[0];if(inquiry.children?.length!==1||inquiry.children[0].marker!=='content_topic_open'||![0,1,2].includes(head.runtime_state))fail();reader.exactRoot(head,r.foundation_id,'middle',head.runtime_state);
 const topic=readSelectedContent(inquiry.children[0].children,'topic',reader);
 return {profile:'EZCURIOSITY-INVERSE-1',status:'draft',...CURIOSITY_CONTRACT,experiencer,inquiry:{content_kind:'contextual_question_set',topic,question_selection:'contextually_relevant_unresolved',answer_commitment:'none',specific_question_supplied:false},speech_act:reader.observed.speech_act,scopes,runtime_state:head.runtime_state,limitations:['Context must identify the topic and relevant questions.','This draft epistemic reading is not oddness, sensory novelty seeking or purely instrumental information demand.']};
}
