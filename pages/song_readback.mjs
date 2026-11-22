import {savedQualityLabel} from './story_saved_adjectives.mjs';
import {expandChordMidi} from './compact_chords.mjs?v=state-adjectives-1';
import {decodeSupportedMeaningWithDrafts} from './semantic_music_dispatch.mjs?v=meaning-reliability-1';
import {describeClaim,describeRuntime} from './meaning_readback.mjs?v=field-repairs-1';
import {feltProperties} from './story_qualities.mjs';
import {storyWords} from './story_words.mjs?v=state-adjectives-1';

const labels=new Map([...storyWords.map(r=>[r.id,r.word]),...Object.entries(feltProperties).map(([word,id])=>[id,word])]);
function identity(value){
  if(value.kind==='deictic')return ({speaker:'the speaker',speaker_group:'the speaker’s group',addressee:'the listener'})[value.role]||value.role;
  if(value.kind==='domain')return ({people:'people',things:'things',contextual:'the contextual group'})[value.domain];
  return value.phonemes?.join(' ')||value.kind;
}
export async function readSongLine(bytes,atoms,records,chords,adjectives){
  const melody=chords?expandChordMidi(bytes,atoms):bytes;
  const m=await decodeSupportedMeaningWithDrafts(melody,atoms,records,{allowDraft:true,adjectives});
  const label=id=>typeof id==='object'?savedQualityLabel(id,adjectives,i=>identity(m.entities[i].identity)):labels.get(id)||atoms.find(a=>a.canonical_id===id)?.title||id;
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
  }else if(m.knowledge)words.push('Knowledge of '+(m.knowledge.question.additional?'an additional':'a')+' wanted value. Knower = '+identity(m.knowledge.knower)+', wanter = '+identity(m.knowledge.question.restriction.wanter)+'. '+describeClaim('knows which value',m.knowledge.scopes));
  else if(m.fault)words.push(describeClaim('correct the '+(typeof m.fault.type_label==='string'?m.fault.type_label+' ':'')+'fault',m.scopes.map(s=>['possible','necessary'].includes(s)?'modality_'+s:s),m.speech_act)+' Actor = '+identity(m.actor)+'.');
  else if(m.discovery)words.push(identity(m.discovery.actor)+' found the referenced item. '+identity(m.requirement.actor)+' is required to erase that same item.');
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
