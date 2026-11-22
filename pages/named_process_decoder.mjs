// Older named sentences place the participants before the predicate. Their existing
// role markers and registers distinguish a mover from a destination and a repairer from a target.
import {strictSemanticReader} from './strict_semantic_reader.mjs?v=meaning-reliability-1';

const rolesByRoot=new Map([
  ['REP:110',['actor','target']],['REP:111',['actor','target']],
  ['MOV:110',['actor','destination']],['MOV:111',['actor','destination']]
]);

export function decodeNamedProcessMidi(bytes,atoms){
  const problem='Invalid named process performance.';
  const reader=strictSemanticReader(bytes,atoms,problem);
  const {current,scopes}=reader.unwrapScopes(node=>node.kind==='root');
  const head=current.at(-1),roles=rolesByRoot.get(head?.root_id);
  if(!roles||current.length!==3||![0,1,2].includes(head.runtime_state))throw Error(problem);
  reader.exactRoot(head,head.root_id,'middle',head.runtime_state);
  const participants={
    [roles[0]]:reader.role(current[0],roles[0],'low'),
    [roles[1]]:reader.role(current[1],roles[1],'high')
  };
  return {profile:'EZ-NAMED-PROCESS-1',speech_act:reader.observed.speech_act,
    predicate:head.root_id,runtime_state:head.runtime_state,participants,scopes};
}
