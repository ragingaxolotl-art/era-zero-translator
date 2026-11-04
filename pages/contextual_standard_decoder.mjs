import {strictSemanticReader} from './strict_semantic_reader.mjs';
import {CONTEXTUAL_NORMS} from './contextual_standards.mjs';
export function decodeContextualStandardMidi(bytes,atoms){
 const message='Unsupported or malformed contextual-standard music.',fail=()=>{throw new Error(message);};
 const {observed,unwrapScopes,reference}=strictSemanticReader(bytes,atoms,message);
 const {current,scopes}=unwrapScopes(n=>/^contextual_(hot|cold|heavy|light|bright|dim|rough|smooth)_open$/.test(n.marker||''));
 if(current.length!==1)fail();const frame=current[0],norm=frame.marker?.match(/^contextual_(hot|cold|heavy|light|bright|dim|rough|smooth)_open$/)?.[1];
 if(!norm||frame.children?.length!==2)fail();const [role,head]=frame.children;
 if(role.marker!=='role_bearer_open'||head.kind!=='root'||!['MAT:000','MAT:010'].includes(head.root_id)||head.register!=='middle'||![0,1,2].includes(head.runtime_state))fail();
 const bearer=reference(role.children,'middle');if(!['phonemic','deictic'].includes(bearer.kind)||bearer.reference_mode==='nominal_class')fail();
 const definition=CONTEXTUAL_NORMS[norm];
 return {profile:'EZCONTEXTUAL-INVERSE-1',speech_act:observed.speech_act,scopes,bearer,material_root:head.root_id,runtime_state:head.runtime_state,dimension:definition.dimension,relation:definition.relation,standard:{kind:'contextual',norm,scope:'local_context'},limitations:['No numeric threshold, measurement or equality between separate contextual norms is inferred.','Opposite adjectives may use different standards.','The selected physical dimension does not establish a perceptual or metaphorical reading.','Strict MIDI only; reference sounds do not uniquely identify spelling or external referents.']};
}
