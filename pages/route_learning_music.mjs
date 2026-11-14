import {canonicalDigest,midiFromScheduledEvents} from './engine.mjs';
import {ROUTE_LEARNING_READINGS,validateRouteLearning} from './route_learning.mjs';
import {foundationPayload,validateFoundations,foundationPath} from './foundations.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {scheduledLexicalEvents,grammarMarker} from './scheduler.mjs';
import {acquisitionMusicEvent} from './acquisition_music_frames.mjs';
import {acquisitionScopeMarker,validAcquisitionScopes} from './acquisition_scopes.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function routeLearningFoundations(){
 return Promise.all(Object.entries(ROUTE_LEARNING_READINGS).map(async([reading,r],i)=>{
  const record={profile:'EZFOUND-1',definition_version:'1.0.0',family_affinity:'MIN',status:'candidate',review:'reviews/route_learning.md',sound_code:4+i,display_title:r.predicate,definition:r.definition,roles:{experiencer:['entity'],target:['entity']},excludes:[...r.excludes]};
  const digest=await canonicalDigest(foundationPayload(record));return {...record,content_digest:digest,foundation_id:`FND:${digest.slice(0,24)}`};
 }));
}
export async function routeLearningResultFormal(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateRouteLearning(document,{allowDraft}),r=d.result_state,records=await routeLearningFoundations(),record=records.find(x=>x.display_title===r.predicate);
 const ir={ir_version:'1.0.0',root_clause:'c',speech_act:'assertion',nodes:[{node_id:'c',kind:'clause',clause_type:'simple'},{node_id:'p',kind:'lexical_occurrence',target_type:'foundation',target_id:record.foundation_id,foundation_version:record.definition_version,runtime_state:{code:r.runtime_state}},{...r.experiencer,node_id:'holder'},{...r.route,node_id:'route'}],edges:[{edge_id:'center',type:'centers',from:'p',to:'c'},{edge_id:'holder',type:'fills_role',from:'holder',to:'p',role:'experiencer'},{edge_id:'route',type:'fills_role',from:'route',to:'p',role:'target'}],discourse_constraints:{}};
 const events=await renderLexicalOccurrences(ir,authority,{anchor,foundationRecords:records,allowDraftFoundations:true});
 return {semantic_ir:ir,performance:{anchor_midi:anchor,lexical_events:events}};
}
export async function midiFromRouteLearning(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateRouteLearning(document,{allowDraft}),formal=await routeLearningResultFormal(d,authority,{allowDraft:true,anchor});
 const [transition]=await renderLexicalOccurrences({nodes:[{node_id:'acquisition',kind:'lexical_occurrence',target_type:'atom',target_id:'ORI:110',runtime_state:{code:d.transition_runtime}}],edges:[]},authority,{anchor});
 let events=[acquisitionMusicEvent('route_learning_open',anchor),acquisitionMusicEvent('acquisition_result_open',anchor),...scheduledLexicalEvents(formal),acquisitionMusicEvent('acquisition_result_close',anchor),transition,acquisitionMusicEvent('route_learning_close',anchor)];
 for(const scope of [...d.event_scopes].reverse())events=[grammarMarker(formal,'acquisition',acquisitionScopeMarker(scope,'open')),...events,grammarMarker(formal,'acquisition',acquisitionScopeMarker(scope,'close'))];
 return midiFromScheduledEvents(events,anchor,d.speech_act==='question'?[0,2]:[0,0]);
}
export async function decodeRouteLearningMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Route-learning music requires draft opt-in.');
 const records=await routeLearningFoundations();await validateFoundations(records,{allowDraft:true});
 const dictionary=[...atoms,...records.map(r=>({canonical_id:r.foundation_id,harmonic_signature_semitones:[0,3,7],note_path_semitones:foundationPath(r.sound_code)}))];
 const reader=strictSemanticReader(bytes,dictionary,'Malformed route-learning music.',{allowDraftAcquisition:true}),{current,scopes}=reader.unwrapScopes(n=>n.marker==='route_learning_open'),fail=()=>{throw new Error('Unsupported route-learning structure.');};
 if(!['assertion','question'].includes(reader.observed.speech_act)||!validAcquisitionScopes(scopes.map(s=>s.operator==='negation'?'negation':s.operator==='time'?s.relation:'invalid'))||current.length!==1||current[0].children?.length!==2)fail();
 const [result,transition]=current[0].children;if(result.marker!=='acquisition_result_open'||result.children?.length!==3||![0,1,2].includes(transition.runtime_state))fail();reader.exactRoot(transition,'ORI:110','middle',transition.runtime_state);
 const [holder,target,head]=result.children,record=records.find(r=>r.foundation_id===head?.root_id);if(!record||![0,1,2].includes(head.runtime_state))fail();reader.exactRoot(head,record.foundation_id,'middle',head.runtime_state);
 const experiencer=reader.role(holder,'experiencer','middle'),route=reader.role(target,'target','high');
 if(!['phonemic','deictic'].includes(experiencer.kind)||experiencer.property||experiencer.reference_mode==='nominal_class'||route.kind!=='phonemic'||route.property||!['definite_nominal','proximal_nominal','distal_nominal'].includes(route.reference_mode))fail();
 // A noun label is not an independently verified route; predicate semantics
 // supplies its role. Do not require spelling recovery from phonemes.
 const reading=Object.keys(ROUTE_LEARNING_READINGS).find(k=>ROUTE_LEARNING_READINGS[k].predicate===record.display_title);
 return {profile:'EZROUTE-LEARNING-INVERSE-1',status:'draft',speech_act:reader.observed.speech_act,transition_root:'ORI:110',transition_runtime:transition.runtime_state,scopes,result_assertion:'at_culmination_only',phase_contract:{before:'does_not_hold',culmination:'holds',after:'unspecified'},result_state:{reading,predicate:record.display_title,criterion:record.definition,experiencer,route,runtime_state:head.runtime_state,content_commitment:reading==='memorization'?'representation_without_truth_assertion':'contextual_route_reference'},limitations:['Context must resolve the route and relevant represented information or criterion.','No actual traversal, permanent retention or external referent identity is established.','Candidate result meanings are not canonical vocabulary admission.']};
}
