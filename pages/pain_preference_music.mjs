import {validatePainPreference} from './pain_preference.mjs';
import {painPreferenceEvent} from './pain_preference_frames.mjs';
import {painComparisonMusicEvents,readPainComparisonTree} from './pain_comparison_music.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function midiFromPainPreference(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validatePainPreference(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'pain-preference',name);
 let events=[painPreferenceEvent(d.runtime_state,'open',anchor)];
 for(const [role,ref] of [['experiencer',d.holder],['target',d.target],['comparison_standard',d.comparison_standard]])events.push(mark(`role_${role}_open`),...await renderLexicalOccurrences({nodes:[ref],edges:[]},authority,{anchor}),mark(`role_${role}_close`));
 // The profile makes this a reference restriction, not another matrix assertion.
 events.push(...await painComparisonMusicEvents(d.pain_comparison,authority,{allowDraft:true,anchor}),painPreferenceEvent(d.runtime_state,'close',anchor));
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return midiFromScheduledEvents(events,anchor,d.speech_act==='question'?[0,2]:[0,0]);
}
export function decodePainPreferenceMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Pain preference requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed pain preference music.',{allowDraftPain:true,allowDraftPainStimulus:true,allowDraftPainComparison:true,allowDraftPainPreference:true});
 const {current,scopes}=reader.unwrapScopes(n=>/^pain_preference_/.test(n.marker||'')),frame=current[0],m=frame?.marker?.match(/^pain_preference_([012])_open$/);
 const valid=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(current.length!==1||!m||frame.children?.length!==4||!valid.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(reader.observed.speech_act))throw new Error('Invalid preference structure.');
 const [h,t,s,c]=frame.children,holder=reader.role(h,'experiencer','middle'),target=reader.role(t,'target','middle'),comparison_standard=reader.role(s,'comparison_standard','middle'),pain_comparison=readPainComparisonTree(c,reader);
 for(const ref of [holder,target,comparison_standard])if(!['phonemic','deictic'].includes(ref.kind)||ref.property||ref.reference_mode==='nominal_class')throw new Error('Invalid preference reference.');
 const same=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
 const forward=same(pain_comparison.left.stimulus,target)&&same(pain_comparison.right.stimulus,comparison_standard),reverse=same(pain_comparison.left.stimulus,comparison_standard)&&same(pain_comparison.right.stimulus,target);
 if(pain_comparison.relation!=='greater_than'||forward===reverse)throw new Error('Ambiguous or invalid preference restriction binding.');
 return {profile:'EZPAIN-PREFERENCE-INVERSE-1',status:'draft',foundation_id:'FND:018dd25d713dff83661a76a4',holder,target,comparison_standard,pain_comparison,more_painful_role:forward?'target':'comparison_standard',restriction_scope:'reference_descriptions_not_preference_polarity',speech_act:reader.observed.speech_act,scopes,runtime_state:Number(m[1])};
}
