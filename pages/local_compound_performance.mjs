import {bindLocalCompound} from './local_compound_binding.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
// Prepare existing lexical performances inside an explicit local scope tree.
// This is not a flattened MIDI export: local boundaries still need audible frames.
export async function prepareLocalCompoundPerformance(id,registry,authority,bindings,{runtimeState=1,anchor=60}={}){
 if(![0,1,2].includes(runtimeState))throw new Error('Invalid local runtime state.');
 const bound=await bindLocalCompound(id,registry,authority,bindings);
 const same=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
 async function walk(node,externalHead){
  if(node.kind==='local_compound'){
   const participants=[];
   for(const b of bound.bindings.filter(b=>same(b.path,node.path)&&b.slot_path===undefined)){
    const ref={...b.reference,node_id:'participant'};
    const events=await renderLexicalOccurrences({nodes:[ref,{node_id:'predicate',kind:'clause'}],edges:[{edge_id:'participant_role',type:'fills_role',from:ref.node_id,to:'predicate',role:b.role}]},authority,{anchor});
    participants.push({role:b.role,reference:b.reference,events});
   }
   const components=[];for(const [i,child] of node.components.entries())components.push(await walk(child,externalHead&&i===node.head_index));
   return {...node,participants,components};
  }
  const occurrence={node_id:'lexical',kind:'lexical_occurrence',target_type:node.kind==='atom'?'atom':'compound',target_id:node.target_id,runtime_state:{code:runtimeState}};
  const nodes=[occurrence];
  if(node.kind==='canonical_compound'){
   const entries=bound.bindings.filter(b=>same(b.path,node.path));
   occurrence.compound_bindings=entries.map((b,i)=>{
    const argument_id=`argument${i}`;nodes.push({...b.reference,node_id:argument_id});return {slot_path:b.slot_path,role:b.role,argument_id};
   });
  }
  const events=await renderLexicalOccurrences({nodes,edges:[]},authority,{anchor});
  // Existing renderer places a runtime tail only on its semantic head. A local
  // qualifier is not the external head of the new compound.
  if(!externalHead)for(const event of events)delete event.runtime_tail;
  return {...node,events};
 }
 return {profile:'EZLOCAL-PERFORMANCE-TREE-1',runtime_state:runtimeState,anchor,tree:await walk(bound.expansion.tree,true),bindings:bound.bindings};
}
