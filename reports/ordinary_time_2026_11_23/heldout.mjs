import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [root,output]=process.argv.slice(2),load=name=>import(pathToFileURL(path.join(root,'pages',name)));
const {storyReading}=await load('story_readings.mjs'),{scoreStory,decodeStoryMidi}=await load('story_music.mjs');
const {compactChordMidi,expandChordMidi}=await load('compact_chords.mjs');
const a=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json'))),save='CMP:58cfa479709294b9809be1b7',copy='CMP:9ea919967152aa85bc1c7169';
// Intentions selected after the implementation was frozen, before these runs.
const cases=[
 {text:'Yesterday, the narrow robot saved the stored file. [0]',answers:{property0Subjectnarrow:'physical'},predicate:save,roles:['actor','target'],entities:[0,1],properties:[[{contextual_norm:'narrow'}],['DAT:000']],scopes:['time_previous_day','time_before_speech'],runtime:0},
 {text:'Tomorrow, will Nora keep the box cold? [2]',answers:{condition0:'physical'},predicate:'CMP:cac584a394535e4912c75b5a',roles:['cause','bearer'],entities:[0,1],condition:{contextual_norm:'cold'},scopes:['time_next_day','time_after_speech'],runtime:2,act:'question'},
 {text:'Nora does not need to copy the record tomorrow.',answers:{timeScope0:'event'},predicate:copy,roles:['actor','target'],entities:[0,1],scopes:['negation','modality_necessary','time_next_day']},
 {text:'Can the file be saved by the program today?',answers:{timeScope0:'event'},predicate:save,roles:['actor','target'],entities:[1,0],scopes:['ability','time_current_day'],act:'question'},
 {text:'Yesterday, Nora placed the box at the cold gate.',answers:{property0Destinationcold:'physical'},predicate:'CMP:64574c1a25d72a89aafc46ef',roles:['actor','target','destination'],entities:[0,1,2],properties:[[],[],[{contextual_norm:'cold'}]],scopes:['time_previous_day','time_before_speech']},
 {text:'Yesterday, the file was not being copied by the robot.',predicate:copy,roles:['actor','target'],entities:[1,0],scopes:['time_previous_day','time_before_speech','negation','aspect_ongoing']},
 {text:'The robot saved the record yesterday. It will copy it tomorrow.',answers:{subject1:'0'},predicate:save,roles:['actor','target'],entities:[0,1],scopes:['time_previous_day','time_before_speech'],second:{predicate:copy,entities:[0,1],scopes:['time_next_day','time_after_speech']}},
 {text:'Nora saved the file yesterday. Today, the file is stored.',predicate:save,roles:['actor','target'],entities:[0,1],scopes:['time_previous_day','time_before_speech'],second:{predicate:'DAT:000',entities:[1],scopes:['time_current_day']}}
];
const results=[];
for(const c of cases){
 const plan=storyReading(c.text,a,{answers:c.answers});assert(plan?.events,c.text+' '+JSON.stringify(plan));
 const {midi}=await scoreStory(plan,a),m=decodeStoryMidi(midi,a.atoms),e=m.events[0];
 assert.equal(e.predicate,c.predicate,c.text);assert.deepEqual(e.scopes,c.scopes,c.text);
 assert.deepEqual(e.arguments.map(v=>v.role),c.roles);assert.deepEqual(e.arguments.map(v=>v.entity),c.entities);
 assert.deepEqual(e.arguments.map(v=>v.properties),c.properties||c.roles.map(()=>[]));
 assert.deepEqual(e.condition,c.condition);assert.equal(m.runtime_state,c.runtime??1);assert.equal(m.speech_act,c.act||'assertion');
 assert.deepEqual(m.relations,[]);assert.equal(m.events.length,c.second?2:1);
 if(c.second){assert.equal(m.events[1].predicate,c.second.predicate);assert.deepEqual(m.events[1].scopes,c.second.scopes);assert.deepEqual(m.events[1].arguments.map(v=>v.entity),c.second.entities);}
 const chords=compactChordMidi(midi,a.atoms);assert.deepEqual(decodeStoryMidi(expandChordMidi(chords,a.atoms),a.atoms),m);
 results.push({input:c.text,answers:c.answers||{},status:'pass',melody_sha256:createHash('sha256').update(midi).digest('hex'),chord_sha256:createHash('sha256').update(chords).digest('hex'),meaning:m});
}
fs.writeFileSync(output,JSON.stringify({status:'pass',note:'Post-implementation engineering combinations, not an independently sampled language benchmark.',results},null,2)+'\n');
console.log('PASS eight post-implementation combinations with independently specified expectations.');
