// Shared public draft meaning and score shape, used by both sentence composers.
// This extends the existing erasure construction; it adds no root or sound code.
export const ERASURE='erase_stored_object';
export const isStoredInformationTarget=head=>/^(?:programs?|files?|records?|messages?|documents?|backups?|logs?|entries|entry)$/.test(head||'');
export const erasureLabel='remove the item from the contextual store';
export function erasurePropertyNeedsPhase(property,adjectives){
  return property==='DAT:000'||!!(property&&typeof property==='object'&&adjectives?.byId.get(property.local_id)?.atomicTargets?.includes('DAT:000'));
}

export async function scoreErasure(music){
  const {wrap,lexical}=music;
  return wrap(ERASURE,[...await lexical('ORI:110'),
    ...wrap('role_result',wrap('negation',await lexical('DAT:000')))],true);
}

export function readErasure(node,reader){
  if(node?.marker!==ERASURE+'_open')return null;
  const fail=()=>{throw Error('Invalid stored-information erasure.');};
  if(node.children?.length!==2)fail();
  const [transition,result]=node.children,runtime=transition.runtime_state;
  if(![0,1,2].includes(runtime)||result?.marker!=='role_result_open'||result.children?.length!==1)fail();
  const negative=result.children[0];
  if(negative.marker!=='negation_open'||negative.children?.length!==1)fail();
  reader.exactRoot(transition,'ORI:110','middle',runtime);
  reader.exactRoot(negative.children[0],'DAT:000','middle',runtime);
  return {id:ERASURE,state:runtime};
}

export function erasureSense(authority,{mode,scopes,speechAct}){
  // The old requested-deletion definition must not describe an asserted past event.
  const id=mode==='progressive'?'GSE:044':speechAct==='command'||scopes.includes('modality_necessary')?'GSE:043':'GSE:045';
  const sense=authority.game_story_senses.find(s=>s.sense_id===id);
  if(!sense)throw Error('The shared erasure definition is missing.');
  return {...sense,target_id:ERASURE};
}
