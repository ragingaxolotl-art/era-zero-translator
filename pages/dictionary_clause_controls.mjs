import {describeClaim,describeRuntime} from './meaning_readback.mjs?v=field-repairs-1';
import {everydayMeaning} from './everyday.mjs?v=partial-word-flow-1';
import {scoreDictionaryClause} from './dictionary_clause_music.mjs?v=partial-word-flow-2';
import {compactChordMidi} from './compact_chords.mjs?v=partial-word-flow-1';
import {sentenceReadiness} from './sentence_readiness.mjs?v=partial-word-flow-2';

const scopeLabels={modality_necessary:'required',modality_possible:'possible',ability:'able',negation:'negated',aspect_ongoing:'ongoing',time_before_speech:'past',time_after_speech:'future',time_current_day:'today',time_next_day:'tomorrow',time_previous_day:'yesterday'};

export async function mountDictionaryClause(container,plan,authority,{document=globalThis.document,player,add,download,wordLink,remember,selectReading,isCurrent,onError,onStatus=()=>{}}) {
  const make=(tag,text)=>{const el=document.createElement(tag);if(text!==undefined)el.textContent=text;return el;};
  const card=make('article');card.className='candidate dictionary-clause';
  const word=plan.readings[0].word, output=make('div');
  card.append(make('h3',plan.input));container.append(card);
  const title=reading=>authority.atoms.find(a=>a.canonical_id===reading.root)?.title || (reading.root==='erase_stored_object'?'Remove the stored item':reading.root);
  let picker,version=0,preferred=plan.preferred;
  const missingDefinition=plan.needsDefinition&&preferred<0;
  if(missingDefinition){
    card.append(make('p','“'+word+'” needs a definition before this sentence can play. Define the action or quality you intend, then return to this sentence.'));
    if(wordLink)card.append(wordLink(plan.input,word,plan.readings[0].quality?'adjective':'verb'));
  }
  if(plan.readings.length>1||plan.needsDefinition){
    let holder=card;
    if(missingDefinition){
      holder=make('details');holder.className='definition-alias-options';
      holder.append(make('summary','Or define it using an existing meaning'));
      holder.append(make('p','This is a dictionary to choose from, not a list of suggested translations. Select one only if its full definition matches what you mean.'));
      card.append(holder);
    }
    const label=make('label',(plan.needsDefinition&&plan.preferred<0?'What does “':'Meaning of “')+word+(plan.needsDefinition&&plan.preferred<0?'” mean here?':'” in this sentence'));
    picker=make('select');label.append(picker);holder.append(label);
    if(plan.needsDefinition){const opt=make('option','Choose the meaning you intend');opt.value='';picker.append(opt);}
    plan.readings.forEach((r,i)=>{const wording=r.terms?[...r.terms].sort().slice(0,3).join(' / '):r.sense.lemma;const description=wording+' — '+title(r);const opt=make('option',description.slice(0,92)+(description.length>92?'…':'')+' · '+r.root);opt.value=String(i);picker.append(opt);});
    const initial=plan.selectedIndex??plan.preferred;picker.value=initial>=0?String(initial):plan.needsDefinition?'':'0';
  }
  if(plan.needsDefinition && !missingDefinition && wordLink)card.append(wordLink(plan.input,word,plan.readings[0].quality?'adjective':'verb'));
  card.append(output);
  const active=()=>isCurrent()&&card.isConnected!==false;
  async function refresh(){
    const generation=++version,current=()=>active()&&version===generation;
    player.stop();output.replaceChildren();
    if(!current())return;
    if(picker?.value===''){onStatus('Missing definition · “'+word+'” needs a meaning before the sentence can play.');return;}
    const index=picker?Number(picker.value):0,reading=plan.readings[index];
    try {
      const line=await scoreDictionaryClause(plan,index,authority);if(!current())return;
      const readiness=await sentenceReadiness(line.midi,authority.atoms);if(!current())return;
      onStatus(readiness.summary+(index===preferred?' · using your saved word choice':plan.needsDefinition?' · using your chosen meaning':' · draft musical grammar'));
      const label=reading.root==='erase_stored_object'?'remove the item from storage':everydayMeaning(authority,{...reading.sense,target_id:reading.root});
      output.append(make('p',describeClaim(label,line.meaning.scopes,line.meaning.speech_act)));
      output.append(make('p',readiness.detail));
      output.append(make('p',reading.root+' · '+(authority.atoms.find(a=>a.canonical_id===reading.root)?.core_definition||title(reading))));
      const who=text=>text==='we'?'our group':text==='I'?'the speaker':text==='you'?'the listener':text;
      const roles=reading.participants.map(p=>p.role+' · '+who(p.text)).join(' / ');
      const actLabel=plan.speechAct==='command'?'Command':plan.speechAct==='question'?'Question':'Statement';
      const scope=[actLabel,...reading.scopes.map(s=>scopeLabels[s])].join(' → ');
      output.append(make('p',scope+' · '+roles+'. '+describeRuntime(line.meaning.runtime_state)));
      if(reading.sense.generalization&&!plan.needsDefinition)output.append(make('p',reading.sense.generalization));
      const button=(text,action)=>{const b=make('button',text);b.type='button';b.addEventListener('click',async()=>{if(current())try{await action();}catch(error){if(current())onError(error);}});output.append(b);return b;};
      button('Play whole sentence',()=>player.play(line.midi)).className='primary';
      button('Play compact chords',()=>player.play(compactChordMidi(line.midi,authority.atoms),{chords:true}));
      button('Stop',()=>player.stop());
      button('Add to song',()=>add(plan.input,line.midi,line.label));
      if(picker&&remember){
        const preference=button(index===preferred?'Forget this word choice':'Use this meaning next time',()=>{
          const forget=index===preferred;
          remember(reading,plan.preferenceForms,forget);preferred=forget?-1:index;
          preference.textContent=forget?'Use this meaning next time':'Forget this word choice';
          onStatus(readiness.summary+(forget?' · using your chosen meaning':' · using your saved word choice'));
        });
      }
      button('Download sentence MIDI',()=>download(new Blob([line.midi],{type:'audio/midi'}),'era-zero-sentence.mid'));
    } catch(error){if(current())onError(error);}
  }
  picker?.addEventListener('change',()=>{if(active())selectReading?.(picker.value===''?null:plan.readings[Number(picker.value)]);return refresh();});await refresh();
}
