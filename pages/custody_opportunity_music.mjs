import {validateCustodyOpportunity,CUSTODY_OPPORTUNITY_CONTRACT} from './custody_opportunity.mjs';
import {custodyOpportunityEvent} from './custody_opportunity_frames.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function custodyOpportunityMusicEvents(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateCustodyOpportunity(document,{allowDraft}),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'custody_opportunity',name);
 let events=[custodyOpportunityEvent(d.runtime_state,'open',anchor)];
 // In this convention the standard role identifies the access context.
 for(const [role,ref] of [['experiencer',d.prospective_holder],['content',d.resource],['comparison_standard',d.access_context]])events.push(mark(`role_${role}_open`),...await renderLexicalOccurrences({nodes:[ref],edges:[]},authority,{anchor}),mark(`role_${role}_close`));
 events.push(custodyOpportunityEvent(d.runtime_state,'close',anchor));
 for(const scope of [...d.scopes].reverse()){const key=scope.operator==='negation'?'negation':`time_${scope.relation}`;events=[mark(key+'_open'),...events,mark(key+'_close')];}
 return events;
}
export async function midiFromCustodyOpportunity(d,authority,options={}){return midiFromScheduledEvents(await custodyOpportunityMusicEvents(d,authority,options),options.anchor??60,d.speech_act==='question'?[0,2]:[0,0]);}
export function decodeCustodyOpportunityMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Custody opportunity requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed custody opportunity music.',{allowDraftCustodyOpportunity:true});return readCustodyOpportunityTree(reader.readTree(),reader,reader.observed.speech_act);
}
export function readCustodyOpportunityTree(nodes,reader,speechAct='assertion'){
 const {current,scopes}=reader.unwrapScopes(n=>/^custody_opportunity_/.test(n.marker||''),nodes),frame=current[0],m=frame?.marker?.match(/^custody_opportunity_([012])_open$/);
 const allowed=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(current.length!==1||!m||frame.children?.length!==3||!allowed.some(s=>JSON.stringify(s)===JSON.stringify(scopes))||!['assertion','question'].includes(speechAct))throw new Error('Invalid custody opportunity structure.');
 const prospective_holder=reader.role(frame.children[0],'experiencer','middle'),resource=reader.role(frame.children[1],'content','middle'),access_context=reader.role(frame.children[2],'comparison_standard','middle');
 for(const ref of [prospective_holder,resource,access_context])if(!['phonemic','deictic'].includes(ref.kind)||ref.property||ref.reference_mode==='nominal_class')throw new Error('Invalid custody opportunity reference.');
 if(access_context.kind!=='phonemic')throw new Error('Invalid custody opportunity access context.');
 if(JSON.stringify(prospective_holder)===JSON.stringify(resource))throw new Error('Custody opportunity requires distinct holder and resource.');
 return {profile:'EZCUSTODY-OPPORTUNITY-INVERSE-1',status:'draft',...CUSTODY_OPPORTUNITY_CONTRACT,prospective_holder,resource,access_context,speech_act:speechAct,scopes,runtime_state:Number(m[1])};
}
