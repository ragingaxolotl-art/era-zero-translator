import {strictSemanticReader} from './strict_semantic_reader.mjs?v=ordinary-comparatives-1';

// Keep the byte-only API used by older integrations. These two paths are the
// existing material roots; callers may instead pass the complete public index.
const materialAtoms=[
 {canonical_id:'MAT:000',harmonic_signature_semitones:[0,7,12],note_path_semitones:[0,0,0,0]},
 {canonical_id:'MAT:010',harmonic_signature_semitones:[0,7,12],note_path_semitones:[0,0,2,2]}
];
const framePattern=/^property_(mass|thermodynamic_temperature|luminance)_(equal|greater_than|less_than|at_least|at_most|not_equal)_open$/;
const problem='Unsupported or malformed strict property-comparison music.';
export function decodePropertyComparisonMidi(bytes,atoms=materialAtoms){
 const fail=()=>{throw new Error(problem);};
 return readPropertyComparison(strictSemanticReader(bytes,atoms,problem),undefined,fail);
}
// A grouped clause uses precisely the same validation on a subtree read from
// sound. No source text, expected predicate or semantic metadata is supplied.
export function readPropertyComparison(reader,subtree,fail=()=>{throw new Error(problem);}){
 const {current,scopes}=reader.unwrapScopes(n=>framePattern.test(n.marker||''),subtree);
 if(current.length!==1||scopes.some(s=>!['negation','modality','time'].includes(s.operator)))fail();
 const frame=current[0],match=frame.marker?.match(framePattern);
 if(!match||frame.children?.length!==3)fail();
 const [first,second,head]=frame.children,participants={};
 for(const roleFrame of [first,second]){
  const role=roleFrame.marker?.match(/^role_(bearer|comparison_standard)_open$/)?.[1];
  if(!role||participants[role])fail();
  const value=reader.reference(roleFrame.children,'middle');
  if(value.kind==='deictic'){
   if(!['speaker','addressee'].includes(value.role))fail();
   participants[role]=value;
  }else{
   if(value.kind!=='phonemic'||value.instance_code!==null||
      !['name','definite_nominal','proximal_nominal','distal_nominal'].includes(value.reference_mode))fail();
   const {instance_code,...reference}=value;participants[role]=reference;
  }
 }
 if(head.kind!=='root'||!['MAT:000','MAT:010'].includes(head.root_id)||
    head.register!=='middle'||![0,1,2].includes(head.runtime_state))fail();
 return {profile:'EZPROPERTYCOMPARE-1',dimension:match[1],relation:match[2],scopes,participants,
  material_root:head.root_id,runtime_state:head.runtime_state,speech_act:reader.observed.speech_act,
  reference_resolution:'Phonemes recover audible labels, not original spelling or external referent identity.'};
}
