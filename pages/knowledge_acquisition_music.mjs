import {validateKnowledgeAcquisition} from './knowledge_acquisition.mjs';
import {canonicalDigest,midiFromScheduledEvents} from './engine.mjs';
import {acquisitionScopeMarker} from './acquisition_scopes.mjs';
import {scheduledLexicalEvents,grammarMarker} from './scheduler.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {acquisitionMusicEvent} from './acquisition_music_frames.mjs';
export async function knowledgeAcquisitionEvents(input,formal,authority,{allowDraft=false}={}){
 formal=structuredClone(formal);const document=await validateKnowledgeAcquisition(input,{allowDraft});
 if(await canonicalDigest(document.result_state)!==await canonicalDigest(formal.semantic_ir)||formal.semantic_digest!==document.result_state.serialization.content_digest)throw new Error('Acquisition result/formal mismatch.');
 const anchor=formal.performance.anchor_midi;
 const [transition]=await renderLexicalOccurrences({nodes:[{node_id:'acquisition',kind:'lexical_occurrence',target_type:'atom',target_id:'ORI:110',runtime_state:document.transition_runtime}],edges:[]},authority,{anchor});
 let events=[acquisitionMusicEvent('knowledge_acquisition_open',anchor),acquisitionMusicEvent('acquisition_result_open',anchor),...scheduledLexicalEvents(formal),acquisitionMusicEvent('acquisition_result_close',anchor),transition,acquisitionMusicEvent('knowledge_acquisition_close',anchor)];
 for(const scope of [...document.event_scopes].reverse())events=[grammarMarker(formal,'acquisition',acquisitionScopeMarker(scope,'open')),...events,grammarMarker(formal,'acquisition',acquisitionScopeMarker(scope,'close'))];
 return events;
}
export async function midiFromKnowledgeAcquisition(document,formal,authority,options){
 const snapshot=structuredClone(formal),content=structuredClone(document),events=await knowledgeAcquisitionEvents(content,snapshot,authority,options);
 return midiFromScheduledEvents(events,snapshot.performance.anchor_midi,content.speech_act==='question'?[0,2]:[0,0]);
}
