// Typed argument and intensional-content validation for the opt-in EZFOUND-1 profile.
// This supplements (and does not replace) the ordinary semantic IR validator.
import {validateFoundations} from './foundations.mjs';
export async function validateFoundationIR(input, records, {allowDraft=false}={}) {
 const ir=structuredClone(input);
 const registry=await validateFoundations(records,{allowDraft});
 if(!ir||!Array.isArray(ir.nodes)||!Array.isArray(ir.edges))throw new Error('Invalid foundation IR.');
 const nodes=new Map();
 for(const n of ir.nodes){
  if(!n||typeof n.node_id!=='string'||!n.node_id||nodes.has(n.node_id))throw new Error('Invalid or duplicate node.');
  nodes.set(n.node_id,n);
 }
 const edgeIds=new Set();
 for(const e of ir.edges){
  if(!e||typeof e.edge_id!=='string'||!e.edge_id||edgeIds.has(e.edge_id)||!nodes.has(e.from)||!nodes.has(e.to))throw new Error('Invalid or duplicate edge.');
  edgeIds.add(e.edge_id);
 }
 const definitions=new Map(registry.map(r=>[r.foundation_id,r]));
 const foundations=ir.nodes.filter(n=>n.target_type==='foundation');
 const content=ir.nodes.filter(n=>n.kind==='clause'&&(n.clause_type==='content'||Object.hasOwn(n,'content_status')));
 const type=n=>n.kind==='clause'&&n.clause_type==='content'&&n.content_status==='intensional'&&n.value_type==='proposition'?'proposition':n.kind==='phonemic_reference'&&n.reference_mode==='nominal_class'?'kind':['phonemic_reference','deictic_reference'].includes(n.kind)&&n.value_type==='entity'?'entity':null;
 for(const n of foundations){
  const d=definitions.get(n.target_id);
  if(n.kind!=='lexical_occurrence'||!d||n.foundation_version!==d.definition_version||Object.hasOwn(n,'compound_bindings')||![0,1,2].includes(n.runtime_state?.code)||Object.hasOwn(n.runtime_state,'num'))throw new Error('Invalid foundation occurrence.');
  const roles=ir.edges.filter(e=>e.type==='fills_role'&&e.to===n.node_id);
  if(roles.length!==Object.keys(d.roles).length)throw new Error('Incomplete foundation arguments.');
  for(const [role,types] of Object.entries(d.roles)){
   const matches=roles.filter(e=>e.role===role);
   if(matches.length!==1||!types.includes(type(nodes.get(matches[0].from))))throw new Error('Invalid foundation role or argument type.');
  }
 }
 for(const n of content){
  if(type(n)!=='proposition'||n.node_id===ir.root_clause)throw new Error('Content must be an intensional embedded proposition.');
  const outgoing=ir.edges.filter(e=>e.from===n.node_id);
  if(outgoing.length!==1||outgoing[0].type!=='fills_role'||!foundations.some(f=>f.node_id===outgoing[0].to))throw new Error('Intensional content cannot also be asserted or shared.');
  const centers=ir.edges.filter(e=>e.type==='centers'&&e.to===n.node_id);
  if(centers.length!==1)throw new Error('Content requires one predicate center.');
  if(ir.edges.some(e=>e.type==='centers'&&e.from===centers[0].from&&e.to!==n.node_id))throw new Error('Content predicate cannot also center an assertion.');
  const owned=new Set([n.node_id]),pending=[n.node_id];
  while(pending.length){const target=pending.pop();for(const e of ir.edges){
   const source=nodes.get(e.from);
   if(e.to!==target||['phonemic_reference','deictic_reference','reference','literal','variable'].includes(source.kind)||owned.has(e.from))continue;
   owned.add(e.from);pending.push(e.from);
  }}
  if(ir.edges.some(e=>owned.has(e.from)&&e.from!==n.node_id&&!owned.has(e.to)))throw new Error('Embedded predicate or scope escapes intensional content.');

 }
 // A content/predicate cycle would make the desired proposition contain its own holder relation.
 const graph=new Map(ir.nodes.map(n=>[n.node_id,[]]));
 for(const e of ir.edges)if(['fills_role','centers','scopes','member_of'].includes(e.type))graph.get(e.from).push(e.to);
 const visiting=new Set(),done=new Set();
 function visit(id){if(visiting.has(id))throw new Error('Cyclic foundation content.');if(done.has(id))return;visiting.add(id);for(const next of graph.get(id))visit(next);visiting.delete(id);done.add(id);}
 for(const n of foundations)visit(n.node_id);
 return {ir,foundations:registry};
}
