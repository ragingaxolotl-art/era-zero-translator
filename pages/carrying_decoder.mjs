import {strictSemanticReader} from './strict_semantic_reader.mjs';

// Independent interpretation of the released EZLEX conventions 3–6. Inputs are
// performed MIDI and the root sound inventory, never English, IR or event plans.
const fail=()=>{throw new Error('Unsupported or malformed destination-carrying music.');};
const same=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
export function decodeDestinationCarryingMidi(bytes,atoms){
 const {observed,marker,exactRoot,role,unwrapScopes}=strictSemanticReader(bytes,atoms,'Unsupported or malformed destination-carrying music.');
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
 const {current,scopes}=unwrapScopes(node=>/^convention_[56]_open$/.test(node.marker||''));
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
