// Only canonical same-argument constraints authorize automatic grouping.
// Equal role names in separate local occurrences remain independent.
export function localParticipantGroups(expansion,authority){
 const rows=expansion.role_requirements,key=r=>JSON.stringify([r.path,r.slot_path??null,r.role]),parents=new Map(rows.map(r=>[key(r),key(r)]));
 const find=k=>parents.get(k)===k?k:find(parents.get(k));
 function walk(node){
  if(node.kind==='canonical_compound')for(const constraint of authority.compound_plans[node.target_id].expanded.binding_constraints||[]){
   if(constraint.relation!=='same_argument')continue;
   const keys=constraint.slot_paths.map(slot=>{const r=rows.find(r=>JSON.stringify(r.path)===JSON.stringify(node.path)&&JSON.stringify(r.slot_path)===JSON.stringify(slot));if(!r)throw new Error('Unknown canonical participant constraint.');return key(r);});
   for(const k of keys.slice(1))parents.set(find(k),find(keys[0]));
  }
  for(const child of node.components||[])walk(child);
 }walk(expansion.tree);
 const groups=new Map();for(const r of rows){const k=find(key(r));if(!groups.has(k))groups.set(k,[]);groups.get(k).push(r);}return [...groups.values()];
}
