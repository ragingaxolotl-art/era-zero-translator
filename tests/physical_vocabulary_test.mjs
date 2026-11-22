import assert from 'node:assert/strict';
import fs from 'node:fs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {feltProperties} from '../pages/story_qualities.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {encodeName} from '../pages/names.mjs';
import {analyzeEnglish} from '../pages/english.mjs';

const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const word=name=>storyWords.find(w=>w.word===name).id;
let checks=0;
async function hear(text,{predicate,scopes=[],roles,labels,act='assertion',state=1,answers={},condition}={}){
  const plan=storyReading(text+' ['+state+']',authority,{answers});
  assert(plan?.events,text+' '+JSON.stringify(plan?.question));
  const {midi}=await scoreStory(plan,authority);
  // Decoder receives only the exported notes and the public dictionary of sounds.
  const decoded=decodeStoryMidi(midi,authority.atoms);
  const compact=compactChordMidi(midi,authority.atoms);
  assert.deepEqual(decodeStoryMidi(expandChordMidi(compact,authority.atoms),authority.atoms),decoded,text);
  assert.equal(decoded.runtime_state,state,text);assert.equal(decoded.speech_act,act,text);
  const event=decoded.events[0];
  if(predicate)assert.equal(event.predicate,word(predicate),text);
  assert.deepEqual(event.scopes,scopes,text);
  if(roles)assert.deepEqual(event.arguments.map(a=>a.role),roles,text);
  if(labels){
    assert.deepEqual(event.arguments.map(a=>a.entity),labels.map((_,i)=>i),text);
    assert.deepEqual(decoded.entities.map(e=>e.identity.phonemes),await Promise.all(labels.map(async label=>(await encodeName(label)).phonemes)),text);
  }
  if(condition)assert.equal(event.condition,word(condition),text);
  checks++;return {decoded,event,midi,compact};
}
const verbs=[['pull','pulls','pulled','pulling','Nora','rope'],['release','releases','released','releasing','Mira','board'],
  ['drop','drops','dropped','dropping','Eli','bottle']];
for(const state of [0,1,2]){
  for(const [base,third,past,ing,name,target] of verbs){
    const expected={predicate:base,roles:['actor','target'],labels:[name,target],state};
    for(const [phrase,scopes,act] of [
      [`${name} ${third} the ${target}.`,[]],
      [`${name} ${past} the ${target}.`,['time_before_speech']],
      [`${name} is ${ing} the ${target}.`,['aspect_ongoing']],
      [`${name} was not ${ing} the ${target}.`,['time_before_speech','negation','aspect_ongoing']],
      [`${name} will not ${base} the ${target}.`,['time_after_speech','negation']],
      [`${name} cannot ${base} the ${target}.`,['negation','ability']],
      [`${name} might not ${base} the ${target}.`,['modality_possible','negation']],
      [`${name} needs to ${base} the ${target}.`,['modality_necessary']],
      [`Did ${name} ${base} the ${target}?`,['time_before_speech'],'question']]){
      await hear(phrase,{...expected,scopes,act:act||'assertion'});
    }
  }
  for(const [text,scopes,act] of [['The crate fell.',['time_before_speech']],['The stone is falling.',['aspect_ongoing']],
    ['The board will fall.',['time_after_speech']],['The rock might not fall.',['modality_possible','negation']],
    ['Can the bottle fall?',['ability'],'question']]){
    await hear(text,{predicate:'fall',roles:['bearer'],scopes,act:act||'assertion',state});
  }
  for(const quality of ['empty','full']){
    for(const [text,scopes,act] of [[`The bottle is ${quality}.`,[]],[`The box was not ${quality}.`,['time_before_speech','negation']],
      [`The cup might be ${quality}.`,['modality_possible']],[`Is the bucket ${quality}?`,[],'question']]){
      await hear(text,{predicate:quality,roles:['bearer'],scopes,act:act||'assertion',state});
    }
  }
}
for(const [text,predicate,scopes] of [['Pull the rope.','pull',[]],['Please release the rope.','release',[]],
  ['Do not drop the box.','drop',['negation']], ["Please don't pull the cord.",'pull',['negation']]]){
  const {decoded}=await hear(text,{predicate,roles:['actor','target'],act:'command',scopes});
  assert.deepEqual(decoded.entities[0].identity,{kind:'deictic',role:'addressee'});
}
// Role reversal is a distinct message even when both names are unknown to the lexicon.
const forward=await hear('Tavi pulled Ren.',{predicate:'pull',roles:['actor','target'],labels:['Tavi','Ren'],scopes:['time_before_speech'],answers:{physical0:'physical'}});
const reverse=await hear('Ren pulled Tavi.',{predicate:'pull',roles:['actor','target'],labels:['Ren','Tavi'],scopes:['time_before_speech'],answers:{physical0:'physical'}});
assert.notDeepEqual(notesFromMidi(forward.midi).notes,notesFromMidi(reverse.midi).notes);
for(const quality of ['empty','full']){
  const subject=await hear(`The ${quality} crate fell.`,{predicate:'fall',roles:['bearer'],scopes:['time_before_speech']});
  assert.deepEqual(subject.event.arguments[0].properties,[word(quality)]);
  const object=await hear(`Nora pulled the ${quality} cart.`,{predicate:'pull',roles:['actor','target'],scopes:['time_before_speech'],answers:{['property0Object'+quality]:'physical'}});
  assert.deepEqual(object.event.arguments[1].properties,[word(quality)]);
  await hear(`Mira kept the bottle ${quality}.`,{predicate:'keep',condition:quality,roles:['cause','bearer'],scopes:['time_before_speech']});
  await hear(`The jar stayed ${quality}.`,{predicate:'stay',condition:quality,roles:['bearer'],scopes:['time_before_speech']});
}
const sequence=await hear('Nora pulled the crate and dropped it.',{predicate:'pull',roles:['actor','target'],scopes:['time_before_speech']});
assert.equal(sequence.decoded.events[1].predicate,word('drop'));
assert.deepEqual(sequence.decoded.events[1].arguments.map(a=>a.entity),[0,1]);
// Two formerly failing inputs from the frozen November 22 audit.
const frozen=await hear('The tired worker lowered the empty box.',{predicate:'lower',roles:['actor','target'],scopes:['time_before_speech'],labels:['worker','box']});
assert.deepEqual(frozen.event.arguments.map(a=>a.properties),[[feltProperties.tired],[word('empty')]]);
await hear('Nora pulled the box.',{predicate:'pull',roles:['actor','target'],scopes:['time_before_speech'],labels:['Nora','box']});
const conditional=await hear('If the box is full, Mira will not drop it.',{predicate:'full',roles:['bearer']});
assert.equal(conditional.decoded.events[1].predicate,word('drop'));
assert.deepEqual(conditional.decoded.events[1].scopes,['time_after_speech','negation']);
assert.equal(conditional.decoded.events[1].arguments[1].entity,0);
assert.deepEqual(conditional.decoded.relations,[{kind:'condition',events:[0,1]}]);
// Abstract senses, adjectives in all positions, and each coordinated target need review.
for(const text of ['Nora pulled the update.','Nora released the update.','Nora dropped the subject.','The price fell.',
  'The promise is empty.','I am full.','The empty promise waited.','Mira noticed the full report.',
  'Mira kept the report full.','Mira dropped the box or the subject.']){
  const plan=storyReading(text,authority);
  assert(plan?.question,text+' must ask a meaning question');
  assert.equal(storyReading(text,authority,{answers:{[plan.question.key]:'other'}}),null,text);
}
for(const [text,forbidden] of [['Nora pulled the update.','pull'],['Nora dropped the subject.','drop'],
  ['The price fell.','fall'],['The promise is empty.','empty'],['I am full.','full']]){
  assert(!analyzeEnglish(text,authority).term_coverage.some(term=>term.matches?.some(match=>match.target_id===word(forbidden))),text);
}
// No verb use of the adjectives, no unsupported phrasal or perfect/passive meaning loss.
for(const text of ['Nora emptied the box.','Nora filled the bottle.','Nora pulled off the plan.',
  'The box was dropped.','Nora has fallen.','The bottle is full of water.']){
  assert(!storyReading(text,authority)?.events,text);
}
const drop=await hear('Nora dropped the box.',{predicate:'drop',roles:['actor','target'],scopes:['time_before_speech']});
const observed=decodeStrictMusicMidi(drop.midi,authority.atoms,{allowDraftInformationPassage:true});
const codes=observed.tokens.filter(t=>t.marker?.startsWith('convention_')&&t.marker.endsWith('_open')).map(t=>t.sound_code);
for(const code of [79,77,76,38,78])assert(codes.includes(code),'Missing nested meaning '+code);
// A valid outer lexical code cannot excuse damaged notes inside a dependency.
const root=observed.tokens.find(t=>t.kind==='root'),timeline=notesFromMidi(drop.midi);
const attack=timeline.notes.findIndex(n=>n.start_tick===root.start_tick);
timeline.notes[attack+2].midi+=1;
assert.throws(()=>decodeStoryMidi(midiFromNoteTimeline(timeline.notes,timeline.division,timeline.tempos[0].value),authority.atoms));
const notFull=await hear('The bottle is not full.',{predicate:'full',scopes:['negation'],roles:['bearer']});
const empty=await hear('The bottle is empty.',{predicate:'empty',roles:['bearer']});
assert.notDeepEqual(notFull.decoded.events,empty.decoded.events);
assert.notDeepEqual(notesFromMidi(notFull.compact,{allowPolyphony:true}).notes,notesFromMidi(empty.compact,{allowPolyphony:true}).notes);
console.log('PASS '+checks+' physical vocabulary sentences in melody and chords; scoped roles, nested release/fall, 0/1/2, adjectives, ambiguity and damaged-score rejection.');
