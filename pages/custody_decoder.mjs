import {strictSemanticReader} from './strict_semantic_reader.mjs';

// Interpret the released custody convention from performed MIDI and root sounds.
// Never accept source text, semantic IR, compound plans or expected participants.
export function decodePhysicalCustodyMidi(bytes,atoms){
 const message='Unsupported or malformed physical-custody music.';
 const fail=()=>{throw new Error(message);};
 const {observed,marker,exactRoot,role,unwrapScopes}=strictSemanticReader(bytes,atoms,message);
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
