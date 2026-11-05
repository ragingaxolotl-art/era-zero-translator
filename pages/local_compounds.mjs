// User definitions are separate from the approved dictionary. This module stores
// meaning and ordered dependencies; it does not claim to compile performances.
import {canonicalDigest} from './engine.mjs';
import {ROLE_ORDER} from './roles.mjs';
const PROFILE='EZLOCAL-COMPOUNDS-1';
const fail=message=>{throw new Error(`Local compound: ${message}`)};
const exact=(value,keys)=>value&&typeof value==='object'&&!Array.isArray(value)&&Object.keys(value).length===keys.length&&keys.every(k=>Object.hasOwn(value,k));
const text=value=>typeof value==='string'&&value.trim()===value&&value.length>0&&value.length<=4000;
export const emptyLocalCompounds=()=>({profile:PROFILE,entries:[]});
function checkDefinition(d,known,definitions,authority){
 if(!exact(d,['label','definition','part_of_speech','components','roles',...(Object.hasOwn(d||{},'english_forms')?['english_forms']:[]),...(Object.hasOwn(d||{},'role_links')?['role_links']:[])]))fail('invalid definition fields');
 if(!text(d.label)||!text(d.definition)||!['noun','verb','adjective','adverb'].includes(d.part_of_speech))fail('provide a label, definition and part of speech');
 if(d.english_forms!==undefined&&(d.part_of_speech!=='verb'||!exact(d.english_forms,['third_person','past'])||!Object.values(d.english_forms).every(v=>text(v)&&/^[a-z]+(?: [a-z]+)*$/.test(v))))fail('provide lowercase third-person and past verb forms');
 if(!Array.isArray(d.components)||d.components.length<2||d.components.length>64)fail('use 2–64 ordered components');
 if(d.components.filter(c=>c?.relation==='head').length!==1)fail('choose exactly one semantic head');
 for(const c of d.components){
  if(!exact(c,['target_id','relation'])||!['head','qualifies'].includes(c.relation)||!known.has(c.target_id))fail('unknown dependency or component relationship');
 }
 if(!Array.isArray(d.roles)||d.roles.length>ROLE_ORDER.length)fail('invalid roles');
 const roles=new Set();for(const r of d.roles){
  if(!exact(r,['role','definition'])||!ROLE_ORDER.includes(r.role)||!text(r.definition)||roles.has(r.role))fail('roles need distinct supported names and definitions');roles.add(r.role);
 }
 if(d.role_links!==undefined){
  if(!Array.isArray(d.role_links)||d.role_links.length>128)fail('invalid role connections');
  const targets=new Set();
  for(const link of d.role_links){
   if(!exact(link,['outer_role','component_path','role',...(Object.hasOwn(link||{},'slot_path')?['slot_path']:[])])||!roles.has(link.outer_role)||!Array.isArray(link.component_path)||!link.component_path.length||!link.component_path.every(i=>Number.isInteger(i)&&i>=0))fail('invalid role connection');
   let definition=d,target;
   for(const index of link.component_path){if(!definition?.components?.[index])fail('unknown role connection path');target=definition.components[index].target_id;definition=definitions.get(target);}
   const identity=JSON.stringify([link.component_path,link.slot_path??null,link.role]);if(targets.has(identity))fail('duplicate role connection');targets.add(identity);
   if(definition){if(link.slot_path!==undefined||!definition.roles.some(r=>r.role===link.role))fail('unknown nested local role');}
   else {
    const plan=authority.compound_plans?.[target],slot=plan?.expanded.nodes.find(n=>n.kind==='slot'&&JSON.stringify(n.path)===JSON.stringify(link.slot_path));
    if(!slot||slot.slot_type!=='entity'||!plan.expanded.edges.some(e=>e.type==='fills_role'&&e.role===link.role&&JSON.stringify(e.from_path)===JSON.stringify(link.slot_path)))fail('unknown canonical participant slot');
   }
  }
 }

}
export async function validateLocalCompounds(registry,authority){
 if(!exact(registry,['profile','entries'])||registry.profile!==PROFILE||!Array.isArray(registry.entries)||registry.entries.length>1000)fail('invalid registry');
 const known=new Set([...authority.atoms.map(a=>a.canonical_id),...authority.compounds.filter(c=>c.status==='approved').map(c=>c.compound_id)]),labels=new Set(),definitions=new Map();
 for(const entry of registry.entries){
  if(!exact(entry,['compound_id','content_digest','definition']))fail('invalid entry fields');
  checkDefinition(entry.definition,known,definitions,authority);
  const digest=await canonicalDigest(entry.definition);
  if(entry.content_digest!==digest||entry.compound_id!==`LOCALCMP:${digest}`||known.has(entry.compound_id))fail('invalid or duplicate identity');
  const label=entry.definition.label.toLocaleLowerCase('en');if(labels.has(label))fail('duplicate local label');labels.add(label);
  // Dependencies must already exist: this rejects forward edges and cycles and
  // makes every saved definition usable by subsequently authored compounds.
  known.add(entry.compound_id);definitions.set(entry.compound_id,entry.definition);
 }
 return structuredClone(registry);
}
export async function addLocalCompound(registry,definition,authority){
 const result=await validateLocalCompounds(registry,authority),digest=await canonicalDigest(definition);
 result.entries.push({compound_id:`LOCALCMP:${digest}`,content_digest:digest,definition:structuredClone(definition)});
 return validateLocalCompounds(result,authority);
}
export async function saveLocalCompounds(storage,registry,authority){
 const checked=await validateLocalCompounds(registry,authority);
 storage.setItem('era-zero-local-compounds-v1',JSON.stringify(checked));return checked;
}
export async function loadLocalCompounds(storage,authority){
 const value=storage.getItem('era-zero-local-compounds-v1');return validateLocalCompounds(value===null?emptyLocalCompounds():JSON.parse(value),authority);
}
export async function importLocalCompounds(json,authority){return validateLocalCompounds(JSON.parse(json),authority);}

// Merge only validated, self-contained libraries. Existing identities and order
// remain unchanged; incoming dependencies retain their topological order.
export async function mergeLocalCompounds(existing,incoming,authority){
 const result=await validateLocalCompounds(existing,authority),source=await validateLocalCompounds(incoming,authority);
 const ids=new Set(result.entries.map(e=>e.compound_id)),labels=new Map(result.entries.map(e=>[e.definition.label.toLocaleLowerCase('en'),e.compound_id]));
 for(const entry of source.entries){
  if(ids.has(entry.compound_id))continue;
  if(labels.has(entry.definition.label.toLocaleLowerCase('en')))throw new Error(`Local compound: “${entry.definition.label}” already names a different saved definition. No definitions were merged.`);
  result.entries.push(entry);ids.add(entry.compound_id);labels.set(entry.definition.label.toLocaleLowerCase('en'),entry.compound_id);
 }
 return validateLocalCompounds(result,authority);
}
