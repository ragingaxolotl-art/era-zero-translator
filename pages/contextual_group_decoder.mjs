import {strictSemanticReader} from './strict_semantic_reader.mjs?v=partial-word-flow-1';
import {readContextualStandard} from './contextual_standard_decoder.mjs?v=contextual-groups-1';

// The renderer already gives unordered groups explicit frames and separators.
// Ordered groups use a one-beat boundary between complete clauses. Reuse those
// established sounds; a half-beat juxtaposition is not evidence of "then".
export function decodeContextualGroupMidi(bytes,atoms){
 const message='Unsupported or malformed contextual-adjective group.',fail=()=>{throw new Error(message);};
 const reader=strictSemanticReader(bytes,atoms,message);
 const {current,scopes}=reader.unwrapScopes(n=>/^coord_(all_of|any_of|exactly_one)_open$/.test(n.marker||'')||/^conditional_(open|satisfied|unsatisfied|counterfactual)_open$/.test(n.marker||''));
 let operator,groups,conditionStatus;
 if(current.length>1){
  operator='sequence';groups=current.map(node=>[node]);
  for(const node of current.slice(0,-1)){
   const last=reader.observed.tokens[node.closing_token];
   if(!last||last.boundary_after_beats!==1)fail();
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
  const {profile,speech_act,limitations,...content}=readContextualStandard(reader,group,fail);
  return content;
 });
 return {profile:'EZCONTEXTUAL-GROUP-INVERSE-1',operator,speech_act:reader.observed.speech_act,scopes,
  ...(conditionStatus?{condition_status:conditionStatus}:{}),members,
  limitations:['Members are proposition contents; the group operator and outer scopes determine what is asserted or asked.',
   'Each adjective retains its own local comparison standard. Matching reference sounds do not prove external identity.',
   'Supports two to eight physical contextual-adjective clauses, without nested groups or other predicate profiles.',
   'Strict MIDI recovery; general microphone recovery is not established.']};
}
