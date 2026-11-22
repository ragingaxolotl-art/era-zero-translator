import {storyReading} from './story_readings.mjs?v=partial-word-flow-2';
import {scoreStory} from './story_music.mjs?v=partial-word-flow-2';
import {everydayMeaning} from './everyday.mjs?v=partial-word-flow-1';
import {compactChordMidi} from './compact_chords.mjs?v=partial-word-flow-1';
import {sentenceReadiness} from './sentence_readiness.mjs?v=contextual-groups-1';

export async function showStoryControls(input,authority,{list,summary,current,preferences,adjectives,player,add,download,onError},initial){
  const element=(tag,text)=>{const node=document.createElement(tag);if(text)node.textContent=text;return node;};
  const card=element('article');card.className='candidate';list.replaceChildren(card);
  const answers={};
  let version=0;
  async function render(plan){
    const generation=++version,active=()=>current()&&card.isConnected&&version===generation;
    if(!active())return;
    player.stop();card.replaceChildren(element('h3',input));
    function button(label,action){
      const b=element('button',label);b.type='button';b.addEventListener('click',async()=>{if(active())try{await action();}catch(e){if(active())onError(e);}});card.append(b);return b;
    }
    const q=plan?.question;
    if(q){
      summary.textContent='One detail needed to play the whole line';
      card.append(element('p',q.prompt));
      const choose=value=>{
        answers[q.key]=value;
        return render(storyReading(input,authority,{answers,preferences,adjectives}));
      };
      for(const o of q.options)button(o.sense?everydayMeaning(authority,o.sense):o.label,()=>choose(o.value));
      if(q.allowName){
        const label=element('label','Name or noun phrase'),field=element('input');
        field.placeholder='For example, Ada or the radio';label.append(field);card.append(label);
        button('Use this referent',()=>{if(field.value.trim())return choose('new:'+field.value.trim());});
      }
      return;
    }
    if(!plan||plan.unsupported){
      summary.textContent='This meaning has no whole-line score yet.';
      button('Change the reading',()=>{for(const key of Object.keys(answers))delete answers[key];return render(initial);});
      return;
    }
    const scored=await scoreStory(plan,authority);if(!active())return;
    const readiness=await sentenceReadiness(scored.midi,authority.atoms,{adjectives});if(!active())return;
    summary.textContent=readiness.summary;
    card.append(element('p',scored.description));
    card.append(element('p',readiness.detail));
    button('Play whole passage',()=>player.play(scored.midi)).className='primary';
    button('Play compact chords',()=>player.play(compactChordMidi(scored.midi,authority.atoms),{chords:true}));
    button('Stop',()=>player.stop());
    button('Add to song',()=>add(input,scored.midi,scored.label));
    button('Download passage MIDI',()=>download(new Blob([scored.midi],{type:'audio/midi'}),'era-zero-story.mid'));
    if(Object.keys(answers).length)button('Change the reading',()=>{for(const key of Object.keys(answers))delete answers[key];return render(initial);});
  }
  return render(initial);
}
