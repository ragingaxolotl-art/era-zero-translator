export const INTAKE_FORMAT='EZ-CONCEPT-QUEUE-1';
export const INTAKE_KEY='era-zero-concept-queue-v1';
const STATES=new Set(['observed','triaged','semantic_review','approved','rejected','superseded','future_era']);
const POS=new Set(['noun','noun_phrase','verb','verb_phrase','adjective','adverb','other']);
const compact=value=>String(value??'').normalize('NFC').trim().replace(/\s+/g,' ');
const capped=(value,max=1000)=>compact(value).slice(0,max);
const validId=value=>/^EZC:[0-9a-z-]{8,80}$/.test(value);

export function createProposal(fields,{id=`EZC:${globalThis.crypto?.randomUUID?.()||`${Date.now().toString(36)}-${Math.random().toString(36).slice(2)}`}`,now=new Date().toISOString()}={}){
  const submitted=capped(fields.submitted_form,180),meaning=capped(fields.intended_meaning,1000),context=capped(fields.example_context,1000);
  if(!submitted||!meaning||!context)throw new Error('A proposal needs a word, intended meaning, and example context.');
  if(!validId(id))throw new Error('Invalid proposal ID.');
  const pos=fields.proposed_part_of_speech;
  if(!POS.has(pos))throw new Error('Select a part of speech.');
  return{proposal_id:id,format:INTAKE_FORMAT,status:'observed',submitted_form:submitted,intended_meaning:meaning,example_context:context,proposed_part_of_speech:pos,corpus_frequency:Number.isSafeInteger(fields.corpus_frequency)&&fields.corpus_frequency>=0?fields.corpus_frequency:1,candidate_routes:Array.isArray(fields.candidate_routes)?fields.candidate_routes.map(x=>capped(x,80)).slice(0,12):[],candidate_target:capped(fields.candidate_target,80)||null,collision_notes:'',reviewer_decision:'',reviewer_name:'',reviewed_target:null,approved_surface_mapping:false,entailment_confirmed:false,created_at:now,updated_at:now,history:[{at:now,status:'observed',note:'Submitted for review.'}]};
}

export function validateQueue(queue,data){
  if(!queue||queue.format!==INTAKE_FORMAT||queue.version!=='1.0.0'||!Array.isArray(queue.proposals)||queue.proposals.length>5000)throw new Error('Unsupported or oversized concept queue.');
  const ids=new Set(),targets=new Set([...(data.atoms||[]).map(x=>x.canonical_id),...(data.compounds||[]).map(x=>x.compound_id)]);
  for(const p of queue.proposals){
    if(!p||p.format!==INTAKE_FORMAT||!validId(p.proposal_id)||ids.has(p.proposal_id)||!STATES.has(p.status)||!POS.has(p.proposed_part_of_speech))throw new Error('Invalid or duplicate concept proposal.');
    ids.add(p.proposal_id);
    for(const field of ['submitted_form','intended_meaning','example_context'])if(!compact(p[field])||String(p[field]).length>1100)throw new Error(`Invalid proposal ${field}.`);
    if(p.status==='approved'&&(!p.approved_surface_mapping||p.entailment_confirmed!==true||!targets.has(p.reviewed_target)||!p.reviewer_decision||!p.collision_notes||!p.reviewer_name))throw new Error('An approved local mapping needs a canonical target and recorded review.');
    if(p.status!=='approved'&&p.approved_surface_mapping)throw new Error('Unapproved proposal cannot carry an active mapping.');
  }
  return queue;
}

export function emptyQueue(){return{format:INTAKE_FORMAT,version:'1.0.0',scope:'browser_local_noncanonical',proposals:[]}}
export function loadQueue(storage,data){const raw=storage.getItem(INTAKE_KEY);return raw?validateQueue(JSON.parse(raw),data):emptyQueue()}
export function saveQueue(storage,queue,data){validateQueue(queue,data);storage.setItem(INTAKE_KEY,JSON.stringify(queue));return queue}
export function addProposal(queue,proposal,data){const next={...queue,proposals:[...queue.proposals,proposal]};return validateQueue(next,data)}

export function reviewProposal(queue,id,decision,data,{now=new Date().toISOString()}={}){
  const existing=queue.proposals.find(p=>p.proposal_id===id);
  if(!existing)throw new Error('Proposal not found.');
  const status=decision.status;
  if(!['triaged','semantic_review','approved','rejected','superseded','future_era'].includes(status))throw new Error('Invalid review decision.');
  const note=capped(decision.reviewer_decision,1000),collisions=capped(decision.collision_notes,1000),reviewer=capped(decision.reviewer_name,120),target=capped(decision.reviewed_target,80)||null;
  if(!note||!reviewer)throw new Error('A review needs a reviewer and a written decision.');
  if(status==='approved'){
    const targets=new Set([...(data.atoms||[]).map(x=>x.canonical_id),...(data.compounds||[]).map(x=>x.compound_id)]);
    if(!decision.entailment_confirmed||!collisions||!targets.has(target))throw new Error('A local mapping needs confirmed entailment, collision review, and an existing canonical target.');
    if(!['noun','noun_phrase','verb','verb_phrase','adjective','adverb'].includes(existing.proposed_part_of_speech))throw new Error('Unsupported part of speech for a local mapping.');
  }
  const proposals=queue.proposals.map(p=>p.proposal_id===id?{...p,status,reviewer_decision:note,collision_notes:collisions,reviewer_name:reviewer,reviewed_target:status==='approved'?target:null,approved_surface_mapping:status==='approved',entailment_confirmed:status==='approved',updated_at:now,history:[...p.history,{at:now,status,note}]}:p);
  return validateQueue({...queue,proposals},data);
}

export function approvedLocalSenses(queue,data){validateQueue(queue,data);return queue.proposals.filter(p=>p.status==='approved').map(p=>{
  const target=p.reviewed_target,route=target.startsWith('CMP:')?'compound':'atom';
  return{sense_id:`LOCAL:${p.proposal_id}`,lemma:p.submitted_form,surface_forms:[p.submitted_form],part_of_speech:p.proposed_part_of_speech,sense_key:'reviewed_local_surface_mapping',route,target_id:target,definition:p.intended_meaning,selection_cues:[p.example_context],generalization:`Local noncanonical English mapping reviewed by ${p.reviewer_name}. ${p.reviewer_decision}`,fidelity:'reviewed_local_mapping',local_review:true,controlled_input_allowed:false};
})}
