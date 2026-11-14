// Draft EZCOUNT-BIND-1 binding validation only. Canonical renderers must continue
// rejecting these nodes until the typed grammar and musical profile are admitted.
export function validateQuantifiedBindings(ir){
 const fail=()=>{throw new Error('Invalid quantified-predicate binding.');};
 if(!ir||!Array.isArray(ir.nodes)||!Array.isArray(ir.edges)||ir.nodes.length>10000)fail();
 const nodes=new Map(ir.nodes.map(n=>[n.node_id,n]));
 if(nodes.size!==ir.nodes.length||[...nodes.keys()].some(id=>typeof id!=='string'||!id))fail();
 if(ir.edges.some(e=>!nodes.has(e.from)||!nodes.has(e.to)))fail();
 if(ir.nodes.some(n=>n.operator==='quantified_predication'&&n.kind!=='scope_operator'))fail();
 const binders=ir.nodes.filter(n=>n.kind==='scope_operator'&&n.operator==='quantified_predication');
 const refs=ir.nodes.filter(n=>n.kind==='quantified_reference');
 const structural=new Set(['scopes','centers','member_of','condition_of']);
 const bodyOf=id=>{
  const reached=new Set(),active=new Set();
  const visit=(id,depth)=>{
   if(depth>128||active.has(id))fail();if(reached.has(id))return;
   active.add(id);reached.add(id);
   if(!['lexical_occurrence','scope_operator','coordination','clause'].includes(nodes.get(id).kind))fail();
   for(const edge of ir.edges.filter(e=>e.to===id&&structural.has(e.type)))visit(edge.from,depth+1);
   active.delete(id);
  };visit(id,0);return reached;
 };
 const enclosed=(id,binder,active=new Set())=>{
  if(id===binder)return true;if(active.has(id)||active.size>128)return false;
  const next=new Set(active);next.add(id);
  const parents=ir.edges.filter(e=>e.from===id&&structural.has(e.type));
  return parents.length>0&&parents.every(e=>enclosed(e.to,binder,next));
 };
 const bodies=new Map();
 for(const binder of binders){
  if(Object.keys(binder).sort().join(',')!=='kind,node_id,operator,quantifier,value'||!['exact','at_least','at_most'].includes(binder.quantifier)||typeof binder.value!=='string'||binder.value.length>1024||!/^(?:0|[1-9][0-9]*)$/.test(binder.value))fail();
  const scoped=ir.edges.filter(e=>e.type==='scopes'&&e.to===binder.node_id),restrictions=ir.edges.filter(e=>e.type==='restricts'&&e.to===binder.node_id);
  if(scoped.length!==1||restrictions.length!==1)fail();
  const restriction=nodes.get(restrictions[0].from);
  if(restriction.kind!=='phonemic_reference'||restriction.reference_mode!=='nominal_class'||restriction.value_type!=='entity')fail();
  const body=bodyOf(scoped[0].from);if(body.has(binder.node_id))fail();bodies.set(binder.node_id,body);
  if(!refs.some(r=>r.binder_id===binder.node_id))fail();
 }
 for(const ref of refs){
  if(Object.keys(ref).sort().join(',')!=='binder_id,kind,node_id,value_type'||ref.value_type!=='entity'||!bodies.has(ref.binder_id))fail();
  const body=bodies.get(ref.binder_id),uses=ir.edges.filter(e=>e.from===ref.node_id);
  const bound=ir.nodes.flatMap(n=>(n.compound_bindings||[]).filter(b=>b.argument_id===ref.node_id).map(()=>n));
  if(!uses.length&&!bound.length)fail();
  if(uses.some(e=>e.type!=='fills_role'||!body.has(e.to)||nodes.get(e.to).kind!=='lexical_occurrence')||bound.some(n=>!body.has(n.node_id)))fail();
  if([...uses.map(e=>e.to),...bound.map(n=>n.node_id)].some(id=>!enclosed(id,ref.binder_id)))fail();
  if(ir.edges.some(e=>e.to===ref.node_id))fail();
 }
 if(ir.edges.some(e=>e.type==='restricts'&&!bodies.has(e.to)))fail();
 return {profile:'EZCOUNT-BIND-1',binder_count:binders.length,reference_count:refs.length};
}
