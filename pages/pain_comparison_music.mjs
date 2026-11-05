import {validatePainComparison} from './pain_comparison.mjs';
import {painComparisonEvent} from './pain_comparison_frames.mjs';
import {painStimulusMusicEvents,readPainStimulusTree} from './pain_stimulus_music.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function painComparisonMusicEvents(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validatePainComparison(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'pain-comparison',name);
 let events=[painComparisonEvent(d.relation,d.runtime_state,'open',anchor),mark('role_content_open'),...await renderLexicalOccurrences({nodes:[d.context],edges:[]},authority,{anchor}),mark('role_content_close'),mark('role_target_open'),...await painStimulusMusicEvents(d.left,authority,{allowDraft:true,anchor}),mark('role_target_close'),mark('role_comparison_standard_open'),...await painStimulusMusicEvents(d.right,authority,{allowDraft:true,anchor}),mark('role_comparison_standard_close'),painComparisonEvent(d.relation,d.runtime_state,'close',anchor)];
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return events;
}
export function decodePainComparisonMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Pain comparison music requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed pain comparison music.',{allowDraftPain:true,allowDraftPainStimulus:true,allowDraftPainComparison:true});
 return readComparisonReader(reader);
}
function readComparisonReader(reader){
 const {current,scopes}=reader.unwrapScopes(n=>/^pain_comparison_/.test(n.marker||'')),frame=current[0],m=frame?.marker?.match(/^pain_comparison_(greater_than|less_than|equal)_([012])_open$/);
 const valid=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(current.length!==1||!m||frame.children?.length!==3||!valid.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(reader.observed.speech_act))throw new Error('Unsupported pain comparison structure.');
 const [contextFrame,l,r]=frame.children,context=reader.role(contextFrame,'content','middle');
 if(!['phonemic','deictic'].includes(context.kind)||context.property||context.reference_mode==='nominal_class'||l.marker!=='role_target_open'||r.marker!=='role_comparison_standard_open'||l.children?.length!==1||r.children?.length!==1)throw new Error('Invalid pain comparison arguments.');
 const left=readPainStimulusTree(l.children[0],reader),right=readPainStimulusTree(r.children[0],reader);
 if(left.relation!==right.relation||JSON.stringify(left.outcome.experiencer)!==JSON.stringify(right.outcome.experiencer))throw new Error('Incompatible pain comparison contexts.');
 return {profile:'EZPAIN-COMPARISON-INVERSE-1',status:'draft',dimension:'felt_bodily_pain_intensity',basis:'same_experiencer_and_selected_context',scale:'ordinal_no_numeric_score',operand_scope:'governed_by_comparison_and_matrix_scope',relation:m[1],left,right,context,speech_act:reader.observed.speech_act,scopes,runtime_state:Number(m[2])};
}

export async function midiFromPainComparison(document,authority,options={}){return midiFromScheduledEvents(await painComparisonMusicEvents(document,authority,options),options.anchor??60,document.speech_act==='question'?[0,2]:[0,0]);}

export function readPainComparisonTree(frame,reader){return readComparisonReader({...reader,observed:{speech_act:'assertion'},unwrapScopes:()=>({current:[frame],scopes:[]})});}
