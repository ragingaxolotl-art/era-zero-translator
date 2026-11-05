import {validateUnderstandingAcquisition} from './understanding_acquisition.mjs';
import {understandingMusicEvents,understandingFoundation,readUnderstandingTree} from './understanding_music.mjs';
import {foundationPath} from './foundations.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {acquisitionMusicEvent} from './acquisition_music_frames.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {validAcquisitionScopes,acquisitionScopeMarker} from './acquisition_scopes.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function midiFromUnderstandingAcquisition(input,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateUnderstandingAcquisition(input,{allowDraft}),formal={performance:{anchor_midi:anchor}};
 const [head]=await renderLexicalOccurrences({nodes:[{node_id:'acquisition',kind:'lexical_occurrence',target_type:'atom',target_id:'ORI:110',runtime_state:d.transition_runtime}],edges:[]},authority,{anchor});
 let events=[acquisitionMusicEvent('understanding_acquisition_open',anchor),acquisitionMusicEvent('acquisition_result_open',anchor),...await understandingMusicEvents(d.result_state,authority,{allowDraft:true,anchor}),acquisitionMusicEvent('acquisition_result_close',anchor),head,acquisitionMusicEvent('understanding_acquisition_close',anchor)];
 for(const scope of [...d.event_scopes].reverse())events=[grammarMarker(formal,'acquisition',acquisitionScopeMarker(scope,'open')),...events,grammarMarker(formal,'acquisition',acquisitionScopeMarker(scope,'close'))];
 return midiFromScheduledEvents(events,anchor,d.speech_act==='question'?[0,2]:[0,0]);
}
export async function decodeUnderstandingAcquisitionMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Understanding acquisition requires draft opt-in.');
 const record=await understandingFoundation(),dictionary=[...atoms,{canonical_id:record.foundation_id,harmonic_signature_semitones:[0,3,7],note_path_semitones:foundationPath(record.sound_code)}];
 const reader=strictSemanticReader(bytes,dictionary,'Malformed comprehension acquisition music.',{allowDraftAcquisition:true,allowDraftContextualContent:true}),{current,scopes}=reader.unwrapScopes(n=>n.marker==='understanding_acquisition_open');
 const fail=()=>{throw new Error('Unsupported comprehension acquisition music.');};
 if(!['assertion','question'].includes(reader.observed.speech_act)||!validAcquisitionScopes(scopes.map(s=>s.operator==='negation'?'negation':s.operator==='time'?s.relation:'invalid'))||current.length!==1||current[0].children?.length!==2)fail();
 const [result,head]=current[0].children;if(result.marker!=='acquisition_result_open'||![0,1,2].includes(head.runtime_state))fail();reader.exactRoot(head,'ORI:110','middle',head.runtime_state);
 return {profile:'EZUNDERSTANDING-ACQUISITION-INVERSE-1',status:'draft',speech_act:reader.observed.speech_act,transition_root:'ORI:110',transition_runtime:head.runtime_state,scopes,result_assertion:'at_culmination_only',phase_contract:{before:'does_not_hold',culmination:'holds',after:'unspecified'},result:readUnderstandingTree(result.children,[],'assertion',reader,record),limitations:['Draft completed transition; not an assertion of understanding at speech time or permanent retention.','Content source restrictions are retained, without fabricating the referenced speech or its truth.']};
}
