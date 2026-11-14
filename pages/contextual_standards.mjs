// Local contextual norms: no numeric cutoff or equality between separate contexts is asserted.
export const CONTEXTUAL_NORMS=Object.freeze({
 hot:{dimension:'thermodynamic_temperature',relation:'greater_than',code:0},
 cold:{dimension:'thermodynamic_temperature',relation:'less_than',code:1},
 heavy:{dimension:'mass',relation:'greater_than',code:2},
 light:{dimension:'mass',relation:'less_than',code:3},
 bright:{dimension:'luminance',relation:'greater_than',code:4},
 dim:{dimension:'luminance',relation:'less_than',code:5},
 rough:{dimension:'surface_texture',relation:'greater_than',code:6},
 smooth:{dimension:'surface_texture',relation:'less_than',code:7}
});
export function validContextualComparison(node,ir){
 const norm=CONTEXTUAL_NORMS[node.norm];
 if(!norm||node.standard!=='contextual'||node.dimension!==norm.dimension||node.relation!==norm.relation||Object.keys(node).some(k=>!['node_id','kind','operator','standard','norm','dimension','relation'].includes(k)))return false;
 const scopes=ir.edges.filter(e=>e.type==='scopes'&&e.to===node.node_id);if(scopes.length!==1)return false;
 const predicate=ir.nodes.find(n=>n.node_id===scopes[0].from);
 if(predicate?.kind!=='lexical_occurrence'||predicate.target_type!=='atom'||!['MAT:000','MAT:010'].includes(predicate.target_id))return false;
 const roles=ir.edges.filter(e=>e.type==='fills_role'&&e.to===predicate.node_id);if(roles.length!==1||roles[0].role!=='bearer')return false;
 return ir.nodes.some(n=>n.node_id===roles[0].from&&['phonemic_reference','deictic_reference'].includes(n.kind)&&n.reference_mode!=='nominal_class');
}
