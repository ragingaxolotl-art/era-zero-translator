import {validateLocalCompounds} from './local_compounds.mjs';
import {expandLocalCompound} from './local_compound_expansion.mjs';
import {localParticipantGroups} from './local_participant_groups.mjs';
import {localCompoundMusic} from './local_compound_music.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {notesFromMidi} from './performance_codec.mjs';

// The shared dictionary supplies the same pronunciation in every sentence.
// Numerals within it name definition slots. The outer story roles bind those
// slots to actual participants, including the noun this adjective describes.
async function prepare(entry,registry,authority){
  const id=entry.compound_id, label=entry.definition.label.toLowerCase();
  const expansion=await expandLocalCompound(id,registry,authority);
  const groups=localParticipantGroups(expansion,authority);
  const slots=groups.map(group=>{
    const row=group.find(r=>!r.path.length)||group[0];
    return {role:row.role,description:row.definition||row.role,bearer:group.some(r=>!r.path.length&&r.role==='bearer')};
  });
  const bindings=await Promise.all(groups.map(async(group,i)=>{
    const {path,slot_path,role}=group[0];
    return {path,slot_path,role,reference:await contextualContentReference('"'+(i+1)+'"')};
  }));
  const distinct=[];
  function visit(node){
    if(node.kind==='canonical_compound'){
      for(const rule of authority.compound_plans[node.target_id].expanded.binding_constraints||[]){
        if(rule.relation!=='distinct_arguments')continue;
        distinct.push(rule.slot_paths.map(slot=>groups.findIndex(group=>group.some(row=>
          JSON.stringify(row.path)===JSON.stringify(node.path)&&JSON.stringify(row.slot_path)===JSON.stringify(slot)))));
      }
    }
    for(const child of node.components||[])visit(child);
  }
  visit(expansion.tree);
  const music=await localCompoundMusic(id,registry,authority,bindings,{runtimeState:1});
  const {notes,division}=notesFromMidi(music.midi);
  return {id,label,parts:label.split(/\s+/),definition:entry.definition.definition,slots,distinct,events:music.events,
    // The final two notes are the standalone speech act, supplied by the outer sentence here.
    pattern:notes.slice(0,-2).map(n=>[n.midi-60,n.start_tick/division,n.end_tick/division])};
}

export async function storyAdjectiveLibrary(registry,authority,{text,cache=new Map()}={}){
  const checked=await validateLocalCompounds(registry,authority);
  const byId=new Map(),byCode=new Map(),byFirst=new Map(),byLabel=new Map();
  const source=text?.toLowerCase().replace(/\s+/g,' ');
  for(const entry of checked.entries){
    const label=entry.definition.label.toLowerCase();
    if(entry.definition.part_of_speech!=='adjective'||(source!==undefined&&!source.includes(label.replace(/\s+/g,' '))))continue;
    if(!cache.has(entry.compound_id))cache.set(entry.compound_id,prepare(entry,checked,authority).catch(error=>({
      id:entry.compound_id,label,parts:label.split(/\s+/),unavailable:error.message
    })));
    const adjective=await cache.get(entry.compound_id);
    byId.set(adjective.id,adjective);byLabel.set(label,adjective);
    if(!adjective.unavailable)byCode.set(adjective.id.slice(9,21),adjective);
    const first=adjective.parts[0],list=byFirst.get(first)||[];
    list.push(adjective);byFirst.set(first,list);
  }
  for(const list of byFirst.values())list.sort((a,b)=>b.parts.length-a.parts.length);
  return {byId,byCode,byFirst,byLabel};
}

let previous;
export async function storedStoryAdjectives(authority,text){
  let raw;
  try{raw=globalThis.localStorage?.getItem('era-zero-local-compounds-v1');}catch{return undefined;}
  if(!raw)return undefined;
  if(previous?.raw!==raw||previous.authority!==authority){
    // A broken private import must never prevent use of the public language.
    let registry;
    try{registry=await validateLocalCompounds(JSON.parse(raw),authority);}catch{return undefined;}
    previous={raw,authority,registry,cache:new Map()};
  }
  const {registry,cache}=previous;
  return storyAdjectiveLibrary(registry,authority,{text,cache});
}

export function validStorySlots(entry,bindings,bearer,entityCount){
  return bindings.length===entry.slots.length&&bindings.every((entity,i)=>
    Number.isInteger(entity)&&entity>=0&&entity<entityCount&&(!entry.slots[i].bearer||entity===bearer))&&
    entry.distinct.every(group=>new Set(group.map(i=>bindings[i])).size===group.length);
}

export function savedQualityLabel(value,library,entityLabel){
  const entry=library.byId.get(value.local_id);
  const participants=entry.slots.flatMap((slot,i)=>slot.bearer?[]:[slot.role+' = '+entityLabel(value.bindings[i])]);
  return entry.label+(participants.length?' ('+participants.join(', ')+')':'');
}
