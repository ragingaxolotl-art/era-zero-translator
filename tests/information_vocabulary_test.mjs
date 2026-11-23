import assert from 'node:assert/strict';
import fs from 'node:fs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {encodeName} from '../pages/names.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const word=label=>storyWords.find(w=>w.word===label).id;
let checks=0;
async function hear(text,verb,{scopes=[],state=1,act='assertion',answers={},event=0}={}){
  const plan=storyReading(text+' ['+state+']',authority,{answers});
  assert(plan?.events,text+' '+JSON.stringify(plan?.question));
  const {midi}=await scoreStory(plan,authority);
  const heard=await decodeSupportedMeaningWithDrafts(midi,authority.atoms,[],{allowDraft:true});
  assert.deepEqual(await decodeSupportedMeaningWithDrafts(expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms),authority.atoms,[],{allowDraft:true}),heard);
  assert.equal(heard.events[event].predicate,word(verb));assert.deepEqual(heard.events[event].scopes,scopes,text);
  assert.deepEqual(heard.events[event].arguments.map(a=>a.role),[verb==='copy'?'actor':'experiencer','target']);
  assert.equal(heard.runtime_state,state);assert.equal(heard.speech_act,act);
  checks++;return {heard,midi,plan};
}
for(const state of [0,1,2])for(const [base,third,past,ongoing,target] of [
  ['copy','copies','copied','copying','the file'],['recall','recalls','recalled','recalling','Mira']
])for(const subject of ['Nora','We']){
  const singular=subject==='Nora',answers=base==='recall'?{retrieval0:'retrieval'}:{};
  for(const [text,scopes,act] of [
    [`${subject} ${singular?third:base} ${target}.`,[]],
    [`${subject} ${past} ${target}.`,['time_before_speech']],
    [`${subject} ${singular?'does':'do'} not ${base} ${target}.`,['negation']],
    [`${subject} did not ${base} ${target}.`,['time_before_speech','negation']],
    [`${subject} ${singular?'is':'are'} ${ongoing} ${target}.`,['aspect_ongoing']],
    [`${subject} ${singular?'was':'were'} not ${ongoing} ${target}.`,['time_before_speech','negation','aspect_ongoing']],
    [`${subject} will ${base} ${target}.`,['time_after_speech']],
    [`${subject} will not ${base} ${target}.`,['time_after_speech','negation']],
    [`${subject} might not ${base} ${target}.`,['modality_possible','negation']],
    [`${subject} cannot ${base} ${target}.`,['negation','ability']],
    [`${subject} ${singular?'needs':'need'} to ${base} ${target}.`,['modality_necessary']],
    [`Did ${subject} ${base} ${target}?`,['time_before_speech'],'question'],
    [`Can ${subject} ${base} ${target}?`,['ability'],'question']]){
    const {heard}=await hear(text,base,{state,scopes,act:act||'assertion',answers});
    assert.deepEqual(heard.events[0].arguments.map(a=>a.entity),[0,1]);
    assert.deepEqual(heard.entities[1].identity.phonemes,(await encodeName(base==='copy'?'file':'Mira')).phonemes);
    if(singular)assert.deepEqual(heard.entities[0].identity.phonemes,(await encodeName('Nora')).phonemes);
    else assert.deepEqual(heard.entities[0].identity,{kind:'deictic',role:'speaker_group'});
  }
}
for(const state of [0,1,2]){
  const {heard}=await hear('Mira remembered Nora.','recall',{state,scopes:['time_before_speech'],answers:{retrieval0:'retrieval'}});
  assert.deepEqual(heard.entities[0].identity.phonemes,(await encodeName('Mira')).phonemes);
  assert.deepEqual(heard.entities[1].identity.phonemes,(await encodeName('Nora')).phonemes);
}
for(const [text,verb,scopes] of [['Copy the file.','copy',[]],['Please do not copy this record.','copy',['negation']],
  ['Recall Mira.','recall',[]],["Please don't remember Mira.",'recall',['negation']]]){
  const {heard}=await hear(text,verb,{scopes,act:'command',answers:{retrieval0:'retrieval'}});
  assert.deepEqual(heard.entities[0].identity,{kind:'deictic',role:'addressee'});
}
const link=await hear('Nora found the document. Mira copied it.','copy',{event:1,scopes:['time_before_speech']});
assert.deepEqual(link.heard.events[1].arguments.map(a=>a.entity),[2,1]);
const condition=await hear('If Nora finds the file, Mira will not copy it.','copy',{event:1,scopes:['time_after_speech','negation']});
assert.deepEqual(condition.heard.relations,[{kind:'condition',events:[0,1]}]);
const plural=await hear('The routine copied the records.','copy',{scopes:['time_before_speech']});
assert.equal(plural.heard.entities[1].plural,true);
const bare=await hear('Copy files.','copy',{act:'command'});assert.equal(bare.heard.entities[1].plural,true);
const alternative=await hear('Nora copied the file or the log.','copy',{scopes:['time_before_speech']});
assert.equal(alternative.heard.events[0].arguments[1].coordination,'any_of');
assert.equal(alternative.heard.events[0].arguments[1].alternatives.length,1);
for(const text of ['Nora copied Mira.','Nora copied the file or the child.','Nora remembers Mira.','Nora recalled the message.']){
  const plan=storyReading(text,authority);assert(plan?.question,text);
  assert.equal(storyReading(text,authority,{answers:{[plan.question.key]:'other'}}),null,text);
}
for(const text of ['Nora copied the file to the folder.','Nora copied only the file.','Nora saved only the file.',
  'Nora remembered to copy the file.','Nora recalled that Mira left.','The file was copied.']){
  assert(!storyReading(text,authority,{answers:{retrieval0:'retrieval'}})?.events,text);
}
// The imperative repair applies to existing verbs too, without stealing a
// capitalized name that happens to have the same spelling as a new verb.
for(const [text,predicate,act,answers] of [
  ['Push Mira.',word('push'),'command',{physical0:'physical'}],
  ['Keep the gate open.',word('keep'),'command',{}],
  ['Delete Mira.','erase_stored_object','command',{information0:'stored'}],
  ['Find Nora.',word('find'),'command',{}],
  ['Copy dropped the box.',word('drop'),'assertion',{}]
]){
  const p=storyReading(text,authority,{answers});assert(p?.events,text);
  const {midi}=await scoreStory(p,authority),heard=decodeStoryMidi(midi,authority.atoms);
  assert.equal(heard.speech_act,act);assert.equal(heard.events[0].predicate,predicate);
  if(act==='command')assert.deepEqual(heard.entities[0].identity,{kind:'deictic',role:'addressee'});
  else assert.deepEqual(heard.entities[0].identity.phonemes,(await encodeName('Copy')).phonemes);
  checks++;
}
// Changing a defining component must not be accepted merely because its
// outer convention code is intact. The listener checks the full sound graph.
for(const [text,verb,root,answers] of [['Nora copied the file.','copy','DAT:000',{}],
  ['Nora recalled Mira.','recall','MIN:012',{retrieval0:'retrieval'}]]){
  const {midi}=await hear(text,verb,{scopes:['time_before_speech'],answers});
  const observed=decodeStrictMusicMidi(midi,authority.atoms,{allowDraftInformationPassage:true});
  const component=observed.tokens.find(t=>t.kind==='root'&&t.root_id===root);assert(component);
  const timeline=notesFromMidi(midi),attack=timeline.notes.findIndex(n=>n.start_tick===component.start_tick);
  timeline.notes[attack+2].midi+=1;
  assert.throws(()=>decodeStoryMidi(midiFromNoteTimeline(timeline.notes,timeline.division,timeline.tempos[0].value),authority.atoms));
}
console.log('PASS '+checks+' reusable copy/recall sentence cases in melody/chords; roles, scope, runtime, reference, ambiguity and corrupted-definition rejection.');
