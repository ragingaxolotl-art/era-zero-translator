import {expandLocalCompound} from './local_compound_expansion.mjs';
import {createContextualContent} from './contextual_content.mjs';
const key=r=>JSON.stringify([r.path,r.slot_path??null,r.role]);
// Bind occurrences, not role names globally. Definitions remain immutable.
export async function bindLocalCompound(id,registry,authority,bindings){
 const expansion=await expandLocalCompound(id,registry,authority);
 if(!Array.isArray(bindings))throw new Error('Provide explicit participant bindings.');
 const requirements=new Map(expansion.role_requirements.map(r=>[key(r),r])),resolved=new Map();
 for(const binding of bindings){
  if(!binding||Object.keys(binding).some(k=>!['path','slot_path','role','reference'].includes(k)))throw new Error('Invalid participant binding fields.');
  const identity=key(binding),requirement=requirements.get(identity);
  if(!requirement||resolved.has(identity))throw new Error('Unknown or duplicate participant binding.');
  if(requirement.value_type&&requirement.value_type!=='entity')throw new Error('This slot requires a non-entity argument; entity binding is not valid.');
  await createContextualContent('topic',binding.reference,{allowDraft:true});
  resolved.set(identity,{...structuredClone(requirement),reference:structuredClone(binding.reference)});
 }
 if(resolved.size!==requirements.size)throw new Error('Bind every participant explicitly.');
 // Preserve canonical same/distinct-argument constraints within each occurrence.
 const visit=node=>{
  if(node.kind==='canonical_compound'){
   const plan=authority.compound_plans[node.target_id];
   for(const constraint of plan.expanded.binding_constraints||[]){
    const refs=constraint.slot_paths.map(slot=>[...resolved.values()].find(r=>JSON.stringify(r.path)===JSON.stringify(node.path)&&JSON.stringify(r.slot_path)===JSON.stringify(slot))?.reference.referent_id);
    if(refs.some(r=>!r))throw new Error('Unbound canonical constraint.');
    if(constraint.relation==='same_argument'?new Set(refs).size!==1:constraint.relation==='distinct_arguments'?new Set(refs).size!==refs.length:true)throw new Error('Canonical participant constraint violated.');
   }
  }
  for(const child of node.components||[])visit(child);
 };visit(expansion.tree);
 return {profile:'EZLOCAL-COMPOUND-BINDING-1',expansion,bindings:[...resolved.values()]};
}
