import {prepareLocalCompoundPerformance} from './local_compound_performance.mjs';
import {grammarMarker} from './scheduler.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {validateLocalCompounds} from './local_compounds.mjs';
// Local-only namespace ±39/19. The portable registry supplies definitions.
// 48-bit identifiers are checked for collisions across that registry.
export function localCompoundFrame(id,relation,side,anchor=60){
 if(!/^LOCALCMP:[a-f0-9]{64}$/.test(id)||!['head','qualifies'].includes(relation)||!['open','close'].includes(side)||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid local compound frame.');
 const trits=BigInt('0x'+id.slice(9,21)).toString(3).padStart(31,'0').split('').map(t=>[0,1,-1][Number(t)]);
 const path=[0,side==='open'?-39:39,19,relation==='head'?0:1,...trits,0];
 return {kind:'grammar_marker',grammar_profile:'EZLOCAL-COMPOUND-MUSIC-1',marker:`local_compound_${side}`,target_id:id,relation,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:path.map(n=>n+anchor),note_duration_beats:.25,boundary_after_beats:.5};
}
export async function localCompoundMusic(id,registry,authority,bindings,options={}){
 const checked=await validateLocalCompounds(registry,authority),codes=new Set();
 for(const entry of checked.entries){const code=entry.compound_id.slice(9,21);if(codes.has(code))throw new Error('Local musical identifier collision; export requires distinct identifiers.');codes.add(code);}
 const prepared=await prepareLocalCompoundPerformance(id,checked,authority,bindings,options),anchor=prepared.anchor;
 const mark=name=>grammarMarker({performance:{anchor_midi:anchor}},'local-compound',name);
 function walk(node){
  if(node.kind!=='local_compound')return node.events;
  return [localCompoundFrame(node.target_id,node.relation,'open',anchor),...node.participants.flatMap(p=>[mark(`role_${p.role}_open`),...p.events,mark(`role_${p.role}_close`)]),...node.components.flatMap(walk),localCompoundFrame(node.target_id,node.relation,'close',anchor)];
 }
 const events=walk(prepared.tree);
 return {profile:'EZLOCAL-COMPOUND-EXPORT-1',registry:checked,performance:prepared,events,midi:midiFromScheduledEvents(events,anchor,[0,0])};
}
