import {PAIN_RELATIONS,validatePainStimulus} from './pain_stimulus.mjs';
import {painStimulusEvent} from './pain_stimulus_frames.mjs';
import {painMusicEvents,readPainTree} from './pain_music.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function midiFromPainStimulus(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validatePainStimulus(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'pain-stimulus',name);
 // Stimulus is a scoped content reference, in middle register; it is not an experiencer.
 let events=[painStimulusEvent(d.relation,d.runtime_state,'open',anchor),mark('role_content_open'),...await renderLexicalOccurrences({nodes:[d.stimulus],edges:[]},authority,{anchor}),mark('role_content_close'),...await painMusicEvents(d.outcome,authority,{allowDraft:true,anchor}),painStimulusEvent(d.relation,d.runtime_state,'close',anchor)];
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return midiFromScheduledEvents(events,anchor,d.speech_act==='question'?[0,2]:[0,0]);
}
export function decodePainStimulusMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Pain stimulus music requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed pain stimulus music.',{allowDraftPain:true,allowDraftPainStimulus:true});
 const {current,scopes}=reader.unwrapScopes(n=>/^pain_stimulus_/.test(n.marker||''));
 const valid=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 const frame=current[0],match=frame?.marker?.match(/^pain_stimulus_(actual_causation|expected_outcome|disposition)_([012])_open$/);
 if(current.length!==1||!match||frame.children?.length!==2||!valid.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(reader.observed.speech_act))throw new Error('Unsupported pain stimulus structure.');
 const stimulus=reader.role(frame.children[0],'content','middle');
 if(!['phonemic','deictic'].includes(stimulus.kind)||stimulus.property||stimulus.reference_mode==='nominal_class')throw new Error('Unsupported stimulus reference.');
 const outcome=readPainTree(frame.children[1],reader);
 return {profile:'EZPAIN-STIMULUS-INVERSE-1',status:'draft',relation:match[1],criterion:PAIN_RELATIONS[match[1]],stimulus,outcome,speech_act:reader.observed.speech_act,scopes,runtime_state:Number(match[2]),outcome_scope:'governed_by_relation_and_matrix_scope'};
}
