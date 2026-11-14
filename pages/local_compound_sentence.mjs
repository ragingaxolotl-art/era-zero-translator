import {localCompoundMusic} from './local_compound_music.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents,canonicalDigest} from './engine.mjs';
// Explicit scope order is outermost first: not(possible(P)) differs from
// possible(not(P)). No English interpretation is inferred by this API.
export async function composeLocalCompoundSentence(id,registry,authority,bindings,{runtimeState=1,anchor=60,scopes=[],speechAct='assertion'}={}){
 if(!['assertion','question'].includes(speechAct)||!Array.isArray(scopes)||scopes.length>16)throw new Error('Invalid sentence speech act or scopes.');
 const markers=scopes.map(scope=>{
  if(!scope||typeof scope!=='object'||Array.isArray(scope))throw new Error('Invalid sentence scope.');
  const keys=Object.keys(scope).sort().join(',');
  if(keys==='operator'&&scope.operator==='negation')return 'negation';
  if(keys==='operator,relation'&&scope.operator==='time'&&['before_speech','at_speech','after_speech'].includes(scope.relation))return `time_${scope.relation}`;
  if(keys==='mode,operator'&&scope.operator==='modality'&&['possible','necessary','permitted','obligated','intended','predicted','counterfactual'].includes(scope.mode))return `modality_${scope.mode}`;
  throw new Error('Unsupported sentence scope.');
 });
 const music=await localCompoundMusic(id,registry,authority,bindings,{runtimeState,anchor});
 const definition=music.registry.entries.find(e=>e.compound_id===id).definition;
 if(!['verb','adjective'].includes(definition.part_of_speech))throw new Error('Select an action or quality for sentence predication.');
 const meaning={profile:'EZLOCAL-SENTENCE-1',compound_id:id,definition,bindings:music.performance.bindings,runtime_state:runtimeState,scopes:structuredClone(scopes),speech_act:speechAct};
 const digest=await canonicalDigest(meaning),mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'local-sentence',name);
 let events=music.events;for(const marker of markers.reverse())events=[mark(marker+'_open'),...events,mark(marker+'_close')];
 return {profile:'EZLOCAL-SENTENCE-EXPORT-1',meaning,meaning_digest:digest,registry:music.registry,events,midi:midiFromScheduledEvents(events,anchor,speechAct==='question'?[0,2]:[0,0])};
}
