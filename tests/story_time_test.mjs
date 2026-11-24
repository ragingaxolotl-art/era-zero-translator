import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {encodeName} from '../pages/names.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const hash=b=>createHash('sha256').update(b).digest('hex');
const legacy=JSON.parse(fs.readFileSync(new URL('./story_time_legacy_2026_11_23.json',import.meta.url)));
for(const row of legacy.cases){
 const result=await scoreStory(storyReading(row.input,authority,{answers:row.answers}),authority);
 assert.equal(hash(result.midi),row.melody_sha256,row.input);
 assert.equal(hash(compactChordMidi(result.midi,authority.atoms)),row.chords_sha256,row.input);
 assert.deepEqual(decodeStoryMidi(result.midi,authority.atoms),row.meaning,row.input);
}
assert.equal(legacy.cases.length,24);
const save='CMP:58cfa479709294b9809be1b7',copy='CMP:9ea919967152aa85bc1c7169';
let pairs=0;
async function hear(text,{predicate=save,roles=['actor','target'],entities=[0,1],scopes=[],answers={},state=1,act='assertion'}={}){
 const plan=storyReading(text+' ['+state+']',authority,{answers});assert(plan?.events,text+' '+JSON.stringify(plan));
 const result=await scoreStory(plan,authority),meaning=decodeStoryMidi(result.midi,authority.atoms),event=meaning.events[0];
 assert.equal(event.predicate,predicate,text);assert.deepEqual(event.arguments.map(a=>a.role),roles,text);
 assert.deepEqual(event.arguments.map(a=>a.entity),entities,text);assert.deepEqual(event.scopes,scopes,text);
 assert.equal(meaning.runtime_state,state);assert.equal(meaning.speech_act,act);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(result.midi,authority.atoms),authority.atoms),authority.atoms),meaning,text);
 pairs++;return {meaning,midi:result.midi};
}
// Expected event meaning is specified independently of the time extractor.
// Compare front/end placement, different verbs, voices, objects and all endings.
const cases=[
 ['Nora saved the file','yesterday',{scopes:['time_previous_day','time_before_speech']}],
 ['Nora did not copy the record','yesterday',{predicate:copy,scopes:['time_previous_day','time_before_speech','negation']}],
 ['Nora will save the file','tomorrow',{scopes:['time_next_day','time_after_speech']}],
 ['The routine will not copy the records','tomorrow',{predicate:copy,scopes:['time_next_day','time_after_speech','negation']}],
 ['Nora is saving the file','today',{scopes:['time_current_day','aspect_ongoing']}],
 ['The file was saved by Nora','yesterday',{entities:[1,0],scopes:['time_previous_day','time_before_speech']}],
 ['The record will be copied by the routine','tomorrow',{predicate:copy,entities:[1,0],scopes:['time_next_day','time_after_speech']}],
 ['Nora lifted the box','yesterday',{predicate:'CMP:e1d0059daad4093d8a5ce05c',scopes:['time_previous_day','time_before_speech']}],
 ['Nora put the box at the gate','yesterday',{predicate:'CMP:64574c1a25d72a89aafc46ef',roles:['actor','target','destination'],entities:[0,1,2],scopes:['time_previous_day','time_before_speech']}],
 ['Nora kept the file stored','yesterday',{predicate:'CMP:cac584a394535e4912c75b5a',roles:['cause','bearer'],scopes:['time_previous_day','time_before_speech']}],
 ['Nora checked the gate again','today',{predicate:'CMP:ffeb55f462f10014970989a4',scopes:['time_current_day','time_before_speech']}],
 ['Please save the file','tomorrow',{act:'command',scopes:['time_next_day']}],
 ['Do not copy the file','today',{predicate:copy,act:'command',scopes:['time_current_day','negation']}],
 ['Save the file','now',{act:'command',scopes:['time_at_speech']}]
];
for(const state of [0,1,2])for(const [body,day,expected] of cases){
 const tail=await hear(body+' '+day+'.',{...expected,state});
 const front=await hear(day[0].toUpperCase()+day.slice(1)+', '+body+'.',{...expected,state});
 assert.equal(hash(front.midi),hash(tail.midi),body);
}
for(const state of [0,1,2]){
 await hear('Yesterday, did Nora not save the file?',{state,act:'question',scopes:['time_previous_day','time_before_speech','negation']});
 await hear('Will the file be saved by Nora tomorrow?',{state,act:'question',entities:[1,0],scopes:['time_next_day','time_after_speech']});
 for(const [verb,claim,event] of [
  ['can',['time_next_day','ability'],['ability','time_next_day']],
  ['cannot',['time_next_day','negation','ability'],['negation','ability','time_next_day']],
  ['might not',['time_next_day','modality_possible','negation'],['modality_possible','time_next_day','negation']],
  ['needs to',['time_next_day','modality_necessary'],['modality_necessary','time_next_day']]
 ]){
  const text='Nora '+verb+' save the file tomorrow.';
  assert.equal(storyReading(text,authority).question.key,'timeScope0');
  assert(storyReading(text,authority,{answers:{timeScope0:'other'}}).unsupported);
  const outer=await hear(text,{state,scopes:claim,answers:{timeScope0:'claim'}});
  const inner=await hear(text,{state,scopes:event,answers:{timeScope0:'event'}});
  assert.notEqual(hash(outer.midi),hash(inner.midi));
 }
}
const paragraph=await hear('Yesterday, Nora saved the file. They copied it today.',{scopes:['time_previous_day','time_before_speech']});
assert.equal(paragraph.meaning.events[1].predicate,copy);assert.deepEqual(paragraph.meaning.events[1].arguments.map(a=>a.entity),[0,1]);
assert.deepEqual(paragraph.meaning.events[1].scopes,['time_current_day','time_before_speech']);
const unchangedTime=await hear('Nora saved the file yesterday. The file was stored today.',{scopes:['time_previous_day','time_before_speech']});
assert.equal(unchangedTime.meaning.events[1].predicate,'DAT:000');assert.deepEqual(unchangedTime.meaning.events[1].scopes,['time_current_day','time_before_speech']);
for(const name of ['Today','Tomorrow','"today"']){
 const named=await hear('Yesterday, Nora copied '+name+'.',{predicate:copy,scopes:['time_previous_day','time_before_speech'],answers:{information0:'stored'}});
 assert.deepEqual(named.meaning.entities[1].identity.phonemes,(await encodeName(name.replaceAll('"',''))).phonemes);
}
const missing=storyReading('Nora noticed yesterday.',authority);assert.equal(missing.question.key,'object0');
const selected=await hear('Nora noticed yesterday.',{predicate:'CMP:ac9df67396f3632d36b5d078',roles:['experiencer','target'],scopes:['time_previous_day','time_before_speech'],answers:{object0:'new:the signal'}});
assert.equal(selected.meaning.entities.length,2);
const plural=await hear('The records were copied by the program yesterday.',{predicate:copy,entities:[1,0],scopes:['time_previous_day','time_before_speech']});
assert(plural.meaning.entities[0].plural);
const runtime=await Promise.all([0,1,2].map(state=>hear('Nora saved the file yesterday.',{state,scopes:['time_previous_day','time_before_speech']})));
assert.equal(new Set(runtime.map(r=>hash(r.midi))).size,3);
for(const text of [
 'Nora saved the file yesterday morning.','Nora only saved the file yesterday.','Nora saved the file yesterday tomorrow.',
 'Yesterday, Nora saved the file today.','Nora saved the file yesterday now.','Nora saved yesterday.',
 'Nora saved the file and copied it yesterday.','If Nora saved the file, Mira copied it yesterday.',
 'All the programs saved the file yesterday.','Nora might need to save the file tomorrow.',
 'Nora saved the file with a tool yesterday.','The file has been saved by Nora yesterday.',
 'The full box was emptied by Nora yesterday.','Nora glorped the file yesterday.'
]){
 assert(!storyReading(text,authority)?.events,text);
 assert.equal(await scoreSongText(text,authority,()=>{throw Error('No invented fallback');}),null,text);
}
const whole=await scoreSongText('Nora saved the file yesterday.',authority,()=>{throw Error('No isolated-root fallback');});
assert.equal(decodeStoryMidi(whole.midi,authority.atoms).events[0].predicate,save);
console.log(`PASS ${pairs} independent melody/chord time pairs, front/end equivalence, modal-scope choices, question/command/negation, references and runtime 0/1/2; 24 frozen performances and unsupported constructions protected.`);
