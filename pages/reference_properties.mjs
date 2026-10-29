// EZREFPROPERTY-1: a restriction belongs to this definite reference, not to
// the surrounding action. Its truth is not the action's runtime state.
export function validReferenceProperty(node){
 const p=node.property_restriction;
 return node.kind==='phonemic_reference'&&node.reference_mode==='definite_nominal'&&p&&
  Object.keys(p).sort().join(',')==='comparison,dimension,magnitude,unit'&&p.dimension==='mass'&&p.unit==='kilogram'&&
  ['greater_than','less_than'].includes(p.comparison)&&typeof p.magnitude==='string'&&p.magnitude.length<=1024&&/^(?:0|[1-9][0-9]*)(?:\.[0-9]*[1-9])?$/.test(p.magnitude);
}
export function restrictReferenceEvents(node,events,anchor){
 if(node.property_restriction===undefined)return events;
 if(!validReferenceProperty(node))throw new Error('Unsupported nominal property restriction.');
 const p=node.property_restriction;
 const marker=(name,path)=>({kind:'grammar_marker',grammar_profile:'EZGRAM-1',marker:name,occurrence_id:node.node_id,target_id:`EZGRAM:${name}`,register:'middle',base_midi:anchor,
  family_qualified_transliteration:name,formal_carrier:'',family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:path,address_absolute_midi:path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5});
 const compare=p.comparison==='greater_than'?1:2;
 const value=[marker(`measure_compare_${p.comparison}_open`,[0,-17,compare,0]),marker('measurement_open',[0,-13,-1,0]),
  ...Array.from(p.magnitude,c=>c==='.'?marker('decimal_point',[0,10,-1,0]):marker(`digit_${c}`,[0,10,Math.floor(Number(c)/4),Number(c)%4,0])),
  marker('measurement_unit_9',[0,13,9,13,0]),marker('measurement_close',[0,13,1,0]),marker(`measure_compare_${p.comparison}_close`,[0,17,compare,0])];
 return [marker('nominal_mass_open',[0,-21,1,0]),...value,marker('nominal_property_head',[0,21,0,21]),...events,marker('nominal_mass_close',[0,21,1,0])];
}
