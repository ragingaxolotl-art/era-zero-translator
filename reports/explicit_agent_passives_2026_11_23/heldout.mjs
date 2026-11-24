// Run from the repository: node reports/explicit_agent_passives_2026_11_23/heldout.mjs
import fs from 'node:fs';import assert from 'node:assert/strict';import {execFileSync} from 'node:child_process';
import {storyReading} from '../../pages/story_readings.mjs';import {scoreStory,decodeStoryMidi} from '../../pages/story_music.mjs';
import {compactChordMidi,expandChordMidi} from '../../pages/compact_chords.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../../pages/data/index.json',import.meta.url)));
const save='CMP:58cfa479709294b9809be1b7',copy='CMP:9ea919967152aa85bc1c7169',see='CMP:b937ee54b7c000fafe11d338';
const cases=[
 ['The heavy box was lifted by the awake robot.',{property0Subjectheavy:'physical'},'CMP:e1d0059daad4093d8a5ce05c'],
 ['The records were not stored by us.',{},save],['Was I seen by you?',{},see],
 ['They were copied by it.',{subject0:'new:the files',object0:'new:the program'},copy],
 ['The files were saved by the routine before they were copied by the program.',{subject1:'0'},save],
 ['The door was closed by the wind.',{passiveBy0:'actor'},'CMP:3019a12938289fa9f3a23237'],
 ['The file was saved by a program.',{},save],['The file was seen by me.',{},see]
];
const rows=[];
for(const [index,[input,answers,predicate]] of cases.entries()){
 const plan=storyReading(input,authority,{answers});assert(plan?.events,input+' '+JSON.stringify(plan));
 const {midi}=await scoreStory(plan,authority),meaning=decodeStoryMidi(midi,authority.atoms),event=meaning.events[0];
 assert.equal(event.predicate,predicate);assert.deepEqual(event.arguments.map(a=>a.entity),[1,0]);
 assert.deepEqual(event.arguments.map(a=>a.role),predicate===see?['experiencer','source']:index===5?['cause','bearer']:['actor','target']);
 assert.deepEqual(event.scopes,index===1?['time_before_speech','negation']:['time_before_speech']);
 assert.equal(meaning.speech_act,index===2?'question':'assertion');assert.equal(meaning.runtime_state,1);
 assert.equal(meaning.events.length,index===4?2:1);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms),authority.atoms),meaning);
 rows.push({input,answers,meaning});
}
assert.deepEqual(rows[0].meaning.events[0].arguments.map(a=>a.properties),[['LIF:001'],[{contextual_norm:'heavy'}]]);
assert(rows[1].meaning.entities[0].plural);assert.deepEqual(rows[1].meaning.entities[1].identity,{kind:'deictic',role:'speaker_group'});
assert.deepEqual(rows[2].meaning.entities.map(e=>e.identity),[{kind:'deictic',role:'speaker'},{kind:'deictic',role:'addressee'}]);
assert(rows[3].meaning.entities[0].plural);
assert.equal(rows[4].meaning.events[1].predicate,copy);assert.deepEqual(rows[4].meaning.events[1].arguments.map(a=>a.entity),[2,0]);
assert.deepEqual(rows[4].meaning.relations,[{kind:'before',events:[0,1]}]);
assert.equal(rows[6].meaning.entities[1].identity.reference_mode,'indefinite_singular');
assert.deepEqual(rows[7].meaning.entities[1].identity,{kind:'deictic',role:'speaker'});
const revision=execFileSync('git',['rev-parse','HEAD'],{cwd:new URL('../..',import.meta.url),encoding:'utf8'}).trim();
fs.writeFileSync(new URL('./heldout-combinations.json',import.meta.url),JSON.stringify({status:'pass',revision,cases:rows},null,2)+'\n');
console.log('PASS eight post-implementation melody/chord pairs with independent predicates, roles, reference order, scope, runtime, property and relationship assertions.');
