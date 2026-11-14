import {everydayMeaning} from './everyday.mjs';
import {scoreDictionaryClause} from './dictionary_clause_music.mjs';
import {compactChordMidi} from './compact_chords.mjs';

const scopeLabels={modality_necessary:'required',modality_possible:'possible',negation:'negated',aspect_ongoing:'ongoing',time_before_speech:'past',time_current_day:'today',time_next_day:'tomorrow',time_previous_day:'yesterday'};

export async function mountDictionaryClause(container,plan,authority,{document=globalThis.document,player,add,download,wordLink,remember,selectReading,isCurrent,onError,onStatus=()=>{}}) {
  const make=(tag,text)=>{const el=document.createElement(tag);if(text!==undefined)el.textContent=text;return el;};
  const card=make('article');card.className='candidate dictionary-clause';
  const word=plan.readings[0].word, output=make('div');
  card.append(make('h3',plan.input));container.append(card);
  const title=reading=>authority.atoms.find(a=>a.canonical_id===reading.root)?.title || (reading.root==='erase_stored_object'?'Remove the stored item':reading.root);
  let picker,version=0,preferred=plan.preferred;
  if(plan.readings.length>1||plan.needsDefinition){
    const label=make('label',(plan.needsDefinition&&plan.preferred<0?'What does “':'Meaning of “')+word+(plan.needsDefinition&&plan.preferred<0?'” mean here?':'” in this sentence'));
    picker=make('select');label.append(picker);card.append(label);
    if(plan.needsDefinition){const opt=make('option','Choose the meaning you intend');opt.value='';picker.append(opt);}
    plan.readings.forEach((r,i)=>{const wording=r.terms?[...r.terms].sort().slice(0,3).join(' / ')+' — ':'';const opt=make('option',wording+(everydayMeaning(authority,{...r.sense,target_id:r.root})||title(r))+' · '+title(r)+' · '+r.root);opt.value=String(i);picker.append(opt);});
    const initial=plan.selectedIndex??plan.preferred;picker.value=initial>=0?String(initial):plan.needsDefinition?'':'0';
  }
  if(plan.needsDefinition && wordLink)card.append(wordLink(plan.input,word,plan.readings[0].quality?'adjective':'verb'));
  card.append(output);
  const active=()=>isCurrent()&&card.isConnected!==false;
  async function refresh(){
    const generation=++version,current=()=>active()&&version===generation;
    player.stop();output.replaceChildren();
    if(!current())return;
    if(picker?.value===''){onStatus('Choose a meaning for “'+word+'” to finish this sentence.');return;}
    const index=picker?Number(picker.value):0,reading=plan.readings[index];
    try {
      const line=await scoreDictionaryClause(plan,index,authority);if(!current())return;
      onStatus(index===preferred?'Whole sentence ready · using your saved word choice':plan.needsDefinition?'Whole sentence ready · using your chosen meaning':'Whole sentence ready · draft musical grammar');
      output.append(make('p',everydayMeaning(authority,{...reading.sense,target_id:reading.root})));
      output.append(make('p',reading.root+' · '+(authority.atoms.find(a=>a.canonical_id===reading.root)?.core_definition||title(reading))));
      const who=text=>text==='we'?'our group':text==='I'?'the speaker':text==='you'?'the listener':text;
      const roles=reading.participants.map(p=>p.role+' · '+who(p.text)).join(' / ');
      const scope=[plan.speechAct==='question'?'Question':'Statement',...reading.scopes.map(s=>scopeLabels[s])].join(' → ');
      output.append(make('p',scope+' · ['+plan.runtime+']. '+roles+'.'));
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
          onStatus(forget?'Whole sentence ready · using your chosen meaning':'Whole sentence ready · using your saved word choice');
        });
      }
      button('Download sentence MIDI',()=>download(new Blob([line.midi],{type:'audio/midi'}),'era-zero-sentence.mid'));
    } catch(error){if(current())onError(error);}
  }
  picker?.addEventListener('change',()=>{if(active())selectReading?.(picker.value===''?null:plan.readings[Number(picker.value)]);return refresh();});await refresh();
}
