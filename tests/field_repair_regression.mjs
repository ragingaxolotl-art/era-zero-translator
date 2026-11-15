import fs from 'node:fs';
import assert from 'node:assert/strict';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory} from '../pages/story_music.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {compactChordMidi,compactChordPerformance} from '../pages/compact_chords.mjs';
import {readSongLine} from '../pages/song_readback.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {analyzeEnglish} from '../pages/english.mjs';
import {faultCorrectionPlan} from '../pages/fault_correction.mjs';

const read=name=>JSON.parse(fs.readFileSync(new URL('../pages/data/'+name,import.meta.url)));
const authority=read('index.json'),records=read('foundation_preview_candidates.json').records;
const id=lemma=>storyWords.find(w=>w.word===lemma).id;
async function check(text,answers={}){
  const plan=storyReading(text,authority,{answers});assert(plan&&!plan.question&&!plan.unsupported,text);
  const {midi,meaning}=await scoreStory(plan,authority);
  const raw=await decodeSupportedMeaningWithDrafts(midi,authority.atoms,records,{allowDraft:true});
  assert.deepEqual(raw,meaning);
  assert.deepEqual((await readSongLine(compactChordMidi(midi,authority.atoms),authority.atoms,records,true)).meaning,meaning);
  return {heard:raw,midi};
}
for(const input of ['Follow the route.','The pilot followed a marked trail.','The scouts follow their path.']){
  assert.equal(analyzeEnglish(input,authority).candidates[0].sense_key,'trajectory_tracking',input);
}
for(const input of ['An adjustment followed.','An adjustment followed after the route reopened.']){
  assert.equal(analyzeEnglish(input,authority).candidates[0].sense_key,'occurrence_after_a_reference_event',input);
}
const carry='The compiler carried the jobs.';
assert.equal(storyReading(carry,authority).question.key,'carrying0');
assert.equal((await check(carry,{carrying0:'work'})).heard.events[0].predicate,id('hand off work'));
assert.equal((await check(carry,{carrying0:'physical'})).heard.predicate,'physical_carrying');
const sentence='Nora found the report. It found the log.';
assert.equal(storyReading(sentence,authority).question.options.length,2);
for(const index of [0,1])assert.equal((await check(sentence,{subject1:String(index)})).heard.events[1].arguments[0].entity,index);
const valid=(await check('A few permits remained valid.')).heard;
assert.equal(valid.entities[0].identity.reference_mode,'nominal_class');assert.equal(valid.events[0].quantifier,'few');
const before=await check('The monitor will wait if the gate reopens.');
assert.deepEqual(before.heard.relations,[{kind:'condition',events:[1,0]}]);assert.deepEqual(before.heard.events[0].scopes,['time_after_speech']);
const previews=compactChordPerformance(before.midi,authority.atoms,{preview:true}).previews;
assert(previews.length>1&&previews[1].atSeconds>previews[0].atSeconds);
for(const mode of ["can't","cannot","can not"])assert.deepEqual((await check('We '+mode+' see the lamp.')).heard.events[0].scopes,['negation','ability']);
assert.equal((await check('The chair reopened the session.',{property0Objectreopen:'session'})).heard.events[0].predicate,id('resume'));
assert(storyReading('Nora followed.',authority).question);
const fault='We need to correct the uplink fault.';
assert.equal(faultCorrectionPlan(fault),null);assert(storyReading(fault,authority).question);
assert.equal(storyReading(fault,authority,{answers:{faultCategory:'other'}}).unsupported,true);
assert.equal((await check(fault,{faultCategory:'type'})).heard.fault.type_label.phonemes.length>0,true);
for(const state of [0,1,2]){
  const r=(await check('Then we did not know what else Mira wanted. ['+state+']')).heard;
  assert.equal(r.runtime_state,state);assert.equal(r.knowledge.knower.role,'speaker_group');
  assert.deepEqual(r.knowledge.scopes,['time_before_speech','negation']);assert.equal(r.knowledge.question.additional,true);
  assert.deepEqual(r.knowledge.question.restriction.scopes,['time_before_speech']);
}
const plain=(await check('I know what you want.')).heard;
assert.equal(plain.knowledge.question.additional,false);assert.equal(plain.discourse,null);assert.deepEqual(plain.knowledge.scopes,[]);
console.log('PASS reusable field repairs, contrasting participant and word choices, scoped knowledge, ability, conditional reversal, and saved chords.');
