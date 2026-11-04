import {selectedContentEvents,readSelectedContent} from './content_selection.mjs';
import {canonicalDigest,midiFromScheduledEvents} from './engine.mjs';
import {UNDERSTANDING_READINGS,validateUnderstandingContent} from './understanding_content.mjs';
import {foundationPayload,validateFoundations,foundationEvent,foundationPath} from './foundations.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {contextualContentMusicEvent} from './contextual_content_frames.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function understandingFoundation(){
 const record={profile:'EZFOUND-1',definition_version:'1.0.0',family_affinity:'MIN',status:'candidate',review:'reviews/understanding_content.md',sound_code:3,display_title:'contextual content comprehension',definition:'The experiencer grasps the selected contextual content under its specific adequacy criterion. '+Object.values(UNDERSTANDING_READINGS).join(' '),roles:{experiencer:['entity'],content:['contextual_content']},excludes:['Attention, receipt, confidence or memorization alone treated as comprehension','Truth of communicated claims, shared feelings, approval, acquisition or permanent retention inferred from comprehension','A topic label used as a particular message or explanation']};
 const digest=await canonicalDigest(foundationPayload(record));return {...record,content_digest:digest,foundation_id:`FND:${digest.slice(0,24)}`};
}
export async function understandingMusicEvents(document,authority,{allowDraft=false,anchor=60}={}){
 const doc=await validateUnderstandingContent(document,{allowDraft}),record=await understandingFoundation();
 const formal={performance:{anchor_midi:anchor}},mark=name=>grammarMarker(formal,'understanding',name);
 const refs=async reference=>renderLexicalOccurrences({nodes:[reference],edges:[]},authority,{anchor});
 let events=[mark('role_experiencer_open'),...await refs(doc.experiencer),mark('role_experiencer_close'),mark('role_content_open'),contextualContentMusicEvent(doc.content.content_kind,'open',anchor),...selectedContentEvents(doc.content,await refs(doc.content.anchor),anchor),contextualContentMusicEvent(doc.content.content_kind,'close',anchor),mark('role_content_close'),await foundationEvent(record,{anchor,runtimeState:doc.runtime_state,allowDraft:true})];
 for(const scope of [...doc.scopes].reverse()){
  const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;
  events=[mark(`${key}_open`),...events,mark(`${key}_close`)];
 }
 return events;
}
export async function midiFromUnderstanding(document,authority,options={}){
 const doc=structuredClone(document),anchor=options.anchor??60;
 return midiFromScheduledEvents(await understandingMusicEvents(doc,authority,options),anchor,doc.speech_act==='question'?[0,2]:[0,0]);
}
export async function decodeUnderstandingMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Understanding music requires draft opt-in.');
 const record=await understandingFoundation();await validateFoundations([record],{allowDraft:true});
 const dictionary=[...atoms,{canonical_id:record.foundation_id,harmonic_signature_semitones:[0,3,7],note_path_semitones:foundationPath(record.sound_code)}];
 const fail=()=>{throw new Error('Unsupported or malformed understanding music.');};
 const reader=strictSemanticReader(bytes,dictionary,'Malformed understanding frame.',{allowDraftContextualContent:true}),{current,scopes}=reader.unwrapScopes(n=>n.kind==='root');
 if(!['assertion','question'].includes(reader.observed.speech_act)||current.length!==3)fail();
 const allowed=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(!allowed.some(s=>JSON.stringify(s)===JSON.stringify(scopes)))fail();
 const [holder,content,head]=current;
 if(![0,1,2].includes(head?.runtime_state))fail();reader.exactRoot(head,record.foundation_id,'middle',head.runtime_state);
 const experiencer=reader.role(holder,'experiencer','middle');
 if(content.marker!=='role_content_open'||content.children?.length!==1)fail();
 const frame=content.children[0],kind=Object.keys(UNDERSTANDING_READINGS).find(k=>frame.marker===`content_${k}_open`);if(!kind)fail();
 const selected=readSelectedContent(frame.children,kind,reader),reference=selected.anchor;
 for(const ref of [experiencer,reference])if(!['phonemic','deictic'].includes(ref.kind)||ref.property||ref.reference_mode==='nominal_class')fail();
 return {profile:'EZUNDERSTANDING-MUSIC-INVERSE-1',status:'draft',speech_act:reader.observed.speech_act,predicate:'content_comprehension',foundation_id:record.foundation_id,runtime_state:head.runtime_state,scopes,experiencer,content:{content_kind:kind,...selected,resolution_scope:'local_context',assertion_commitment:'none'},criterion:UNDERSTANDING_READINGS[kind],limitations:['Contextually selected content is not supplied or verified as a real-world fact.','No original spelling or external referent identity is recovered from phonemes.','Draft comprehension predicate; broader cognitive grammar and canonical admission remain open.']};
}
