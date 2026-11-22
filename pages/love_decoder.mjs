import {strictSemanticReader} from './strict_semantic_reader.mjs?v=contextual-width-2';

// The approved three-root bond has a fixed public pronunciation. No source text,
// expected predicate or original graph is supplied to this reader.
export function decodeLoveMidi(bytes,atoms){
  const message='Unsupported or malformed approved love-relation music.';
  const fail=()=>{throw Error(message);};
  const reader=strictSemanticReader(bytes,atoms,message);
  const {current,scopes}=reader.unwrapScopes(node=>node.kind==='root');
  if(current.length!==5)fail();
  const [actor,target,preserved,awakening,bond]=current,runtime=bond?.runtime_state;
  if(![0,1,2].includes(runtime))fail();
  reader.exactRoot(preserved,'LIF:002','middle',null);
  reader.exactRoot(awakening,'LIF:101','middle',null);
  reader.exactRoot(bond,'LIF:210','middle',runtime);
  return {profile:'EZLOVE-INVERSE-1',speech_act:reader.observed.speech_act,scopes,
    predicate:'CMP:44718c92b66443c0c0f03ad7',runtime_state:runtime,
    participants:{actor:reader.role(actor,'actor','low'),target:reader.role(target,'target','high')},
    meaning:{established_life_bond:true,self_awakening_facet:true,preserved_unexpressed_self_facet:true,
      qualifiers_are_separate_events:false,...(runtime===2?{poetic_reading:'never_finished_becoming'}:{})},
    limitations:['This is the approved DBA poetic bond, not every English sense of love.',
      'The num poetic reading does not change the definition of runtime state 2.',
      'Audible references do not establish external identity or original spelling.',
      'This profile reads strict MIDI; it does not prove general recorded-audio recovery.']};
}
