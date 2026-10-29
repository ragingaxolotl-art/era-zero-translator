// Explicit discourse anchors, not phonemic names or new lexical roots.
const PATHS={speaker:[0,12,-1,0],addressee:[0,12,1,0]};
const OFFSETS={low:-12,middle:0,high:12,sustained_background:-5};
export function deicticReference(role,nodeId){
  if(!Object.hasOwn(PATHS,role))throw new Error('Unknown discourse role.');
  return {node_id:nodeId,kind:'deictic_reference',deictic_role:role,referent_id:`discourse:${role}`,value_type:'entity'};
}
export function deicticEvent(reference,register,anchor=60){
  const role=reference.deictic_role;
  if(!Object.hasOwn(PATHS,role)||reference.referent_id!==`discourse:${role}`||!Object.hasOwn(OFFSETS,register))throw new Error('Invalid discourse reference.');
  const relative=PATHS[role],base=anchor+OFFSETS[register];
  return {kind:'deictic_reference',occurrence_id:reference.node_id,target_id:`EZREF:${role}`,referent_id:reference.referent_id,deictic_role:role,label:role,register,base_midi:base,
    family_qualified_transliteration:role,formal_carrier:'',family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:[...relative],address_absolute_midi:relative.map(note=>base+note),note_duration_beats:.25};
}

// A definite nominal identifies a contextually recoverable referent by noun label.
export function nominalMarker(reference,register,anchor=60){
  if(!['definite_nominal','nominal_class'].includes(reference.reference_mode)||!Object.hasOwn(OFFSETS,register))throw new Error('Invalid nominal reference.');
  const mode=reference.reference_mode,relative=[0,12,mode==='definite_nominal'?2:3,0],base=anchor+OFFSETS[register];
  return {kind:'reference_marker',occurrence_id:reference.node_id,target_id:`EZREF:${mode}`,referent_id:reference.referent_id,reference_mode:mode,label:mode,register,base_midi:base,
    family_qualified_transliteration:mode,formal_carrier:'',family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:relative,address_absolute_midi:relative.map(note=>base+note),note_duration_beats:.25};
}
