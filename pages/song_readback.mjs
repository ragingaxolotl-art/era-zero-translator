import {savedQualityLabel} from './story_saved_adjectives.mjs?v=ordinary-comparatives-1';
import {expandChordMidi} from './compact_chords.mjs?v=ordinary-comparatives-1';
import {decodeSupportedMeaningWithDrafts} from './semantic_music_dispatch.mjs?v=ordinary-time-1';
import {describeClaim,describeRuntime} from './meaning_readback.mjs?v=field-repairs-1';
import {feltProperties} from './story_qualities.mjs?v=information-storage-1';
import {storyWords} from './story_words.mjs?v=information-storage-1';
import {contextualPropertyLabel} from './story_contextual_properties.mjs?v=contextual-modifiers-1';

const labels=new Map([...storyWords.map(r=>[r.id,r.word]),...Object.entries(feltProperties).map(([word,id])=>[id,word])]);
function identity(value){
  if(value.kind==='deictic')return ({speaker:'the speaker',speaker_group:'the speaker’s group',addressee:'the listener'})[value.role]||value.role;
  if(value.kind==='domain')return ({people:'people',things:'things',contextual:'the contextual group'})[value.domain];
  return value.phonemes?.join(' ')||value.kind;
}
function comparisonSummary(meaning){
 const dimension={mass:'physical mass',thermodynamic_temperature:'thermodynamic temperature',luminance:'surface luminance'}[meaning.dimension];
 const relation={greater_than:'greater than',less_than:'less than',equal:'equal to',at_least:'at least',at_most:'at most',not_equal:'different from'}[meaning.relation];
 const scopes=meaning.scopes.map(s=>s.operator==='time'?'time_'+s.relation:s.operator==='modality'?'modality_'+s.mode:s.operator);
 const supported=new Set(['negation','time_before_speech','time_at_speech','time_after_speech','time_previous_day','time_current_day','time_next_day','modality_possible','modality_necessary','modality_predicted']);
 const claim=dimension+' '+relation+' the comparison participant’s';
 const description=scopes.every(s=>supported.has(s))&&!meaning.scopes.some(s=>s.strength!==undefined)?describeClaim(claim,scopes,meaning.speech_act):'Scoped '+claim+'; see complete ordered scope details.';
 return description+' Bearer = '+identity(meaning.participants.bearer)+'; comparison participant = '+identity(meaning.participants.comparison_standard)+'.';
}
export async function readSongLine(bytes,atoms,records,chords,adjectives){
  const melody=chords?expandChordMidi(bytes,atoms):bytes;
  const m=await decodeSupportedMeaningWithDrafts(melody,atoms,records,{allowDraft:true,adjectives});
  const label=id=>contextualPropertyLabel(id)||(typeof id==='object'?savedQualityLabel(id,adjectives,i=>identity(m.entities[i].identity)):labels.get(id)||atoms.find(a=>a.canonical_id===id)?.title||id);
  const words=[];
  if(m.events){
    for(const [i,e] of m.events.entries()){
      const binding=e.arguments.map(a=>{
        const options=[a,...a.alternatives||[]].map(o=>identity(m.entities[o.entity].identity)+(o.properties.length?' ('+o.properties.map(label).join(', ')+')':''));
        return a.role+' = '+options.join(' or ');
      }).join(', ');
      const relation=m.relations.find(r=>r.kind==='condition'&&r.events.includes(i));
      const prefix=relation?(relation.events[0]===i?'Condition · ':'Consequence if the condition holds · '):'';
      words.push(prefix+describeClaim(label(e.predicate)+(e.condition?' · '+label(e.condition):''),e.scopes,m.speech_act,e.quantifier,e.negated_quantifier)+' '+binding+'.');
    }
    for(const r of m.relations){
      const [a,b]=r.events.map(i=>i+1);
      words.push(r.kind==='before'?'Action '+a+' occurs before action '+b+'.':r.kind==='condition'?'Action '+b+' depends on action '+a+'.':'Actions '+a+' and '+b+' both apply.');
    }
  }else if(m.profile==='EZPROPERTYCOMPARE-GROUP-1'){
    const relation={sequence:'The relationship places the clauses in temporal order.',all_of:'The relationship joins all clause contents, without specifying temporal order.',any_of:'The relationship requires at least one clause and permits both.',exactly_one:'The relationship requires exactly one clause.',conditional:'The second clause is conditional on the first; neither is asserted independently.'}[m.operator];
    words.push((m.speech_act==='question'?'Question about the complete relationship: ':m.speech_act==='assertion'?'Relationship: ':m.speech_act+' about the relationship: ')+relation);
    if(m.scopes.length)words.push('The whole relationship is scoped; see the complete ordered scope details.');
    if(m.condition_status&&m.condition_status!=='open')words.push('Condition status: '+m.condition_status+'.');
    m.members.forEach((member,index)=>{
      let description;
      if(member.profile==='EZPROPERTYCOMPARE-1')description=comparisonSummary(member);
      else {
        const name=member.standard?member.standard.norm+' under its own contextual standard':label(member.predicate);
        const scopes=member.scopes.map(s=>s.operator==='time'?'time_'+s.relation:s.operator==='modality'?'modality_'+s.mode:s.operator==='aspect'?'aspect_'+s.aspect:s.operator);
        const supported=new Set(['negation','time_before_speech','time_at_speech','time_after_speech','time_previous_day','time_current_day','time_next_day','modality_possible','modality_necessary','modality_predicted','aspect_ongoing']);
        description=(scopes.every(s=>supported.has(s))&&!member.scopes.some(s=>s.strength!==undefined)?describeClaim(name,scopes):'Scoped '+name+'; see complete scope details.')+' Bearer = '+identity(member.bearer)+'.';
      }
      words.push('Clause '+(index+1)+' content: '+description+' '+describeRuntime(member.runtime_state));
    });
  }else if(m.profile==='EZPROPERTYCOMPARE-1'){
    words.push(comparisonSummary(m));
  }else if(m.profile==='EZCONTEXTUAL-GROUP-INVERSE-1'){
    const relation={sequence:'The relationship places the clauses in temporal order.',all_of:'The relationship includes all clauses, without specifying temporal order.',any_of:'The relationship requires at least one clause and permits both.',exactly_one:'The relationship requires exactly one clause.',conditional:'The relationship makes the second clause conditional on the first; neither is asserted independently.'}[m.operator];
    words.push((m.speech_act==='question'?'Question about the group. ':m.speech_act==='assertion'?'':m.speech_act+' over the group. ')+relation);
    if(m.scopes.length){
      const scopes=m.scopes.map(s=>s.operator==='time'?'time_'+s.relation:s.operator==='modality'?'modality_'+s.mode:s.operator==='aspect'?'aspect_'+s.aspect:s.operator);
      const supported=new Set(['negation','time_before_speech','time_at_speech','time_after_speech','modality_possible','modality_necessary','modality_predicted','aspect_ongoing']);
      words.push(scopes.every(s=>supported.has(s))&&!m.scopes.some(s=>s.strength!==undefined)?'Whole group: '+describeClaim('the entire relationship',scopes,m.speech_act):'The entire relationship has additional scope details shown in the complete meaning.');
    }
    if(m.condition_status&&m.condition_status!=='open')words.push('Condition status: '+m.condition_status+'.');
    m.members.forEach((member,index)=>{
      const scopes=member.scopes.map(s=>s.operator==='time'?'time_'+s.relation:s.operator==='modality'?'modality_'+s.mode:s.operator==='aspect'?'aspect_'+s.aspect:s.operator);
      const supported=new Set(['negation','time_before_speech','time_at_speech','time_after_speech','time_previous_day','time_current_day','time_next_day','modality_possible','modality_necessary','modality_predicted','aspect_ongoing']);
      const claim=scopes.every(s=>supported.has(s))?describeClaim(member.standard.norm,scopes):'Scoped '+member.standard.norm+'; see complete scope details.';
      words.push('Clause '+(index+1)+' content: '+claim+' Bearer = '+identity(member.bearer)+'. '+describeRuntime(member.runtime_state));
    });
    words.push('Comparison standards are local to each adjective; no numerical cutoffs are stated.');
  }else if(m.knowledge)words.push('Knowledge of '+(m.knowledge.question.additional?'an additional':'a')+' wanted value. Knower = '+identity(m.knowledge.knower)+', wanter = '+identity(m.knowledge.question.restriction.wanter)+'. '+describeClaim('knows which value',m.knowledge.scopes));
  else if(m.fault)words.push(describeClaim('correct the '+(typeof m.fault.type_label==='string'?m.fault.type_label+' ':'')+'fault',m.scopes.map(s=>['possible','necessary'].includes(s)?'modality_'+s:s),m.speech_act)+' Actor = '+identity(m.actor)+'.');
  else if(m.discovery)words.push(identity(m.discovery.actor)+' found the referenced item. '+identity(m.requirement.actor)+' is required to erase that same item.');
  else if(m.standard?.kind==='contextual'&&m.bearer){
    const dimension=({physical_width:'physical width',thermodynamic_temperature:'temperature',mass:'mass',luminance:'surface luminance',surface_texture:'surface texture'})[m.dimension]||m.dimension;
    const scopes=(m.scopes||[]).map(s=>s.operator==='time'?'time_'+s.relation:s.operator==='modality'?'modality_'+s.mode:s.operator==='aspect'?'aspect_'+s.aspect:s.operator);
    const supported=new Set(['negation','time_before_speech','time_at_speech','time_after_speech','time_previous_day','time_current_day','time_next_day','modality_possible','modality_necessary','modality_predicted','aspect_ongoing']);
    const label=m.standard.norm+' ('+dimension+')';
    words.push(scopes.every(s=>supported.has(s))?describeClaim(label,scopes,m.speech_act):'Recovered a scoped '+label+' reading; the complete meaning contains additional scope details.');
    words.push('Bearer = '+identity(m.bearer)+'. The standard is local; no numerical cutoff is stated.');
  }
  else if(typeof m.predicate==='string'){
    const roles=Array.isArray(m.participants)?m.participants.map(p=>[p.role,p.reference]):Object.entries(m.participants||{});
    const scopes=(m.scopes||[]).map(scope=>typeof scope==='string'?scope:scope.operator==='time'?'time_'+scope.relation:scope.operator==='aspect'?'aspect_'+scope.aspect:scope.operator);
    if(scopes.every(s=>['time_before_speech','time_at_speech','time_after_speech','negation','aspect_ongoing','modality_possible','modality_necessary'].includes(s)))words.push(describeClaim(label(m.predicate).replaceAll('_',' '),scopes,m.speech_act));
    else words.push('Recovered '+label(m.predicate).replaceAll('_',' ')+'.');
    if(roles.length)words.push(roles.map(([role,ref])=>role+' = '+identity(ref)).join(', ')+'.');
  }
  if(m.runtime_state!==undefined)words.push(describeRuntime(m.runtime_state));
  return {summary:words.join(' '),meaning:m};
}
