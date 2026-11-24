import assert from 'node:assert/strict';
import fs from 'node:fs';
import {storyReading,storyRoles} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {analyzeEnglish} from '../pages/english.mjs';
import {recognizedClausePredicate} from '../pages/dictionary_clauses.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {encodeName} from '../pages/names.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const placement='CMP:64574c1a25d72a89aafc46ef',displacement='CMP:82dc9c681fbaf7944cb7b85b';
const word=label=>storyWords.find(w=>w.word===label).id;
let cases=0;
async function hear(text,{state=1,scopes=[],act='assertion',answers={}}={}){
 const plan=storyReading(text+' ['+state+']',authority,{answers});assert(plan?.events,text+' '+JSON.stringify(plan));
 const {midi}=await scoreStory(plan,authority),heard=decodeStoryMidi(midi,authority.atoms);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms),authority.atoms),heard);
 assert.equal(heard.events[0].predicate,placement,text);assert.deepEqual(heard.events[0].scopes,scopes,text);
 assert.deepEqual(heard.events[0].arguments.map(a=>a.role),['actor','target','destination']);
 assert.equal(heard.runtime_state,state);assert.equal(heard.speech_act,act);cases++;
 return {plan,heard,midi};
}
for(const state of [0,1,2])for(const [text,scopes,act] of [
 ['Nora puts the box at the gate.',[]],['Mira put the board at the station.',['time_before_speech']],
 ['We place the book at the desk.',[]],['The robot placed the box at the door.',['time_before_speech']],
 ['Nora is putting the box at the gate.',['aspect_ongoing']],
 ['Nora was not placing the box at the gate.',['time_before_speech','negation','aspect_ongoing']],
 ['Nora will not put the box at the gate.',['time_after_speech','negation']],
 ['Nora cannot put the box at the gate.',['negation','ability']],
 ['Nora might not put the box at the gate.',['modality_possible','negation']],
 ['Nora needs to place the box at the gate.',['modality_necessary']],
 ['Can Nora put the box at the gate?',['ability'],'question'],
 ['Did Nora put the box at the gate?',['time_before_speech'],'question'],
 ['Put the box at the gate.',[],'command'],['Please place the box at the gate.',[],'command'],
 ['Do not put the box at the gate.',['negation'],'command']
])await hear(text,{state,scopes,act:act||'assertion'});

for(const subject of ['I','We','You','The robots']){
 const text=subject+' put the box at the gate.';
 assert.equal(storyReading(text,authority)?.question?.key,'tense0');
 const present=await hear(text,{answers:{tense0:'present'}});
 const past=await hear(text,{answers:{tense0:'past'},scopes:['time_before_speech']});
 assert.notDeepEqual(past.midi,present.midi);
}
for(const [text,scopes] of [['I did put the box at the gate.',['time_before_speech']],
 ['We will put the box at the gate.',['time_after_speech']],['You can put the box at the gate.',['ability']]]){
 assert(!storyReading(text,authority)?.question);await hear(text,{scopes});
}
const described=await hear('The awake robot placed the full box at the closed gate.',{scopes:['time_before_speech']});
assert.deepEqual(described.heard.events[0].arguments.map(a=>a.properties),[['LIF:001'],[word('full')],[word('closed')]]);
const alternatives=await hear('Nora put the box or the crate at the gate.',{scopes:['time_before_speech']});
assert.equal(alternatives.heard.events[0].arguments[1].coordination,'any_of');
assert.equal(alternatives.heard.events[0].arguments[1].alternatives.length,1);
for(const [text,actor,target,destination] of [
 ['Nora placed the box at the gate.','nora','box','gate'],
 ['Mira placed the gate at the box.','mira','gate','box']
]){
 const {heard}=await hear(text,{scopes:['time_before_speech']});
 for(const [i,name] of [actor,target,destination].entries())assert.deepEqual(heard.entities[heard.events[0].arguments[i].entity].identity.phonemes,(await encodeName(name)).phonemes);
}
for(const text of ['Nora placed the box at the gate and Mira held the rope.',
 'Nora placed the box at the gate before Mira held the rope.',
 'If Nora placed the box at the gate, Mira will hold the rope.',
 'Nora placed the box at the gate and placed the board at the door.']){
 const {heard}=await hear(text,{scopes:['time_before_speech']});assert.equal(heard.events.length,2);assert.equal(heard.relations.length,1);
 if(text.startsWith('If')){assert.equal(heard.relations[0].kind,'condition');assert.deepEqual(heard.events[1].scopes,['time_after_speech']);}
}
for(const [text,key] of [['Nora put the file at the gate.','physical0'],['Nora placed the box at the folder.','place0'],
 ['Nora placed Mira at the gate.','physical0']]){
 assert.equal(storyReading(text,authority)?.question?.key,key,text);
 assert.equal(storyReading(text,authority,{answers:{[key]:'other'}}),null);
 await hear(text,{scopes:['time_before_speech'],answers:{[key]:'physical'}});
}
await hear('"Put" placed the box at the gate.',{scopes:['time_before_speech']});
await hear('Nora placed the box at "At".',{scopes:['time_before_speech'],answers:{place0:'physical'}});
for(const text of ['Nora put the box.','Nora placed the box on the table.','Nora put the box in the crate.',
 'Nora put the box at the gate with a tool.','Nora put only the box at the gate.','Nora put the box at the gate yesterday morning.',
 'The box was put at the gate.','Nora has put the box at the gate.','Nora putted the box at the gate.',
 'Nora is puting the box at the gate.','Nora put the box at the box.','Nora held the box at the gate.'])
 assert.equal(storyReading(text,authority),null,text);
for(const form of ['put','puts','putting','place','places','placed','placing']){
 assert(analyzeEnglish('Nora '+form+' the box at the gate.',authority).term_coverage.some(t=>t.term===form&&t.matches.some(m=>m.target_id===placement)),form);
 assert.equal(recognizedClausePredicate('Nora '+form+' the box at the gate.',authority),form);
}
for(const form of ['putted','puting'])assert.equal(recognizedClausePredicate('Nora '+form+' the box at the gate.',authority),null);
assert.deepEqual(storyRoles(placement),[['actor','target','destination']]);
assert(storyWords.find(w=>w.id===placement).parts.includes(displacement));

// A missing or substituted destination, aliased participant, or wrong nested
// arrival is rejected from the emitted sound, rather than trusted from an IR.
for(const change of [
 p=>p.events[0].arguments.pop(),
 p=>p.events[0].arguments[2].role='recipient',
 p=>p.events[0].arguments[1].entity=p.events[0].arguments[2].entity,
 p=>p.events[0].arguments[1].entity=p.events[0].arguments[0].entity
]){
 const plan=structuredClone(described.plan);change(plan);
 const {midi}=await scoreStory(plan,authority);assert.throws(()=>decodeStoryMidi(midi,authority.atoms));
}
const damaged=structuredClone(authority);
damaged.compound_plans[placement].expanded.nodes.find(n=>n.root_id==='MOV:110').root_id='MOV:111';
await assert.rejects(()=>scoreStory(storyReading('Nora placed the box at the gate.',damaged),damaged));
console.log('PASS '+cases+' independently decoded placement messages, three roles and adjective attachments, all runtimes, tense ambiguity, scope, clauses, literal choices and damaged-score rejection.');
