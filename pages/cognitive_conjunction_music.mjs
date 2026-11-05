import {validateCognitiveConjunction,validCognitiveOuterScopes} from './cognitive_conjunction.mjs';
import {midiFromCuriosity} from './curiosity_music.mjs';
import {midiFromUnderstanding,understandingFoundation} from './understanding_music.mjs';
import {midiFromUnderstandingAcquisition} from './understanding_acquisition_music.mjs';
import {midiFromRouteLearning,routeLearningFoundations} from './route_learning_music.mjs';
import {notesFromMidi} from './performance_codec.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {grammarMarker} from './scheduler.mjs';
import {decodeStrictMusicMidi} from './strict_music_decoder.mjs';
import {foundationPath,validateFoundations} from './foundations.mjs';
function eventsFromNotes(notes,division){return notes.map((n,i)=>({family_opening_absolute_midi:[],address_absolute_midi:[n.midi],note_duration_beats:(n.end_tick-n.start_tick)/division,boundary_after_beats:i+1<notes.length?(notes[i+1].start_tick-n.end_tick)/division:.5}));}
export async function midiFromCognitiveConjunction(document,authority,records,{allowDraft=false,anchor=60}={}){
 const d=await validateCognitiveConjunction(document,{allowDraft}),formal={performance:{anchor_midi:anchor}},marker=name=>grammarMarker(formal,'conjunction',name),events=[marker('coord_all_of_open')];
 for(const [i,member] of d.members.entries()){
  const options={allowDraft:true,anchor};let bytes;
  if(member.profile==='EZCURIOSITY-1')bytes=await midiFromCuriosity(member,authority,records,options);
  else bytes=await ({'EZUNDERSTANDING-CONTENT-1':midiFromUnderstanding,'EZUNDERSTANDING-ACQUISITION-1':midiFromUnderstandingAcquisition,'EZROUTE-LEARNING-1':midiFromRouteLearning}[member.profile])(member,authority,options);
  const {notes,division}=notesFromMidi(bytes);if(i)events.push(marker('coord_member'));events.push(...eventsFromNotes(notes.slice(0,-2),division));
 }
 events.push(marker('coord_all_of_close'));for(const scope of [...(d.scopes||[])].reverse()){const key=scope.operator==='negation'?'negation':'modality_possible';events.unshift(marker(key+'_open'));events.push(marker(key+'_close'));}return midiFromScheduledEvents(events,anchor,d.speech_act==='question'?[0,2]:[0,0]);
}
export async function decodeCognitiveConjunctionMidi(bytes,atoms,records,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Cognitive conjunction requires draft opt-in.');
 const foundations=[...records,await understandingFoundation(),...await routeLearningFoundations()];await validateFoundations(foundations,{allowDraft:true});
 const dictionary=[...atoms,...foundations.map(r=>({canonical_id:r.foundation_id,harmonic_signature_semitones:[0,3,7],note_path_semitones:foundationPath(r.sound_code)}))];
 const observed=decodeStrictMusicMidi(bytes,dictionary,{allowDraftAcquisition:true,allowDraftContextualContent:true,allowDraftContextualInquiry:true,allowDraftCuriosity:true}),tokens=observed.tokens;
 let body=tokens,scopes;const outer=[];
 while(['negation_open','modality_possible_open'].includes(body[0]?.marker)&&body[0].closing_token===tokens.indexOf(body.at(-1))){outer.push(body[0].marker==='negation_open'?{operator:'negation'}:{operator:'modality',mode:'possible'});body=body.slice(1,-1);}
 if(outer.length){if(!validCognitiveOuterScopes(outer))throw new Error('Unsupported conjunction scope.');scopes=outer;}
 if(!['assertion','question'].includes(observed.speech_act)||body[0]?.marker!=='coord_all_of_open'||body[0].closing_token!==tokens.indexOf(body.at(-1)))throw new Error('Expected a complete assertion or question over the conjunction.');
 const groups=[[]];
 for(const token of body.slice(1,-1)){if(token.marker==='coord_member'&&token.enclosing_scopes.length===body[0].enclosing_scopes.length)groups.push([]);else groups.at(-1).push(token);}
 if(groups.length<2||groups.length>8||groups.some(g=>!g.length))throw new Error('Invalid conjunction member count.');
 const {notes,division}=notesFromMidi(bytes),{decodeSupportedMeaningWithDrafts}=await import('./semantic_music_dispatch.mjs'),members=[];
 const profiles=['EZCURIOSITY-INVERSE-1','EZUNDERSTANDING-MUSIC-INVERSE-1','EZUNDERSTANDING-ACQUISITION-INVERSE-1','EZROUTE-LEARNING-INVERSE-1'];
 for(const group of groups){
  const segment=notes.filter(n=>n.start_tick>=group[0].start_tick&&n.end_tick<=group.at(-1).end_tick);
  const reconstructed=midiFromScheduledEvents(eventsFromNotes(segment,division),observed.anchor_midi,[0,0]);
  const meaning=await decodeSupportedMeaningWithDrafts(reconstructed,atoms,records,{allowDraft:true,allowConjunction:false});
  if(!profiles.includes(meaning.profile))throw new Error('Unsupported cognitive member.');members.push(meaning);
 }
 return {profile:'EZCOGNITIVE-CONJUNCTION-INVERSE-1',status:'draft',operator:'all_of',speech_act:observed.speech_act,members,...(scopes?{scopes}:{}),limitations:['No temporal order or causal relationship is asserted between members.','Shared reference sounds do not establish external identity; each member retains its own contextual references.']};
}
