import {canonicalDigest,deepSort} from './engine.mjs';
import {encodeName,notesForName} from './names.mjs';
import {deicticEvent,nominalMarker} from './references.mjs';
import {registerFor,ROLE_ORDER} from './roles.mjs';
const OFFSETS={low:-12,middle:0,high:12,sustained_background:-5};
const ROLE_REGISTERS={actor:'low',source:'low',cause:'low',target:'high',result:'high',destination:'high',recipient:'high',beneficiary:'high',environment:'sustained_background',persistent_condition:'sustained_background',location:'sustained_background',time:'sustained_background'};
const key=path=>JSON.stringify(path);
const equal=(a,b)=>JSON.stringify(deepSort(a))===JSON.stringify(deepSort(b));
const fail=message=>{throw new Error(`Compound binding: ${message}`)};
function runtime(code,path,base){
 if(code===0)return {code,name:'inactive',relative_motion_semitones:-1,absolute_note:base+path.at(-1)-1,articulation:'sharp_stop',duration_beats:.25};
 if(code===1)return {code,name:'active',relative_motion_semitones:-path.at(-1)||0,absolute_note:base,articulation:'firm_return',duration_beats:.5};
 if(code===2)return {code,name:'num',relative_motion_semitones:7,absolute_note:base+path.at(-1)+7,articulation:'sustain',duration_beats:2};
 fail('invalid runtime state');
}
function atomEvent(atom,id,register,anchor,state,component){
 if(!atom)fail('unknown atom');
 const base=anchor+OFFSETS[register],path=atom.note_path_semitones;
 const event={occurrence_id:id,...(component?{component_node_id:component.path?key(component.path):component.node_id,component_role:component.external_head?'head':component.component_role||'qualifier'}:{}),
 target_id:atom.canonical_id,register,base_midi:base,family_qualified_transliteration:atom.canonical_transliteration,formal_carrier:atom.formal_carrier,
 family_opening_relative_semitones:[...atom.harmonic_signature_semitones],family_opening_absolute_midi:atom.harmonic_signature_semitones.map(n=>base+n),address_relative_semitones:[...path],address_absolute_midi:path.map(n=>base+n),note_duration_beats:1};
 if(state!==null)event.runtime_tail=runtime(state,path,base);
 return event;
}
function conventionEvent(meaning,side,id,anchor,path){
 const code=meaning.sound_code;
 if(meaning.profile!=='EZLEX-1'||!Number.isInteger(code)||code<0||code>6560)fail('invalid convention');
 const notes=[0,side==='open'?-19:19,...code.toString(3).padStart(8,'0').split('').map(n=>[0,1,-1][Number(n)]),0],marker=`convention_${code}_${side}`;
 return {kind:'grammar_marker',grammar_profile:'EZLEX-1',marker,convention_scope_path:path,convention_sense:meaning.sense_key,occurrence_id:id,target_id:`EZLEX:${marker}`,register:'middle',base_midi:anchor,
 family_qualified_transliteration:marker,formal_carrier:'',family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:notes,address_absolute_midi:notes.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}

// This is the lexical rendering layer, not a general semantic-IR parser.
// Callers construct and validate grammar; compiled plans come from the release.
export async function renderLexicalOccurrences(ir,authority,{anchor=60,maxEvents=100000}={}){
 if(!Number.isInteger(anchor)||anchor<24||anchor>96||!Number.isInteger(maxEvents)||maxEvents<1)fail('invalid rendering limits');
 const atoms=new Map(authority.atoms.map(a=>[a.canonical_id,a])),compounds=new Map(authority.compounds.map(c=>[c.compound_id,c]));
 const nodes=new Map(ir.nodes.map(n=>[n.node_id,n]));if(nodes.size!==ir.nodes.length)fail('duplicate node ID');
 const verified=new Map();let emitted=0;
 const count=events=>{emitted+=events.length;if(emitted>maxEvents)fail('event limit exceeded');return events};
 async function planFor(id){
  if(verified.has(id))return verified.get(id);
  const definition=compounds.get(id),plan=authority.compound_plans?.[id];
  if(!definition||definition.status!=='approved'||!plan||plan.profile!=='EZCOMPOUNDPLAN-1'||plan.compound_id!==id||plan.definition_version!==definition.definition_version||plan.content_digest!==definition.content_digest)fail('missing or mismatched compiled definition');
  const {plan_digest,...payload}=plan;if(await canonicalDigest(payload)!==plan_digest)fail('compiled plan digest mismatch');
  verified.set(id,plan);return plan;
 }
 async function reference(node,register){
  if(node.value_type!=='entity'||node.runtime_state!==undefined)fail('invalid reference type or runtime');
  if(node.kind==='deictic_reference')return count([deicticEvent(node,register,anchor)]);
  const name=node.name;
  if(!name||!Array.isArray(name.phonemes))fail('missing name');
  const expected=await encodeName(name.normalized_label,name.object_tag||'',name.phonemes.join(' '));
  for(const field of ['format','name_id','events','frame','instance_notes'])if(!equal(name[field],expected[field]))fail('corrupt phonemic reference');
  if(typeof node.referent_id!=='string'||!node.referent_id)fail('missing referent');
  const base=anchor+OFFSETS[register],notes=notesForName(expected);
  const event={kind:'phonemic_label',occurrence_id:node.node_id,target_id:name.name_id,referent_id:node.referent_id,label:name.normalized_label,semantic_claim:false,register,base_midi:base,
   family_qualified_transliteration:name.normalized_label,formal_carrier:'',family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:notes.map(n=>n-60),address_absolute_midi:notes.map(n=>n+base-60),note_duration_beats:1};
  if(node.reference_mode){
   const mode=node.reference_mode==='definite_nominal'?'definite':node.reference_mode==='nominal_class'?'class':null;
   if(!mode||node.referent_id!==`nominal:${mode}:${name.name_id}`||!/^[a-z]+$/.test(name.normalized_label))fail('invalid nominal reference');
   return count([nominalMarker(node,register,anchor),event]);
  }
  return count([event]);
 }
 async function occurrence(node,register,ancestors=[]){
  const id=node.node_id;
  if(ancestors.includes(id)||ancestors.length>=64)fail('cyclic or excessively deep participant binding');
  if(!Object.hasOwn(OFFSETS,register))fail('unknown register');
  if(['phonemic_reference','deictic_reference'].includes(node.kind))return reference(node,register);
  if(node.kind!=='lexical_occurrence')fail('participant is not renderable');
  const state=node.runtime_state?.code;if(![0,1,2].includes(state))fail('invalid runtime state');
  if(node.target_type==='atom'){
   if(node.compound_bindings!==undefined)fail('atom cannot bind compound slots');
   return count([atomEvent(atoms.get(node.target_id),id,register,anchor,state)]);
  }
  if(node.target_type!=='compound')fail('unknown target type');
  const plan=await planFor(node.target_id),definition=compounds.get(node.target_id),bound=Object.hasOwn(node,'compound_bindings'),bindings=new Map();
  let components,scopes;
  if(bound){
   if(!Array.isArray(node.compound_bindings))fail('bindings must be an array');
   const slots=new Map(plan.expanded.nodes.filter(n=>n.kind==='slot').map(n=>[key(n.path),n]));
   for(const binding of node.compound_bindings){
    const slot=slots.get(key(binding.slot_path)),argument=nodes.get(binding.argument_id),edges=plan.expanded.edges.filter(e=>equal(e.from_path,binding.slot_path));
    if(!slot||bindings.has(key(binding.slot_path))||!argument||argument.value_type!==slot.slot_type||edges.length!==1||edges[0].type!=='fills_role'||!ROLE_ORDER.includes(edges[0].role))fail('unknown, duplicate or mistyped slot binding');
    if(binding.role!==undefined&&binding.role!==edges[0].role)fail('binding role mismatch');
    bindings.set(key(binding.slot_path),{slot_path:binding.slot_path,argument_id:binding.argument_id,role:edges[0].role,predicate_path:edges[0].to_path});
   }
   if(bindings.size!==slots.size)fail('unbound compound slots');
   components=plan.bound_components;scopes=plan.expanded.scopes;
  }else{
   const roles=ir.edges.filter(e=>e.type==='fills_role'&&e.to===id).map(e=>e.role);
   if(plan.required_roles.some(role=>!roles.includes(role))||!plan.unbound_components)fail('missing required compound roles or scoped bindings');
   components=plan.unbound_components;scopes=plan.unbound_scopes;
  }
  const conventions=scopes.filter(s=>s.conventional_meaning),result=[];
  let previous=[],previousContexts=new Map(),previousBoundary;
  const chainFor=paths=>paths.map(path=>{const b=bindings.get(key(path));if(!b)fail('unknown qualified slot');return {compound_occurrence_id:id,slot_path:path,argument_id:b.argument_id,role:b.role,predicate_path:b.predicate_path}});
  const marker=(scope,side,contexts)=>{const event=conventionEvent(scope.conventional_meaning,side,id,anchor,scope.path),chain=contexts.get(key(scope.path))||[];if(chain.length)event.binding_chain=chain;count([event]);return event};
  for(const component of components){
   const path=component.path||[component.node_id],chain=chainFor(component.qualified_slot_paths||[]),contexts=new Map((component.convention_slot_contexts||[]).map(c=>[key(c.scope_path),chainFor(c.qualified_slot_paths)]));
   const active=conventions.filter(s=>equal(path.slice(0,s.path.length),s.path)).sort((a,b)=>a.path.length-b.path.length);
   let shared=0;while(shared<previous.length&&shared<active.length&&equal(previous[shared].path,active[shared].path))shared++;
   for(const scope of previous.slice(shared).reverse())result.push(marker(scope,'close',previousContexts));
   if(previousBoundary!==undefined&&result.length)result.at(-1).boundary_after_beats=previousBoundary;
   for(const scope of active.slice(shared))result.push(marker(scope,'open',contexts));
   previous=active;previousContexts=contexts;previousBoundary=component.boundary_after_beats;
   let payload;
   if(component.kind==='slot'){
    const binding=bindings.get(key(component.path)),argument=nodes.get(binding.argument_id),inner=await occurrence(argument,ROLE_REGISTERS[binding.role]||'middle',[...ancestors,id]);
    payload=inner.map(event=>({...event,occurrence_id:id,argument_node_id:argument.node_id,binding_path:component.path,binding_role:binding.role,binding_predicate_path:binding.predicate_path,
     binding_chain:[{compound_occurrence_id:id,slot_path:component.path,argument_id:argument.node_id,role:binding.role,predicate_path:binding.predicate_path},...(event.binding_chain||[])]}));
   }else{
    const isHead=component.external_head??component.node_id===definition.semantic_head;
    payload=count([atomEvent(atoms.get(component.root_id),id,component.component_role?ROLE_REGISTERS[component.component_role]||'middle':register,anchor,isHead?state:null,{...component,external_head:isHead})]);
   }
   result.push(...payload.map(event=>chain.length?{...event,binding_chain:[...chain,...(event.binding_chain||[])]}:event));
  }
  for(const scope of previous.slice().reverse())result.push(marker(scope,'close',previousContexts));
  if(previousBoundary!==undefined)result.at(-1).boundary_after_beats=previousBoundary;
  return result;
 }
 const lexical=ir.nodes.filter(n=>['lexical_occurrence','phonemic_reference','deictic_reference'].includes(n.kind));
 const boundIds=new Set(lexical.flatMap(n=>(n.compound_bindings||[]).map(b=>b.argument_id))),independent=new Set(ir.edges.map(e=>e.from)),events=[];
 for(const node of lexical.slice().sort((a,b)=>a.node_id<b.node_id?-1:a.node_id>b.node_id?1:0)){
  if(boundIds.has(node.node_id)&&!independent.has(node.node_id))continue;
  events.push(...await occurrence(node,registerFor(node.node_id,ir)));
 }
 if(lexical.length&&!events.length)fail('no independently rooted lexical occurrence');
 return events;
}

export function lexicalGloss(events,authority){
 const atoms=new Map(authority.atoms.map(a=>[a.canonical_id,a]));
 return events.map(event=>{
  const id=event.occurrence_id;
  if(event.kind==='grammar_marker')return `${id}:${event.marker}`;
  if(event.kind==='reference_marker')return `${id}:reference(${event.reference_mode})`;
  if(event.kind==='deictic_reference')return `${id}:reference(${event.deictic_role})`;
  if(event.kind==='phonemic_label')return `${id}:name(${event.label})`;
  return `${id}${event.component_node_id?'.'+event.component_node_id:''}:${atoms.get(event.target_id).title}${event.runtime_tail?'['+event.runtime_tail.code+']':''}`;
 }).join(' | ');
}
