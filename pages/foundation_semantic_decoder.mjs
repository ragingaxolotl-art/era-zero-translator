import {readPhysicalCarryingTree} from './carrying_decoder.mjs';
import {readPhysicalCustodyTree,readCustodyAcquisitionTree} from './custody_decoder.mjs';
import {validAcquisitionScopes} from './acquisition_scopes.mjs';
import {readSwimmingTree} from './swimming_decoder.mjs';
import {readFeltConditionTree} from './felt_decoder.mjs';
import {validateFoundations,foundationPath} from './foundations.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
// No source IR, expected sentence, or formal plan is accepted by this inverse.
export async function decodeFoundationSentenceMidi(bytes,atoms,records,{allowDraft=false,allowDraftQuestionContent=false,allowDraftAcquisition=false}={}){
 records=await validateFoundations(records,{allowDraft});
 const definitions=new Map(records.map(r=>[r.foundation_id,r]));
 if(atoms.some(a=>definitions.has(a.canonical_id)))throw new Error('Conflicting foundation identity.');
 const dictionary=[...atoms,...records.map(r=>({canonical_id:r.foundation_id,harmonic_signature_semitones:[0,3,7],note_path_semitones:foundationPath(r.sound_code)}))];
 const fail=()=>{throw new Error('Unsupported or malformed foundation sentence music.');};
 const reader=strictSemanticReader(bytes,dictionary,'Malformed foundation sentence framing.',{allowDraftQuestionContent,allowDraftAcquisition});
 const {observed,readTree,reference}=reader;
 const registers={bearer:'middle',actor:'low',target:'high',experiencer:'middle',comparison_standard:'middle',content:'middle'};
 function proposition(children,depth=0,parent=null){
  if(depth>32)fail();const scopes=[];
  while(children.length===1&&children[0].kind==='grammar'&&!/^convention_(4|7|8|13|15|16|17|19|21)_open$/.test(children[0].marker||'')){
   const n=children[0],m=n.marker;let scope;
   if(m==='negation_open')scope={operator:'negation'};
   else if(/^aspect_(bounded|ongoing|habitual)_open$/.test(m))scope={operator:'aspect',aspect:m.slice(7,-5)};
   else if(/^time_(before_speech|at_speech|after_speech|previous_day|current_day|next_day)_open$/.test(m))scope={operator:'time',relation:m.slice(5,-5)};
   else if(/^modality_(possible|necessary|permitted|obligated|intended|predicted|counterfactual)_open$/.test(m))scope={operator:'modality',mode:m.slice(9,-5)};
   else fail();
   scopes.push(scope);children=n.children;if(!children||scopes.length>32)fail();
  }
  if(children.length===1&&/^convention_(13|15|16|17|19)_open$/.test(children[0].marker||'')){
   const felt=readFeltConditionTree(children[0],reader,frame=>{
    if(frame.marker==='role_experiencer_open'&&frame.children?.length===1&&frame.children[0].marker==='desire_subject_reference'){
     if(parent?.sound_code!==0)fail();
     return {kind:'bound',binding:'parent_desire_experiencer'};
    }
    return reader.role(frame,'experiencer','middle');
   });
   return {predicate:{kind:'conventional_compound',name:felt.predicate,convention_codes:felt.convention_codes},runtime_state:felt.runtime_state,scopes,arguments:{experiencer:{type:'entity',reference:felt.participants.experiencer}},meaning:felt.meaning};
  }
  if(children.length===1&&/^convention_(4|8)_open$/.test(children[0].marker||'')){
   const carrying=children[0].marker==='convention_4_open';
   const value=carrying?readPhysicalCarryingTree(children[0],reader):readCustodyAcquisitionTree(children[0],reader);
   const args=Object.fromEntries(Object.entries(value.participants).map(([role,reference])=>[role,{type:'entity',reference}]));
   return {predicate:{kind:'conventional_compound',name:value.predicate,convention_codes:value.convention_codes},runtime_state:value.runtime_state,scopes,arguments:args,meaning:value.meaning};
  }
  if(children.length===1&&children[0].marker==='convention_7_open'){
   const custody=readPhysicalCustodyTree(children[0],reader);
   return {predicate:{kind:'conventional_compound',name:custody.predicate,convention_codes:custody.convention_codes},runtime_state:custody.runtime_state,scopes,arguments:{holder:{type:'entity',reference:custody.participants.holder},object:{type:'entity',reference:custody.participants.object}},meaning:custody.meaning};
  }
  if(children.length===1&&children[0].marker==='convention_21_open'){
   const swimming=readSwimmingTree(children[0],reader,frame=>{
    if(frame.marker==='role_actor_open'&&frame.children?.length===1&&frame.children[0].marker==='desire_subject_reference'){
     if(parent?.sound_code!==0)fail();return {kind:'bound',binding:'parent_desire_experiencer'};
    }
    return reader.role(frame,'actor','low');
   });
   return {predicate:{kind:'conventional_compound',name:swimming.predicate,convention_codes:swimming.convention_codes},runtime_state:swimming.runtime_state,scopes,arguments:{actor:{type:'entity',reference:swimming.actor}},meaning:swimming.meaning};
  }
  const head=children.at(-1),d=definitions.get(head?.root_id);
  if(head?.kind!=='root'||head.register!=='middle'||![0,1,2].includes(head.runtime_state))fail();
  const required=d?.roles||({'LIF:211':{actor:['entity'],target:['entity']},'MOV:201':{bearer:['entity']},'LIF:001':{bearer:['entity']},'LIF:002':{bearer:['entity']},'LIF:011':{bearer:['entity']},'LIF:012':{bearer:['entity']},'WRN:001':{bearer:['entity']},'REP:001':{bearer:['entity']},'MIN:201':{bearer:['entity']}}[head.root_id]||null);
  if(!required||children.length!==Object.keys(required).length+1)fail();
  const args={};
  for(const frame of children.slice(0,-1)){
   const role=frame.marker?.match(/^role_(.+)_open$/)?.[1];
   if(!role||!Object.hasOwn(required,role)||Object.hasOwn(args,role)||!frame.children)fail();
   let value;
   if(frame.children.length===1&&frame.children[0].marker==='proposition_content_open'){
    value={type:'proposition',content_status:'intensional',proposition:proposition(frame.children[0].children,depth+1,d)};
   }else if(frame.children.length===1&&frame.children[0].marker==='polar_content_open'){
    value={type:'question',question_kind:'polar',content_status:'intensional',assertion_commitment:'neither_answer',proposition:proposition(frame.children[0].children,depth+1,d)};
   }else if(frame.children.length===1&&frame.children[0].marker==='desire_subject_reference'){
    if(parent?.sound_code!==0||role!==([1,2].includes(d?.sound_code)?'experiencer':({'LIF:211':'actor','MOV:201':'bearer','LIF:001':'bearer','LIF:002':'bearer','LIF:011':'bearer','LIF:012':'bearer','WRN:001':'bearer','REP:001':'bearer','MIN:201':'bearer'})[head.root_id]))fail();
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
 const originalTree=readTree();let tree=originalTree;const acquisitionScopes=[];
 while(tree.length===1&&['negation_open','time_before_speech_open','time_previous_day_open','time_current_day_open'].includes(tree[0].marker)){
  const marker=tree[0].marker;acquisitionScopes.push(marker==='negation_open'?'negation':marker.slice(5,-5));tree=tree[0].children;
 }

 if(tree.length===1&&tree[0].marker==='knowledge_acquisition_open'){
  if(!['assertion','question'].includes(observed.speech_act)||!validAcquisitionScopes(acquisitionScopes))fail();
  const children=tree[0].children;
  if(children.length!==2||children[0].marker!=='acquisition_result_open')fail();
  const head=children[1];reader.exactRoot(head,'ORI:110','middle',head.runtime_state);
  if(![0,1,2].includes(head.runtime_state))fail();
  const result=proposition(children[0].children);
  if(result.predicate.foundation_id!=='FND:fe36cb2a6d649151067c7754'||result.scopes.length||result.arguments.content?.type!=='question')fail();
  return {profile:'EZKNOWLEDGE-ACQUISITION-INVERSE-1',speech_act:observed.speech_act,meaning:{predicate:{kind:'acquisition',root_id:'ORI:110'},runtime_state:head.runtime_state,scopes:acquisitionScopes.map(s=>s==='negation'?{operator:'negation'}:{operator:'time',relation:s}),phase_contract:{before:'does_not_hold',culmination:'holds',after:'unspecified'},result_assertion:'at_culmination_only',result},limitations:['Draft acquisition convention; not general learning or recorded-audio recognition.','Knowledge result and question meanings are recovered, not verified as real-world facts.']};
 }
 const meaning=proposition(originalTree);
 if(meaning.predicate.kind!=='foundation')fail();
 return {profile:'EZFOUND-SEMANTIC-INVERSE-1',speech_act:observed.speech_act,meaning,
  limitations:['Candidate vocabulary requires explicit opt-in.','This profile supports foundation predicates and embedded care, viewpoint-specific consciousness/dormancy, available self-mobility, attentional capacity, internal impairment/restoration reviewed felt conditions or bodily swimming with direct or controlled references; other constructions reject.','Reference sounds do not determine original spelling or external identity.','Recovered propositions remain inside their scopes and speech act; intensional content is not independently asserted.','Reads strict MIDI, not recorded audio.']};
}
