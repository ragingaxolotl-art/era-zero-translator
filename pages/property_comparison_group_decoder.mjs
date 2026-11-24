import {strictSemanticReader} from './strict_semantic_reader.mjs?v=ordinary-comparatives-1';
import {readPropertyComparison} from './property_comparison_decoder.mjs?v=ordinary-comparatives-1';
import {readContextualStandard} from './contextual_standard_decoder.mjs?v=ordinary-comparatives-1';

// Existing named-state roots that can accompany a material comparison. No new
// predicate meaning or musical frame is introduced by this inverse.
const stateRoots=new Set(['LIF:001','LIF:002','LIF:011','LIF:012','WRN:001','REP:001','MIN:201','MOV:201','MAT:001']);
function readNamedState(reader,subtree,fail){
 const {current,scopes}=reader.unwrapScopes(n=>n.kind==='root',subtree);
 if(current.length!==2)fail();const [role,head]=current;
 if(role.marker!=='role_bearer_open'||head.kind!=='root'||!stateRoots.has(head.root_id)||
    head.register!=='middle'||![0,1,2].includes(head.runtime_state))fail();
 const bearer=reader.reference(role.children,'middle');
 if(!['phonemic','deictic'].includes(bearer.kind)||bearer.reference_mode==='nominal_class'||bearer.property)fail();
 return {profile:'EZ-NAMED-STATE-1',predicate:head.root_id,scopes,bearer,runtime_state:head.runtime_state};
}
export function decodePropertyComparisonGroupMidi(bytes,atoms){
 const message='Unsupported or malformed property-comparison group.',fail=()=>{throw new Error(message);};
 const reader=strictSemanticReader(bytes,atoms,message);
 const {current,scopes}=reader.unwrapScopes(n=>/^coord_(all_of|any_of|exactly_one)_open$/.test(n.marker||'')||/^conditional_(open|satisfied|unsatisfied|counterfactual)_open$/.test(n.marker||''));
 let operator,groups,conditionStatus;
 if(current.length>1){
  operator='sequence';groups=[[]];
  for(const [index,node] of current.entries()){
   groups.at(-1).push(node);
   const last=node.closing_token===undefined?node:reader.observed.tokens[node.closing_token];
   if(index<current.length-1&&last.boundary_after_beats===1)groups.push([]);
  }
 }else{
  const frame=current[0],coord=frame?.marker?.match(/^coord_(all_of|any_of|exactly_one)_open$/),condition=frame?.marker?.match(/^conditional_(open|satisfied|unsatisfied|counterfactual)_open$/);
  if(!coord&&!condition)fail();
  operator=coord?coord[1]:'conditional';conditionStatus=condition?.[1];groups=[[]];
  const separator=coord?'coord_member':'conditional_then';
  for(const node of frame.children){
   if(node.marker===separator){if(node.children)fail();groups.push([]);}
   else groups.at(-1).push(node);
  }
  if(condition&&groups.length!==2)fail();
 }
 if(groups.length<2||groups.length>8||groups.some(group=>!group.length))fail();
 const members=groups.map(group=>{
  const accepted=[];
  for(const read of [readPropertyComparison,readContextualStandard,readNamedState]){
   try{accepted.push(read(reader,group,fail));}catch{}
  }
  if(accepted.length!==1)fail();
  const {speech_act,limitations,reference_resolution,...content}=accepted[0];
  return content;
 });
 if(!members.some(m=>m.profile==='EZPROPERTYCOMPARE-1'))fail();
 return {profile:'EZPROPERTYCOMPARE-GROUP-1',operator,speech_act:reader.observed.speech_act,scopes,
  ...(conditionStatus?{condition_status:conditionStatus}:{}),members,
  limitations:['Members are proposition contents; the group relationship and outer scopes determine what is asserted or asked.',
   'Comparisons retain both participants and their physical dimension. Contextual adjectives keep their separate local standards.',
   'Two to eight comparison, contextual physical adjective or supported named-state clauses; nested groups and other predicates are not covered.',
   'Reference sounds do not prove external identity. Strict MIDI recovery does not establish microphone recovery.']};
}
