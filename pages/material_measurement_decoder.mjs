import {strictSemanticReader} from './strict_semantic_reader.mjs';
// Reads normalized mass, temperature or luminance measurement/bound meaning from MIDI alone.
export function decodeMaterialMeasurementMidi(bytes,atoms){
 const message='Unsupported or malformed material measurement music.',fail=()=>{throw new Error(message);};
 const {observed,unwrapScopes,reference}=strictSemanticReader(bytes,atoms,message);
 const {current,scopes}=unwrapScopes(n=>n.kind==='root');
 if(current.length!==3)fail();const head=current.at(-1);
 if(head.kind!=='root'||!['MAT:000','MAT:010'].includes(head.root_id)||head.register!=='middle'||![0,1,2].includes(head.runtime_state))fail();
 const bearer=current.slice(0,-1).find(n=>n.marker==='role_bearer_open'),quantity=current.slice(0,-1).find(n=>n.marker==='role_quantity_open');
 if(!bearer||!quantity||quantity.children?.length!==1)fail();
 const subject=reference(bearer.children,'middle');if(!['phonemic','deictic'].includes(subject.kind)||subject.reference_mode==='nominal_class')fail();
 let measure=quantity.children[0],relation='equal';
 if(measure.marker!=='measurement_open'){
  relation=measure.marker?.match(/^measure_compare_(greater_than|less_than|at_least|at_most|not_equal)_open$/)?.[1];
  if(!relation||measure.children?.length!==1)fail();measure=measure.children[0];
 }
 if(measure.marker!=='measurement_open'||!measure.children?.length)fail();
 const entries=measure.children,unit=entries.at(-1).marker?.match(/^measurement_unit_(9|14|15)$/)?.[1];
 if(!unit)fail();
 const magnitude=entries.slice(0,-1).map(n=>n.marker==='measurement_negative'?'-':n.marker==='decimal_point'?'.':/^digit_[0-9]$/.test(n.marker||'')?n.marker.at(-1):fail()).join('');
 if(magnitude.length>1024||magnitude==='-0'||!/^-?(?:0|[1-9][0-9]*)(?:\.[0-9]*[1-9])?$/.test(magnitude)||(unit==='15'&&magnitude.startsWith('-')))fail();
 const [dimension,canonicalUnit]={9:['mass','kilogram'],14:['thermodynamic_temperature','kelvin'],15:['luminance','candela_per_square_meter']}[unit];
 return {profile:'EZMATERIALMEASURE-INVERSE-1',speech_act:observed.speech_act,scopes,material_root:head.root_id,runtime_state:head.runtime_state,bearer:subject,dimension,measurement:{magnitude,unit:canonicalUnit,relation},limitations:['A recovered bound is not a universal adjective threshold.','Luminance requires contextual surface/viewing direction and does not assert perceived brightness.','Reference sounds do not uniquely determine spelling or external identity.','Strict MIDI only; not arbitrary recorded audio.']};
}
