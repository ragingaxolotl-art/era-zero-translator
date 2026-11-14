import {contextualContentReference} from './contextual_content.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {informationMusic} from './information_music.mjs';
import {encodeName} from './names.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';

// These nouns name categories of fault. A category does not specify its cause or a repair procedure.
const faultTypes = ['redundancy','checksum','data','memory','network','parity','storage','syntax','timing','transmission'];
const types = new Set(faultTypes);
const restorationTarget = 'REP:110';
const internalFault = 'WRN:000';

export function faultCorrectionPlan(input) {
  if (typeof input !== 'string') return null;
  const text = input.trim().replace(/\s+/g,' ').replace(/’/g,"'");
  const match = /^(we|i|you) (need to|do not need to|don't need to|need not|need to not) (resolve|fix|correct) (the|this|that) (?:([a-z]+) )?(error|fault)(?:\.?\s*\[([012])\])?\.?$/i.exec(text);
  if (!match) return null;
  const [,who,requirement,,determiner,label,,runtime] = match;
  const type = label?.toLowerCase() || null;
  if (type && !types.has(type)) return null;
  const form = requirement.toLowerCase();
  const scopes = form === 'need to' ? ['necessary'] : form === 'need to not' ? ['necessary','negation'] : ['negation','necessary'];
  return {actor:who.toLowerCase() === 'i' ? 'I' : who.toLowerCase(), scopes, determiner:determiner.toLowerCase(), type, runtime:Number(runtime ?? 1)};
}

function faultMeaning(actor,scopes,reference_mode,type_label,runtime_state) {
  return {profile:'EZ-FAULT-CORRECTION-1',status:'draft',speech_act:'assertion',runtime_state,actor,scopes,
    action:{kind:'correct_fault',restoration_root:restorationTarget,event_asserted:false},
    fault:{class_root:internalFault,reference_mode,type_label}};
}

export async function composeFaultCorrection(plan,authority) {
  const {anchor,wrap,lexical,participant,reference} = informationMusic(authority,plan.runtime);
  const who = {we:'speaker_group',I:'speaker',you:'addressee'}[plan.actor];
  const label = await contextualContentReference(plan.determiner+' '+(plan.type || 'error'));
  let events = [
    ...await participant(plan.actor,'actor'), ...await lexical(restorationTarget),
    ...wrap('role_condition',[...await lexical(internalFault,'condition'),...await reference(label,'condition')])
  ];
  for (const scope of [...plan.scopes].reverse()) events = wrap(scope === 'necessary' ? 'modality_necessary' : scope,events);
  return {midi:midiFromScheduledEvents(events,anchor,[0,0]),
    meaning:faultMeaning({kind:'deictic',role:who},plan.scopes,label.reference_mode,plan.type,plan.runtime)};
}

let knownLabels;
async function readFaultType(reference) {
  knownLabels ??= Promise.all(['error',...faultTypes].map(async label => [label,(await encodeName(label)).phonemes.join(' ')]));
  const matches = (await knownLabels).filter(([,phones]) => phones === reference.phonemes.join(' '));
  if (matches.length !== 1) throw Error('Unrecognized fault designation.');
  return matches[0][0] === 'error' ? null : matches[0][0];
}

// The only inputs to the inverse are the played score and the public dictionary.
export async function decodeFaultCorrectionMidi(bytes,atoms) {
  const fail = () => {throw Error('Invalid required fault correction.');};
  const reader = strictSemanticReader(bytes,atoms,'Invalid required fault correction.',{allowDraftInformationPassage:true});
  if (reader.observed.speech_act !== 'assertion') fail();
  const {current,scopes} = reader.unwrapScopes(node => node.marker === 'role_actor_open');
  const operators = scopes.map(s => s.operator === 'modality' && s.mode === 'necessary' && !('strength' in s) ? 'necessary' : s.operator);
  if (!['necessary','negation,necessary','necessary,negation'].includes(operators.join(',')) || current.length !== 3) fail();
  const [subject,restoration,condition] = current;
  const runtime = restoration.runtime_state;
  if (![0,1,2].includes(runtime) || subject.marker !== 'role_actor_open' || condition.marker !== 'role_condition_open') fail();
  const group = subject.children.length === 1 && subject.children[0].marker === 'speaker_group_open';
  const actor = reader.reference(group ? subject.children[0].children : subject.children,'low');
  if (actor.kind !== 'deictic' || !['speaker','addressee'].includes(actor.role) || (group && actor.role !== 'speaker')) fail();
  reader.exactRoot(restoration,restorationTarget,'middle',runtime);
  const [fault,...label] = condition.children;
  reader.exactRoot(fault,internalFault,'middle',runtime);
  const ref = reader.reference(label,'middle');
  if (ref.kind !== 'phonemic' || !['definite_nominal','proximal_nominal','distal_nominal'].includes(ref.reference_mode) || ref.instance_code !== null) fail();
  const type = await readFaultType(ref);
  return faultMeaning(group ? {kind:'deictic',role:'speaker_group'} : actor,operators,ref.reference_mode,type,runtime);
}

export function describeFaultCorrection(plan) {
  const subject = {we:'Our group',I:'I',you:'You'}[plan.actor];
  const needs = plan.actor === 'we' ? 'needs' : 'need';
  const action = plan.scopes[0] === 'negation' ? (plan.actor === 'we' ? 'does' : 'do')+' not need to correct'
    : plan.scopes.includes('negation') ? needs+' to refrain from correcting' : needs+' to correct';
  return subject+' '+action+' '+plan.determiner+' '+(plan.type ? plan.type+' ' : '')+'fault.';
}
