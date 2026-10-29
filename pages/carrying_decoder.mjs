import {decodeStrictMusicMidi} from './strict_music_decoder.mjs';

// Independent interpretation of the released EZLEX conventions 3–6. Inputs are
// performed MIDI and the root sound inventory, never English, IR or event plans.
const fail=()=>{throw new Error('Unsupported or malformed destination-carrying music.');};
const same=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
export function decodeDestinationCarryingMidi(bytes,atoms){
 const observed=decodeStrictMusicMidi(bytes,atoms),tokens=observed.tokens;
 const tree=(from,to,depth=0)=>{
  if(depth>64)fail();const children=[];
  for(let i=from;i<to;i++){
   const token=tokens[i];
   if(token.opening_token!==undefined)fail();
   if(token.closing_token!==undefined){
    const end=token.closing_token;if(end<=i||end>=to||tokens[end].opening_token!==i)fail();
    children.push({...token,children:tree(i+1,end,depth+1)});i=end;
   }else children.push(token);
  }
  return children;
 };
 const marker=(node,name)=>node?.marker===name;
 const exactRoot=(node,id,register,runtime)=>{
  if(node?.kind!=='root'||node.root_id!==id||node.register!==register||node.runtime_state!==runtime)fail();
 };
 const decimal=nodes=>{
  const value=nodes.map(n=>n.marker==='decimal_point'?'.':/^digit_[0-9]$/.test(n.marker||'')?n.marker.at(-1):fail()).join('');
  if(value.length>1024||!/^(?:0|[1-9][0-9]*)(?:\.[0-9]*[1-9])?$/.test(value))fail();return value;
 };
 const reference=(nodes,register)=>{
  if(nodes.length===1&&marker(nodes[0],'nominal_mass_open')){
   const content=nodes[0].children,compare=content[0],relation=compare?.marker?.match(/^measure_compare_(greater_than|less_than)_open$/)?.[1];
   if(!relation||compare.children?.length!==1||!marker(compare.children[0],'measurement_open')||!marker(content[1],'nominal_property_head'))fail();
   const measured=compare.children[0].children;if(!marker(measured.at(-1),'measurement_unit_9'))fail();
   const magnitude=decimal(measured.slice(0,-1)),head=reference(content.slice(2),register);
   if(head.kind!=='phonemic'||head.reference_mode!=='definite_nominal'||head.property)fail();
   return {...head,property:{dimension:'mass',comparison:relation,magnitude,unit:'kilogram'}};
  }
  let mode='name';
  if(nodes[0]?.kind==='reference_mode'){
   if(nodes[0].register!==register||!['definite_nominal','nominal_class'].includes(nodes[0].reference_mode))fail();
   mode=nodes[0].reference_mode;nodes=nodes.slice(1);
  }
  if(nodes.length!==1||nodes[0].register!==register)fail();const n=nodes[0];
  if(n.kind==='phonemic')return {kind:'phonemic',reference_mode:mode,phonemes:[...n.phonemes],instance_code:n.instance_code};
  if(mode!=='name')fail();
  if(n.kind==='deictic')return {kind:'deictic',role:n.deictic_role};
  if(n.kind==='root'&&[0,1,2].includes(n.runtime_state))return {kind:'lexical',root_id:n.root_id,runtime_state:n.runtime_state};
  fail();
 };
 const role=(node,name,register,qualified=false)=>{
  if(!marker(node,`role_${name}_open`))fail();let content=node.children;
  if(qualified){exactRoot(content[0],'MAT:010',register,null);content=content.slice(1);}
  return reference(content,register);
 };
 const support=node=>{
  if(!marker(node,'convention_3_open')||node.children.length!==3)fail();
  const [source,target,root]=node.children;exactRoot(root,'MAT:211','middle',null);
  return {carrier:role(source,'source','low'),load:role(target,'target','high',true)};
 };
 const carrying=node=>{
  if(!marker(node,'convention_4_open')||node.children.length!==3)fail();
  const [actor,nested,root]=node.children,result=support(nested);exactRoot(root,'MOV:121','middle',null);
  if(!same(role(actor,'actor','low'),result.load))fail();return result;
 };
 const directed=(node,runtime)=>{
  if(!marker(node,'convention_5_open')||node.children.length!==4)fail();
  const [actor,destination,nested,root]=node.children,result=carrying(nested);exactRoot(root,'MOV:111','middle',runtime);
  if(!same(role(actor,'actor','low'),result.load))fail();
  return {...result,destination:role(destination,'destination','high')};
 };
 let current=tree(0,tokens.length),scopes=[];
 while(current.length===1&&!/^convention_[56]_open$/.test(current[0].marker||'')){
  const node=current[0],m=node.marker;let scope;
  if(m==='negation_open')scope={operator:'negation'};
  else if(/^aspect_(bounded|ongoing|habitual)_open$/.test(m||''))scope={operator:'aspect',aspect:m.slice(7,-5)};
  else if(/^time_(before_speech|at_speech|after_speech|previous_day|current_day|next_day)_open$/.test(m||''))scope={operator:'time',relation:m.slice(5,-5)};
  else if(/^modality_(possible|necessary|permitted|obligated|intended|predicted|counterfactual)_open$/.test(m||''))scope={operator:'modality',mode:m.slice(9,-5)};
  else fail();
  current=node.children||fail();
  if(marker(current[0],'confidence_open')){
   if(scope.operator!=='modality'||!['possible','necessary','predicted'].includes(scope.mode))fail();
   const strength=decimal(current[0].children);if(!/^(?:0|1|0\.[0-9]*[1-9])$/.test(strength))fail();
   scope.strength=strength;current=current.slice(1);
  }
  scopes.push(scope);if(scopes.length>64)fail();
 }
 if(current.length!==1)fail();const node=current[0],completed=marker(node,'convention_6_open');
 if(!completed&&!marker(node,'convention_5_open'))fail();
 const head=node.children?.at(-1),runtime=head?.runtime_state;if(![0,1,2].includes(runtime))fail();
 let participants;
 if(completed){
  if(node.children.length!==4)fail();const [actor,destination,nested]=node.children;
  exactRoot(head,'MOV:110','middle',runtime);participants=directed(nested,null);
  if(!same(role(actor,'actor','low'),participants.load)||!same(role(destination,'destination','high'),participants.destination))fail();
 }else participants=directed(node,runtime);
 return {profile:'EZCARRY-INVERSE-1',speech_act:observed.speech_act,scopes,
  predicate:completed?'completed_destination_carrying':'ongoing_destination_carrying',runtime_state:runtime,participants,
  convention_codes:completed?[6,5,4,3]:[5,4,3],
  meaning:{destination:'spatial',same_load:true,same_carrying_event:true,carrier_distinct_from_load:true,culmination_part_of_event_type:completed,receipt_asserted:false},
  limitations:['The recovered speech act distinguishes assertions from commands; a command does not assert that the requested event occurred.',
   'The predicate and its commitments are inside the recovered scope operators; negation, modality, ongoing and habitual scope do not by themselves assert a current completed event.',
   'Recovers this bounded convention profile, not arbitrary sentences, original IR node IDs or English spelling.',
   'Repeated reference sounds are checked for consistency; shared identity is asserted by the learned convention, not proved about external objects. Homophones and untagged referents can remain ambiguous.',
   'This is a strict MIDI inverse, not recognition of arbitrary recorded or human-played audio.']};
}
