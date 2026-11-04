// Explicit subject control for the reviewed desire -> care infinitive construction.
export function validateSubjectControl(ir){
 const nodes=new Map(ir.nodes.map(n=>[n.node_id,n])),edges=ir.edges;
 for(const n of ir.nodes.filter(n=>n.kind==='reference'&&n.reference_type==='desire_subject')){
  const fail=()=>{throw new Error('Invalid desired-subject identity.');};
  if(n.value_type!=='entity'||Object.keys(n).some(k=>!['node_id','kind','reference_type','referent_id','value_type'].includes(k))||!ir.discourse_constraints?.declared_referents?.includes(n.referent_id))fail();
  const links=edges.filter(e=>e.from===n.node_id),role=links.find(e=>e.type==='fills_role'),identity=links.find(e=>e.type==='corefers_with');
  if(links.length!==2||!role||role.role!=='actor'||!identity)fail();
  const predicate=nodes.get(role.to),holder=nodes.get(identity.to);
  if(predicate?.target_id!=='LIF:211'||!['phonemic_reference','deictic_reference'].includes(holder?.kind)||holder.referent_id!==n.referent_id)fail();
  let id=predicate.node_id;const seen=new Set();
  while(nodes.get(id)?.kind!=='clause'){
   if(seen.has(id))fail();seen.add(id);
   const up=edges.filter(e=>e.from===id&&['scopes','centers'].includes(e.type));if(up.length!==1)fail();id=up[0].to;
  }
  const clause=nodes.get(id),parents=edges.filter(e=>e.from===id&&e.type==='fills_role'&&e.role==='content');
  if(clause.content_status!=='intensional'||parents.length!==1)fail();
  const parent=nodes.get(parents[0].to);
  if(parent?.target_type!=='foundation'||!edges.some(e=>e.from===holder.node_id&&e.to===parent.node_id&&e.type==='fills_role'&&e.role==='experiencer'))fail();
 }
}
export function subjectControlEvent(node,anchor=60){
 if(node.reference_type!=='desire_subject')throw new Error('Unsupported discourse reference.');
 const path=[0,-25,0,0];
 return {kind:'discourse_reference',occurrence_id:node.node_id,target_id:'EZCONTROL:desire_subject',referent_id:node.referent_id,register:'middle',base_midi:anchor,family_qualified_transliteration:'desire_subject',formal_carrier:'',family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:path,address_absolute_midi:path.map(n=>anchor+n),note_duration_beats:.25};
}
