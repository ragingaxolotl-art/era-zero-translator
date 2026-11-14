import {PAIN_CONTRACT,validatePainMeaning} from './pain_meaning.mjs';
import {painEvent} from './pain_frames.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
import {readFeltConditionTree} from './felt_decoder.mjs';
export async function painMusicEvents(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validatePainMeaning(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'pain',name);
 const experiencer={...d.experiencer,node_id:'experiencer'};
 const ir={nodes:[experiencer,{node_id:'pain-base',kind:'lexical_occurrence',target_type:'compound',target_id:d.dependency,runtime_state:{code:d.runtime_state},compound_bindings:[{slot_path:['s-experiencer'],argument_id:'experiencer'}]}],edges:[]};
 const base=await renderLexicalOccurrences(ir,authority,{anchor}),conscious=base.findIndex(e=>e.target_id==='LIF:001');
 if(conscious<2||base[0].marker!=='convention_11_open')throw new Error('Unexpected felt dependency layout.');
 let events=[painEvent('open',anchor),base[0],mark('role_experiencer_open'),...base.slice(1,conscious),mark('role_experiencer_close'),...base.slice(conscious),painEvent('close',anchor)];
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return events;
}
export async function midiFromPain(document,authority,options={}){const d=await validatePainMeaning(document,options);return midiFromScheduledEvents(await painMusicEvents(d,authority,options),options.anchor??60,d.speech_act==='question'?[0,2]:[0,0]);}
export function readPainTree(node,reader){
 if(node?.marker!=='felt_bodily_pain_open'||node.children?.length!==1||node.children[0].marker!=='convention_11_open')throw new Error('Unsupported pain content.');
 const base=readFeltConditionTree(node.children[0],reader),experiencer=base.participants.experiencer;
 if(!['phonemic','deictic'].includes(experiencer.kind)||experiencer.property||experiencer.reference_mode==='nominal_class')throw new Error('Unsupported pain experiencer.');
 return {...PAIN_CONTRACT,experiencer,runtime_state:base.runtime_state};
}
export function decodePainMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Pain music requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed pain music.',{allowDraftPain:true});
 const {current,scopes}=reader.unwrapScopes(n=>n.marker==='felt_bodily_pain_open');
 const valid=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(!valid.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(reader.observed.speech_act)||current.length!==1||current[0].marker!=='felt_bodily_pain_open'||current[0].children?.length!==1||current[0].children[0].marker!=='convention_11_open')throw new Error('Unsupported pain music structure.');
 const base=readFeltConditionTree(current[0].children[0],reader),experiencer=base.participants.experiencer;
 if(!['phonemic','deictic'].includes(experiencer.kind)||experiencer.property||experiencer.reference_mode==='nominal_class')throw new Error('Unsupported pain experiencer.');
 return {profile:'EZPAIN-INVERSE-1',status:'draft',...PAIN_CONTRACT,experiencer,speech_act:reader.observed.speech_act,scopes,runtime_state:base.runtime_state};
}
