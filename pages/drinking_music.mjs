import {validateDrinkingMeaning,DRINKING_CONTRACT,DRINKING_VIEWPOINTS} from './drinking_meaning.mjs';
import {drinkingEvent} from './drinking_frames.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function drinkingMusicEvents(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateDrinkingMeaning(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'drinking',name);
 let events=[drinkingEvent(d.viewpoint,d.runtime_state,'open',anchor)];
 for(const [role,ref] of [['experiencer',d.drinker],['content',{...d.material.reference,value_type:'entity'}]])events.push(mark(`role_${role}_open`),...await renderLexicalOccurrences({nodes:[ref],edges:[]},authority,{anchor}),mark(`role_${role}_close`));
 events.push(drinkingEvent(d.viewpoint,d.runtime_state,'close',anchor));
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return events;
}
export function decodeDrinkingMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Drinking requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed drinking music.',{allowDraftDrinking:true});return readDrinkingTree(reader.readTree(),reader,reader.observed.speech_act);
}
export function readDrinkingTree(nodes,reader,speechAct='assertion'){
 const {current,scopes}=reader.unwrapScopes(n=>/^drinking_/.test(n.marker||''),nodes),frame=current[0],m=frame?.marker?.match(/^drinking_(ongoing|bounded|habitual)_([012])_open$/);
 const valid=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(current.length!==1||!m||frame.children?.length!==2||!valid.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(speechAct))throw new Error('Invalid drinking structure.');
 const drinker=reader.role(frame.children[0],'experiencer','middle'),reference=reader.role(frame.children[1],'content','middle');
 if(!['phonemic','deictic'].includes(drinker.kind)||drinker.property||drinker.reference_mode==='nominal_class'||reference.kind!=='phonemic'||reference.property||!['nominal_class','definite_nominal','proximal_nominal','distal_nominal'].includes(reference.reference_mode))throw new Error('Invalid drinking participants.');
 return {profile:'EZDRINKING-INVERSE-1',status:'draft',...DRINKING_CONTRACT,drinker,material:{reading:reference.reference_mode==='nominal_class'?'kind':'contextual_portion',reference,material_kind_commitment:'label_not_classification',quantity:'unspecified',whole_amount_consumption:'not_asserted',existence_commitment:'governed_by_enclosing_content'},viewpoint:m[1],viewpoint_contract:DRINKING_VIEWPOINTS[m[1]],runtime_state:Number(m[2]),speech_act:speechAct,scopes};
}

export async function midiFromDrinking(d,authority,options={}){return midiFromScheduledEvents(await drinkingMusicEvents(d,authority,options),options.anchor??60,d.speech_act==='question'?[0,2]:[0,0]);}
