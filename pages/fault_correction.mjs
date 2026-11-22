import {clauseSyntax} from './dictionary_clauses.mjs?v=sentence-diagnostics-1';
import {scoreRoleReference,readRoleReference} from './dictionary_clause_music.mjs?v=sentence-diagnostics-1';
import {midiFromScheduledEvents} from './engine.mjs';
import {informationMusic} from './information_music.mjs?v=meaning-reliability-1';
import {encodeName} from './names.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs?v=meaning-reliability-1';

// These nouns name categories of fault. A category does not specify its cause or a repair procedure.
const faultTypes = ['redundancy','duplicate','checksum','data','memory','network','parity','storage','syntax','timing','transmission','backup','sensor','valve','power','clock','disk'];
const types = new Set(faultTypes);
const restorationTarget = 'REP:110';
const internalFault = 'WRN:000';

function faultPlan(input,acceptCategory=false) {
  const line=clauseSyntax(input);if(!line||line.being||!line.scopes.includes('modality_necessary'))return null;
  const m=/^(?:resolve|fix|correct) (the|this|that|a|an) (?:([a-z]+|"[a-z]+") )?(?:error|fault)$/i.exec(line.tail);
  if(!m)return null;
  const type=m[2]?.toLowerCase()||null;
  if(!acceptCategory&&type&&!types.has(type)&&!type.startsWith('"'))return null;
  return {actor:line.subject,scopes:line.scopes.map(s=>s.replace('modality_','')),
    determiner:m[1].toLowerCase(),type:type?.replaceAll('"','')||null,runtime:line.runtime,speechAct:line.speechAct};
}

export function faultCorrectionPlan(input){return faultPlan(input);}
export function faultCategoryReading(input,answers){
  if(!/\b(?:error|fault)\b/i.test(input))return null;
  const proposed=faultPlan(input,true);
  if(!proposed||!proposed.type||types.has(proposed.type)||faultPlan(input))return null;
  if(answers.faultCategory==='type')return {faultPlan:proposed};
  if(answers.faultCategory==='other')return {unsupported:true};
  return {question:{key:'faultCategory',prompt:'Does “'+proposed.type+'” name the kind of fault?',
    options:[{value:'type',label:'Use it as a fault category'},{value:'other',label:'It describes the fault another way'}]}};
}

function faultMeaning(actor,scopes,reference_mode,type_label,runtime_state,speech_act) {
  return {profile:'EZ-FAULT-CORRECTION-1',status:'draft',speech_act,runtime_state,actor,scopes,
    action:{kind:'correct_fault',restoration_root:restorationTarget,event_asserted:false},
    fault:{class_root:internalFault,reference_mode,type_label}};
}

export async function composeFaultCorrection(plan,authority) {
  const music=informationMusic(authority,plan.runtime),{anchor,wrap,lexical}=music;
  const actor=await scoreRoleReference(plan.actor,'actor',music);
  const fault=await scoreRoleReference(plan.determiner+' '+(plan.type||'error'),'condition',music);
  let events=[...wrap('role_actor',actor.notes),...await lexical(restorationTarget),
    ...wrap('role_condition',[...await lexical(internalFault,'condition'),...fault.notes])];
  for(const scope of [...plan.scopes].reverse())events=wrap(['necessary','possible'].includes(scope)?'modality_'+scope:scope,events);
  return {midi:midiFromScheduledEvents(events,anchor,plan.speechAct==='question'?[0,2]:[0,0]),
    meaning:faultMeaning(actor.identity,plan.scopes,fault.identity.reference_mode,await readFaultType(fault.identity),plan.runtime,plan.speechAct)};

}

let knownLabels;
async function readFaultType(reference) {
  knownLabels ??= Promise.all(['error',...faultTypes].map(async label => [label,(await encodeName(label)).phonemes.join(' ')]));
  const matches = (await knownLabels).filter(([,phones]) => phones === reference.phonemes.join(' '));
  if (matches.length !== 1) return {phonemes:reference.phonemes};
  return matches[0][0] === 'error' ? null : matches[0][0];
}

// The only inputs to the inverse are the played score and the public dictionary.
export async function decodeFaultCorrectionMidi(bytes,atoms) {
  const fail = () => {throw Error('Invalid required fault correction.');};
  const reader = strictSemanticReader(bytes,atoms,'Invalid required fault correction.',{allowDraftInformationPassage:true});
  const act=reader.observed.speech_act;if(!['assertion','question'].includes(act))fail();
  const {current,scopes} = reader.unwrapScopes(node => node.marker === 'role_actor_open');
  const operators=scopes.map(s=>{
    if(s.operator==='modality'&&['possible','necessary'].includes(s.mode)&&s.strength===undefined)return s.mode;
    if(s.operator==='negation')return 'negation';
    if(s.operator==='ability')return 'ability';
    if(s.operator==='time'&&['previous_day','current_day','next_day','before_speech','after_speech'].includes(s.relation))return 'time_'+s.relation;
    fail();
  });
  if(!operators.includes('necessary')||current.length!==3)fail();
  const [subject,restoration,condition] = current;
  const runtime = restoration.runtime_state;
  if (![0,1,2].includes(runtime) || subject.marker !== 'role_actor_open' || condition.marker !== 'role_condition_open') fail();
  const actor=readRoleReference(subject.children,'actor',reader);
  reader.exactRoot(restoration,restorationTarget,'middle',runtime);
  const [fault,...label] = condition.children;
  reader.exactRoot(fault,internalFault,'middle',runtime);
  const ref=readRoleReference(label,'condition',reader);
  if (ref.kind !== 'phonemic' || !['definite_nominal','proximal_nominal','distal_nominal','indefinite_singular'].includes(ref.reference_mode) || ref.instance_code !== null) fail();
  const type = await readFaultType(ref);
  return faultMeaning(actor,operators,ref.reference_mode,type,runtime,act);
}

export function describeFaultCorrection(plan) {
  const subject = {we:'Our group',I:'I',you:'You'}[plan.actor]||plan.actor;
  if(plan.speechAct==='question'||plan.scopes.some(s=>s==='possible'||s==='ability'||s.startsWith('time_')))return (plan.speechAct==='question'?'Question':'Statement')+' about '+subject+' correcting '+plan.determiner+' '+(plan.type?plan.type+' ':'')+'fault. Scope · '+plan.scopes.map(s=>s.replaceAll('_',' ')).join(' → ')+'.';
  const needs = ['you','I'].includes(plan.actor)?'need':'needs';
  const action = plan.scopes[0] === 'negation' ? (['you','I'].includes(plan.actor)?'do':'does')+' not need to correct'
    : plan.scopes.includes('negation') ? needs+' to refrain from correcting' : needs+' to correct';
  return subject+' '+action+' '+plan.determiner+' '+(plan.type ? plan.type+' ' : '')+'fault.';
}
