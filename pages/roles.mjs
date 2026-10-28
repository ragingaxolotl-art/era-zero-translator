// Quantification changes cardinality, not the scoped participant's argument role.
const REGISTERS={actor:'low',source:'low',cause:'low',target:'high',result:'high',destination:'high',recipient:'high',beneficiary:'high',environment:'sustained_background',persistent_condition:'sustained_background',location:'sustained_background',time:'sustained_background'};
export function registerFor(nodeId,ir){
  const nodes=new Map(ir.nodes.map(node=>[node.node_id,node])),pending=[nodeId],scopedIds=new Set();
  while(pending.length){
    const current=pending.pop();if(scopedIds.has(current))continue;scopedIds.add(current);
    for(const edge of ir.edges){
      const parent=nodes.get(edge.to);
      if(edge.type==='scopes'&&edge.from===current&&parent?.kind==='scope_operator'&&parent.operator==='quantifier')pending.push(edge.to);
    }
  }
  const registers=ir.edges.filter(edge=>edge.type==='fills_role'&&scopedIds.has(edge.from)).map(edge=>REGISTERS[edge.role]||'middle');
  return ['high','low','sustained_background'].find(register=>registers.includes(register))||'middle';
}
