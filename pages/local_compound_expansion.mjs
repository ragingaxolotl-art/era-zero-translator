import {validateLocalCompounds} from './local_compounds.mjs';
import {canonicalDigest} from './engine.mjs';
// Preserve nested identity and qualification scopes. Canonical compounds remain
// atomic references to their validated release plans, never flattened to roots.
export async function expandLocalCompound(compoundId,registry,authority,{maxNodes=4096,maxDepth=32}={}){
 if(!Number.isInteger(maxNodes)||maxNodes<1||maxNodes>100000||!Number.isInteger(maxDepth)||maxDepth<1||maxDepth>64)throw new Error('Invalid local expansion limits.');
 const checked=await validateLocalCompounds(registry,authority),local=new Map(checked.entries.map(e=>[e.compound_id,e])),atoms=new Map(authority.atoms.map(a=>[a.canonical_id,a])),canonical=new Map(authority.compounds.map(c=>[c.compound_id,c]));
 if(!local.has(compoundId))throw new Error('Select a saved local compound.');
 let count=0;const requirements=[];
 async function visit(id,path,relation){
  if(++count>maxNodes||path.length>maxDepth)throw new Error('Local expansion limit exceeded.');
  const entry=local.get(id);
  if(entry){
   for(const role of entry.definition.roles)requirements.push({path:[...path],target_id:id,...role});
   const components=[];for(const [i,c] of entry.definition.components.entries())components.push(await visit(c.target_id,[...path,i],c.relation));
   return {kind:'local_compound',target_id:id,path,relation,definition:structuredClone(entry.definition),head_index:entry.definition.components.findIndex(c=>c.relation==='head'),components};
  }
  if(atoms.has(id))return {kind:'atom',target_id:id,path,relation};
  const definition=canonical.get(id),plan=authority.compound_plans?.[id];
  if(!definition||definition.status!=='approved'||!plan||plan.compound_id!==id||plan.profile!=='EZCOMPOUNDPLAN-1'||plan.definition_version!==definition.definition_version||plan.content_digest!==definition.content_digest)throw new Error('Missing canonical dependency plan.');
  const {plan_digest,...body}=plan;if(await canonicalDigest(body)!==plan_digest)throw new Error('Invalid canonical dependency plan.');
  for(const slot of plan.expanded.nodes.filter(n=>n.kind==='slot')){
   const edges=plan.expanded.edges.filter(e=>JSON.stringify(e.from_path)===JSON.stringify(slot.path)&&e.type==='fills_role');
   if(edges.length!==1)throw new Error('Invalid canonical slot role.');
   requirements.push({path:[...path],target_id:id,slot_path:structuredClone(slot.path),value_type:slot.slot_type,role:edges[0].role,definition:null});
  }
  return {kind:'canonical_compound',target_id:id,path,relation,content_digest:definition.content_digest,plan_digest};
 }
 const tree=await visit(compoundId,[],'head');
 return {profile:'EZLOCAL-COMPOUND-EXPANSION-1',tree,role_requirements:requirements,node_count:count};
}
