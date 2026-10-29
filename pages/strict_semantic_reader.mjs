import {decodeStrictMusicMidi} from './strict_music_decoder.mjs';

// Shared strict grammar reader. Each semantic profile must validate the entire
// remaining tree, including exact lexical conventions, roles and head roots.
export function strictSemanticReader(bytes,atoms,message){
 const fail=()=>{throw new Error(message);};
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
 const unwrapScopes=stop=>{
  let current=tree(0,tokens.length),scopes=[];
 while(current.length===1&&!stop(current[0])){
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
  return {current,scopes};
 };
 return {observed,marker,exactRoot,reference,role,unwrapScopes};
}
