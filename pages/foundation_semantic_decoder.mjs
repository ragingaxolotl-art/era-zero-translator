import {validateFoundations,foundationPath} from './foundations.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
// No source IR, expected sentence, or formal plan is accepted by this inverse.
export async function decodeFoundationSentenceMidi(bytes,atoms,records,{allowDraft=false}={}){
 records=await validateFoundations(records,{allowDraft});
 const definitions=new Map(records.map(r=>[r.foundation_id,r]));
 if(atoms.some(a=>definitions.has(a.canonical_id)))throw new Error('Conflicting foundation identity.');
 const dictionary=[...atoms,...records.map(r=>({canonical_id:r.foundation_id,harmonic_signature_semitones:[0,3,7],note_path_semitones:foundationPath(r.sound_code)}))];
 const fail=()=>{throw new Error('Unsupported or malformed foundation sentence music.');};
 const {observed,readTree,reference}=strictSemanticReader(bytes,dictionary,'Malformed foundation sentence framing.');
 const registers={bearer:'middle',actor:'low',target:'high',experiencer:'middle',comparison_standard:'middle',content:'middle'};
 function proposition(children,depth=0,parent=null){
  if(depth>32)fail();const scopes=[];
  while(children.length===1&&children[0].kind==='grammar'){
   const n=children[0],m=n.marker;let scope;
   if(m==='negation_open')scope={operator:'negation'};
   else if(/^aspect_(bounded|ongoing|habitual)_open$/.test(m))scope={operator:'aspect',aspect:m.slice(7,-5)};
   else if(/^time_(before_speech|at_speech|after_speech|previous_day|current_day|next_day)_open$/.test(m))scope={operator:'time',relation:m.slice(5,-5)};
   else if(/^modality_(possible|necessary|permitted|obligated|intended|predicted|counterfactual)_open$/.test(m))scope={operator:'modality',mode:m.slice(9,-5)};
   else fail();
   scopes.push(scope);children=n.children;if(!children||scopes.length>32)fail();
  }
  const head=children.at(-1),d=definitions.get(head?.root_id);
  if(head?.kind!=='root'||head.register!=='middle'||![0,1,2].includes(head.runtime_state))fail();
  const required=d?.roles||({'LIF:211':{actor:['entity'],target:['entity']},'MOV:201':{bearer:['entity']}}[head.root_id]||null);
  if(!required||children.length!==Object.keys(required).length+1)fail();
  const args={};
  for(const frame of children.slice(0,-1)){
   const role=frame.marker?.match(/^role_(.+)_open$/)?.[1];
   if(!role||!Object.hasOwn(required,role)||Object.hasOwn(args,role)||!frame.children)fail();
   let value;
   if(frame.children.length===1&&frame.children[0].marker==='proposition_content_open'){
    value={type:'proposition',content_status:'intensional',proposition:proposition(frame.children[0].children,depth+1,d)};
   }else if(frame.children.length===1&&frame.children[0].marker==='desire_subject_reference'){
    if(parent?.sound_code!==0||role!==(d?.sound_code===1?'experiencer':({'LIF:211':'actor','MOV:201':'bearer'})[head.root_id]))fail();
    value={type:'entity',reference:{kind:'bound',binding:'parent_desire_experiencer'}};
   }else{
    const ref=reference(frame.children,registers[role]);
    if(!['phonemic','deictic'].includes(ref.kind))fail();
    value={type:ref.reference_mode==='nominal_class'?'kind':'entity',reference:ref};
   }
   if(!required[role].includes(value.type))fail();args[role]=value;
  }
  return {predicate:d?{kind:'foundation',foundation_id:d.foundation_id,definition_version:d.definition_version,registry_status:d.status}:{kind:'atom',root_id:head.root_id},runtime_state:head.runtime_state,scopes,arguments:args};
 }
 const meaning=proposition(readTree());
 if(meaning.predicate.kind!=='foundation')fail();
 return {profile:'EZFOUND-SEMANTIC-INVERSE-1',speech_act:observed.speech_act,meaning,
  limitations:['Candidate vocabulary requires explicit opt-in.','This profile supports foundation predicates and embedded care or available self-mobility with direct or controlled references; other constructions reject.','Reference sounds do not determine original spelling or external identity.','Recovered propositions remain inside their scopes and speech act; intensional content is not independently asserted.','Reads strict MIDI, not recorded audio.']};
}
