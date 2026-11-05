import {strictSemanticReader} from './strict_semantic_reader.mjs';

// Interpret the released custody convention from performed MIDI and root sounds.
// Never accept source text, semantic IR, compound plans or expected participants.
export function decodePhysicalCustodyMidi(bytes,atoms){
 const message='Unsupported or malformed physical-custody music.';
 const fail=()=>{throw new Error(message);};
 return readCustodyReader(strictSemanticReader(bytes,atoms,message));
}
export function readPhysicalCustodyTree(frame,reader){return readCustodyReader({...reader,observed:{speech_act:'assertion'},unwrapScopes:()=>({current:[frame],scopes:[]})});}
function readCustodyReader(reader){
 const fail=()=>{throw new Error('Malformed physical custody structure.');};
 const {observed,marker,exactRoot,role,unwrapScopes}=reader;
 const {current,scopes}=unwrapScopes(node=>marker(node,'convention_7_open'));
 if(current.length!==1||!marker(current[0],'convention_7_open'))fail();
 const children=current[0].children;if(children?.length!==3)fail();
 const [source,target,head]=children,runtime=head?.runtime_state;
 if(![0,1,2].includes(runtime))fail();
 exactRoot(head,'MAT:210','middle',runtime);
 const holder=role(source,'source','low'),object=role(target,'target','high',true);
 return {profile:'EZCUSTODY-INVERSE-1',speech_act:observed.speech_act,scopes,
  predicate:'practical_physical_custody',runtime_state:runtime,
  participants:{holder,object},convention_codes:[7],
  meaning:{established_practical_control:true,holder_distinct_from_object:true,
   exclusive_control_required:false,ownership_asserted:false,receipt_asserted:false,
   transfer_asserted:false,continuous_physical_influence_required:false},
  limitations:[
   'Custody commitments are inside the recovered scope and speech act; negation, modality and commands do not assert current custody.',
   'Recovers this bounded convention profile, not arbitrary sentences, original IR node IDs or English spelling.',
   'The distinct-participant relation is asserted by the learned convention, not proved about external objects. Equal phonemic labels can denote distinct referents; homophones and untagged referents remain ambiguous.',
   'Custody alone does not identify a prior holder, a transfer event, lawful authority, ownership, exclusivity or willing acceptance.',
   'This is a strict MIDI inverse, not recognition of arbitrary recorded or human-played audio.'
  ]};
}

// Acquisition specializes actualization of the exact nested custody relation.
// It does not actualize the material object or imply a source custodian.
export function decodeCustodyAcquisitionMidi(bytes,atoms){
 const message='Unsupported or malformed custody-acquisition music.';
 const fail=()=>{throw new Error(message);};
 return readAcquisitionReader(strictSemanticReader(bytes,atoms,message));
}
export function readCustodyAcquisitionTree(frame,reader){return readAcquisitionReader({...reader,observed:{speech_act:'assertion'},unwrapScopes:()=>({current:[frame],scopes:[]})});}
function readAcquisitionReader(reader){
 const fail=()=>{throw new Error('Malformed custody acquisition structure.');};
 const {observed,marker,exactRoot,role,unwrapScopes}=reader;
 const {current,scopes}=unwrapScopes(node=>marker(node,'convention_8_open'));
 if(current.length!==1||!marker(current[0],'convention_8_open')||current[0].children?.length!==2)fail();
 const [custody,head]=current[0].children,runtime=head?.runtime_state;
 if(![0,1,2].includes(runtime))fail();exactRoot(head,'ORI:110','middle',runtime);
 if(!marker(custody,'convention_7_open')||custody.children?.length!==3)fail();
 const [source,target,coupling]=custody.children;exactRoot(coupling,'MAT:210','middle',null);
 return {profile:'EZCUSTODY-ACQUISITION-INVERSE-1',speech_act:observed.speech_act,scopes,
  predicate:'completed_physical_custody_acquisition',runtime_state:runtime,
  participants:{holder:role(source,'source','low'),object:role(target,'target','high',true)},
  convention_codes:[8,7],
  meaning:{actualized_referent:'holder_object_custody_relation',custody_immediately_before:false,custody_at_culmination:true,
   holder_distinct_from_object:true,object_creation_asserted:false,object_movement_asserted:false,
   prior_custodian_asserted:false,sourced_transfer_asserted:false,ownership_asserted:false,persistence_after_culmination_asserted:false},
  limitations:[
   'The pre/post commitments define the event inside the recovered scope and speech act; negation and commands do not assert that the transition occurred.',
   'The nested custody relation is the culmination state, not a separate assertion of custody at speech time.',
   'Recovers this bounded MIDI profile, not general discourse, original spelling, external referent identity or recorded audio.',
   'Acquisition does not identify a prior holder or imply that another holder lost control; transfer and delivery require further meaning.'
  ]};
}

// Both relations are read from performed sound, then checked for shared object
// identity. Convention 9 supplies temporal/event linkage, not conjunction.
export function decodeCustodyTransferMidi(bytes,atoms){
 const message='Unsupported or malformed custody-transfer music.';
 const fail=()=>{throw new Error(message);};
 const {observed,marker,exactRoot,role,unwrapScopes}=strictSemanticReader(bytes,atoms,message);
 const {current,scopes}=unwrapScopes(node=>marker(node,'convention_9_open'));
 if(current.length!==1||!marker(current[0],'convention_9_open')||current[0].children?.length!==2)fail();
 const [prior,acquisition]=current[0].children;
 const custody=node=>{
  if(!marker(node,'convention_7_open')||node.children?.length!==3)fail();
  const [source,target,head]=node.children;exactRoot(head,'MAT:210','middle',null);
  return {holder:role(source,'source','low'),object:role(target,'target','high',true)};
 };
 const before=custody(prior);
 if(!marker(acquisition,'convention_8_open')||acquisition.children?.length!==2)fail();
 const after=custody(acquisition.children[0]),head=acquisition.children[1],runtime=head?.runtime_state;
 if(![0,1,2].includes(runtime))fail();exactRoot(head,'ORI:110','middle',runtime);
 if(JSON.stringify(before.object)!==JSON.stringify(after.object))fail();
 return {profile:'EZCUSTODY-TRANSFER-INVERSE-1',speech_act:observed.speech_act,scopes,
  predicate:'completed_physical_custody_transfer',runtime_state:runtime,
  participants:{source:before.holder,object:before.object,recipient:after.holder},convention_codes:[9,7,8,7],
  meaning:{same_object:true,same_reallocation_event:true,source_custody_before:true,source_custody_at_culmination:false,
   recipient_custody_before:false,recipient_custody_at_culmination:true,distinct_source_recipient:true,
   object_distinct_from_holders:true,ownership_asserted:false,willingness_asserted:false,movement_asserted:false,
   carrying_asserted:false,exclusivity_against_third_parties_asserted:false,persistence_after_culmination_asserted:false},
  limitations:[
   'Pre/post commitments define the event inside the recovered scope and speech act; negation, questions, modality and commands do not assert occurrence.',
   'The first custody relation is the source pre-state; recipient acquisition supplies the culmination, not a current independent state assertion.',
   'Equal audible object references are required across phases. External identity and distinctness are asserted by the convention, not established from homophonous names.',
   'This relinquishing custody-transfer sense does not express ownership transfer, retained shared custody, willing acceptance or carrying-mediated delivery.',
   'This bounded MIDI inverse does not recover arbitrary discourse, original spelling or recorded audio.'
  ]};
}
