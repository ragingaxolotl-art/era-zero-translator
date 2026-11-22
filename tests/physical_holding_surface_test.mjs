import assert from 'node:assert/strict';
import fs from 'node:fs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {analyzeEnglish} from '../pages/english.mjs';
import {recognizedClausePredicate,dictionaryClausePlan} from '../pages/dictionary_clauses.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {encodeName} from '../pages/names.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const holding='CMP:834a56d90e31b430990720ff',release='CMP:69f57af236cf82c134e3c51a';
const word=label=>storyWords.find(w=>w.word===label).id;
let checks=0;
async function hear(text,{scopes=[],state=1,act='assertion',answers={}}={}){
  const plan=storyReading(text+' ['+state+']',authority,{answers});assert(plan?.events,text+' '+JSON.stringify(plan?.question));
  const {midi}=await scoreStory(plan,authority),decoded=decodeStoryMidi(midi,authority.atoms);
  assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms),authority.atoms),decoded);
  const event=decoded.events[0];assert.equal(event.predicate,holding,text);assert.deepEqual(event.scopes,scopes,text);
  assert.deepEqual(event.arguments.map(a=>a.role),['actor','target']);assert.deepEqual(event.arguments.map(a=>a.entity),[0,1]);
  assert.equal(decoded.runtime_state,state);assert.equal(decoded.speech_act,act);checks++;
  return {decoded,midi};
}
for(const state of [0,1,2])for(const [text,scopes,act] of [
  ['Nora holds the rope.',[]],['Mira held the board.',['time_before_speech']],
  ['We are holding the box.',['aspect_ongoing']],['Nora was not holding the box.',['time_before_speech','negation','aspect_ongoing']],
  ['Nora will not hold the box.',['time_after_speech','negation']],['Nora cannot hold the box.',['negation','ability']],
  ['Nora might not hold the box.',['modality_possible','negation']],['Nora needs to hold the box.',['modality_necessary']],
  ['Can Nora hold the box?',['ability'],'question'],['Did Nora hold the box?',['time_before_speech'],'question'],
  ['Please hold the box.',[],'command'],['Do not hold the box.',['negation'],'command']
])await hear(text,{state,scopes,act:act||'assertion'});
for(const [text,scopes,act] of [['Hold ropes.',[],'command'],['Hold Mira.',[],'command'],
  ['Nora held the rope and Mira held the box.',['time_before_speech']],
  ['Nora held the rope. Mira released it.',['time_before_speech']],
  ['If Nora holds the rope, Mira will release it.',[]]]){
  const {decoded}=await hear(text,{scopes,act:act||'assertion',answers:{physical0:'physical'}});
  if(text.includes('released it')||text.startsWith('If')){
    assert.equal(decoded.events[1].predicate,release);assert.deepEqual(decoded.events[1].arguments.map(a=>a.entity),[2,1]);
  }
  if(text.startsWith('If')){
    assert.deepEqual(decoded.relations,[{kind:'condition',events:[0,1]}]);assert.deepEqual(decoded.events[1].scopes,['time_after_speech']);
  }
}
const described=await hear('The awake robot holds the full box.');
assert.equal(described.decoded.events[0].arguments[0].properties[0],'LIF:001');
assert.equal(described.decoded.events[0].arguments[1].properties[0],word('full'));
for(const text of ['Nora holds an opinion.','Nora holds the file.','Nora holds Mira.','Nora holds the box or the meeting.']){
  const ask=storyReading(text,authority);assert(ask?.question,text);assert.match(ask.question.key,/^physical/);
  assert.equal(storyReading(text,authority,{answers:{[ask.question.key]:'other'}}),null,text);
}
for(const [text,holder,target] of [['Nora holds Mira.','nora','mira'],['Mira holds Nora.','mira','nora']]){
  const {decoded}=await hear(text,{answers:{physical0:'physical'}});
  assert.deepEqual(decoded.entities[0].identity.phonemes,(await encodeName(holder)).phonemes);
  assert.deepEqual(decoded.entities[1].identity.phonemes,(await encodeName(target)).phonemes);
}
for(const text of ['The rope is held.','Nora has held the rope.','Nora holds the rope with a tool.','Nora holded the rope.',
  'Nora holds only the rope.','Nora holds the rope for Mira.'])assert.equal(storyReading(text,authority),null,text);
assert.equal(recognizedClausePredicate('Nora held the rope.',authority),'held');
assert.equal(recognizedClausePredicate('Nora holded the rope.',authority),null);
assert.equal(dictionaryClausePlan('The rope is held.',authority,{offerDefinition:true}),null);
for(const surface of ['hold','holds','held','holding']){
  const coverage=analyzeEnglish('Nora '+surface+' the rope.',authority).term_coverage;
  assert(coverage.some(item=>item.term===surface&&item.matches.some(m=>m.target_id===holding)),surface);
}
// The shared foundation must remain structurally present in both dependents.
const releasePlan=authority.compound_plans[release];
assert(releasePlan.expanded.nodes.some(n=>n.root_id==='MAT:211'));
const damaged=structuredClone(authority);damaged.compound_plans[holding].expanded.nodes.find(n=>n.root_id==='MAT:211').root_id='MAT:210';
await assert.rejects(()=>scoreStory(storyReading('Nora holds the rope.',damaged),damaged));
console.log('PASS '+checks+' holding sentence round trips, shared release foundation, sense choices, role reversal, irregular forms and unsupported-detail rejection.');
